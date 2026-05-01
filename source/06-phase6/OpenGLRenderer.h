#pragma once
#include "Viewport.h"
#include <vector>

class Scene;
class Shape;

class OpenGLRenderer {
public:
    void setup();

    // Renders scene: clears, draws grid, draws all shapes.
    // Call renderSelectionHighlight / renderPreview* then endFrame() afterwards.
    void render(const Scene& scene, int viewportW, int viewportH);

    void renderSelectionHighlight(Shape* shape);
    void renderGrid(int w, int h);

    void renderPreviewLine(Point2D p1, Point2D p2);
    void renderPreviewArc(float cx, float cy, float radius, float startDeg, float endDeg);
    void renderPreviewPolygon(const std::vector<Point2D>& pts);

    void endFrame();

    Viewport& viewport() { return _viewport; }
    const Viewport& viewport() const { return _viewport; }

private:
    void beginFrame(int w, int h);

    Viewport _viewport;
    bool     _initialized = false;
};
