#include "OpenGLRenderer.h"
#include "Scene.h"
#include "ShapeLine.h"
#include "ShapeArc.h"
#include "ShapePolygon.h"
#include <OpenGL/gl.h>
#include <cmath>
#include <algorithm>

void OpenGLRenderer::setup() {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glLineWidth(1.5f);
}

void OpenGLRenderer::render(const Scene& scene, int w, int h) {
    if (!_initialized) {
        _viewport.initCenter(w, h);
        _initialized = true;
    }
    beginFrame(w, h);
    renderGrid(w, h);
    for (auto& shape : scene.shapes()) shape->draw();
    // Caller must call renderSelectionHighlight / renderPreview* then endFrame().
}

void OpenGLRenderer::beginFrame(int w, int h) {
    glViewport(0, 0, w, h);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    float hw = (w * 0.5f) / _viewport.zoom;
    float hh = (h * 0.5f) / _viewport.zoom;
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(_viewport.cameraX - hw, _viewport.cameraX + hw,
            _viewport.cameraY - hh, _viewport.cameraY + hh, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

void OpenGLRenderer::renderGrid(int w, int h) {
    const float gridSize = 20.0f;
    float hw = (w * 0.5f) / _viewport.zoom;
    float hh = (h * 0.5f) / _viewport.zoom;
    float left   = _viewport.cameraX - hw;
    float right  = _viewport.cameraX + hw;
    float bottom = _viewport.cameraY - hh;
    float top    = _viewport.cameraY + hh;

    float startX = floorf(left   / gridSize) * gridSize;
    float startY = floorf(bottom / gridSize) * gridSize;

    glColor4f(0.0f, 0.0f, 0.0f, 0.07f);
    glPointSize(1.5f);
    glBegin(GL_POINTS);
    for (float x = startX; x <= right; x += gridSize)
        for (float y = startY; y <= top; y += gridSize)
            glVertex2f(x, y);
    glEnd();
    glPointSize(1.0f);
}

void OpenGLRenderer::renderSelectionHighlight(Shape* shape) {
    if (!shape) return;

    float minX = 1e9f, minY = 1e9f, maxX = -1e9f, maxY = -1e9f;

    if (shape->type() == ShapeType::Line) {
        auto* line = static_cast<ShapeLine*>(shape);
        Point2D s = line->start(), e = line->end();
        minX = std::min(s.x, e.x); maxX = std::max(s.x, e.x);
        minY = std::min(s.y, e.y); maxY = std::max(s.y, e.y);
    } else if (shape->type() == ShapeType::Arc) {
        auto* arc = static_cast<ShapeArc*>(shape);
        float cx = arc->cx(), cy = arc->cy(), r = arc->radius();
        minX = cx - r; maxX = cx + r;
        minY = cy - r; maxY = cy + r;
    } else if (shape->type() == ShapeType::Polygon) {
        auto* poly = static_cast<ShapePolygon*>(shape);
        for (auto& v : poly->vertices()) {
            minX = std::min(minX, v.x); maxX = std::max(maxX, v.x);
            minY = std::min(minY, v.y); maxY = std::max(maxY, v.y);
        }
    }

    float pad = 5.0f;
    glColor4f(0.29f, 0.62f, 1.0f, 1.0f);  // #4a9eff
    glLineWidth(1.5f);
    glBegin(GL_LINE_LOOP);
    glVertex2f(minX - pad, minY - pad);
    glVertex2f(maxX + pad, minY - pad);
    glVertex2f(maxX + pad, maxY + pad);
    glVertex2f(minX - pad, maxY + pad);
    glEnd();
}

void OpenGLRenderer::renderPreviewLine(Point2D p1, Point2D p2) {
    glColor4f(0.29f, 0.62f, 1.0f, 0.55f);
    glLineWidth(1.5f);
    glBegin(GL_LINES);
    glVertex2f(p1.x, p1.y);
    glVertex2f(p2.x, p2.y);
    glEnd();
}

void OpenGLRenderer::renderPreviewArc(float cx, float cy, float radius,
                                       float startDeg, float endDeg) {
    glColor4f(0.29f, 0.62f, 1.0f, 0.55f);
    glLineWidth(1.5f);
    glBegin(GL_LINE_STRIP);
    float startRad = startDeg * static_cast<float>(M_PI) / 180.0f;
    float endRad   = endDeg   * static_cast<float>(M_PI) / 180.0f;
    for (int i = 0; i <= 64; ++i) {
        float t = startRad + (endRad - startRad) * i / 64.0f;
        glVertex2f(cx + radius * cosf(t), cy + radius * sinf(t));
    }
    glEnd();
}

void OpenGLRenderer::renderPreviewPolygon(const std::vector<Point2D>& pts) {
    if (pts.empty()) return;
    glColor4f(0.29f, 0.62f, 1.0f, 0.55f);
    glLineWidth(1.5f);
    glBegin(GL_LINE_STRIP);
    for (auto& p : pts) glVertex2f(p.x, p.y);
    glEnd();
}

void OpenGLRenderer::endFrame() {
    glLineWidth(1.5f);
    glFlush();
}
