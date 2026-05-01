#include "ShapePolygon.h"
#include <OpenGL/gl.h>
#include <cmath>
#include <algorithm>

ShapePolygon::ShapePolygon(std::vector<Point2D> vertices,
                            Color strokeColor,
                            Color fillColor,
                            std::unique_ptr<IFillStrategy> fillStrategy)
    : _vertices(std::move(vertices))
    , _strokeColor(strokeColor)
    , _fillColor(fillColor)
    , _fillStrategy(std::move(fillStrategy))
    , _fillStrategyName(_fillStrategy ? _fillStrategy->name() : "Solid") {}

void ShapePolygon::draw() const {
    if (_vertices.size() < 3) return;

    if (_fillStrategy) {
        _fillStrategy->fill(_vertices, _fillColor);
    }

    glColor4f(_strokeColor.r, _strokeColor.g, _strokeColor.b, _strokeColor.a);
    glBegin(GL_LINE_LOOP);
    for (auto& p : _vertices) glVertex2f(p.x, p.y);
    glEnd();
}

bool ShapePolygon::containsPoint(Point2D p, float tol) const {
    if (_vertices.size() < 3) return false;
    int n = static_cast<int>(_vertices.size());

    // Edge proximity test (click near border)
    for (int i = 0; i < n; ++i) {
        Point2D a = _vertices[i], b = _vertices[(i + 1) % n];
        float dx = b.x - a.x, dy = b.y - a.y;
        float len2 = dx * dx + dy * dy;
        float t = 0.0f;
        if (len2 >= 1e-6f)
            t = std::max(0.0f, std::min(1.0f, ((p.x - a.x) * dx + (p.y - a.y) * dy) / len2));
        float nx = a.x + t * dx - p.x, ny = a.y + t * dy - p.y;
        if (sqrtf(nx * nx + ny * ny) <= tol) return true;
    }

    // Point-in-polygon (ray casting) — catches interior clicks
    bool inside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
        float xi = _vertices[i].x, yi = _vertices[i].y;
        float xj = _vertices[j].x, yj = _vertices[j].y;
        if (((yi > p.y) != (yj > p.y)) &&
            (p.x < (xj - xi) * (p.y - yi) / (yj - yi) + xi))
            inside = !inside;
    }
    return inside;
}

void ShapePolygon::setFillStrategy(std::unique_ptr<IFillStrategy> strategy) {
    _fillStrategyName = strategy ? strategy->name() : "Solid";
    _fillStrategy = std::move(strategy);
}

void ShapePolygon::setFillStrategyByName(const std::string& name) {
    _fillStrategyName = name;
    if (name == "Hatch")     _fillStrategy = std::make_unique<HatchFillStrategy>();
    else if (name == "Grid") _fillStrategy = std::make_unique<GridFillStrategy>();
    else                     _fillStrategy = std::make_unique<SolidFillStrategy>();
}
