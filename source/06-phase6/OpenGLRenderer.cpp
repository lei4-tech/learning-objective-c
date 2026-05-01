#include "OpenGLRenderer.h"
#include "Scene.h"
#include <OpenGL/gl.h>

void OpenGLRenderer::setup() {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_LINE_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glLineWidth(1.5f);
}

void OpenGLRenderer::render(const Scene& scene, int w, int h) {
    beginFrame(w, h);
    for (auto& shape : scene.shapes()) {
        shape->draw();
    }
    endFrame();
}

void OpenGLRenderer::beginFrame(int w, int h) {
    glViewport(0, 0, w, h);
    glClearColor(0.95f, 0.95f, 0.95f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

    // 正投影：左下角 (0,0)，右上角 (w,h)，与 NSView 坐标系一致
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, w, 0, h, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

void OpenGLRenderer::endFrame() {
    glFlush();
}
