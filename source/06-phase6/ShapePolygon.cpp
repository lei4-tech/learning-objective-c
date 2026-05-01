#include "ShapePolygon.h"
#include <OpenGL/gl.h>

ShapePolygon::ShapePolygon(std::vector<Point2D> vertices,
                            Color strokeColor,
                            Color fillColor,
                            std::unique_ptr<IFillStrategy> fillStrategy)
    : _vertices(std::move(vertices))
    , _strokeColor(strokeColor)
    , _fillColor(fillColor)
    , _fillStrategy(std::move(fillStrategy)) {}

void ShapePolygon::draw() const {
    if (_vertices.size() < 3) return;

    // 先填充，再画轮廓（轮廓覆盖在填充之上）
    if (_fillStrategy) {
        _fillStrategy->fill(_vertices, _fillColor);
    }

    glColor4f(_strokeColor.r, _strokeColor.g, _strokeColor.b, _strokeColor.a);
    glBegin(GL_LINE_LOOP);
    for (auto& p : _vertices) glVertex2f(p.x, p.y);
    glEnd();
}

void ShapePolygon::setFillStrategy(std::unique_ptr<IFillStrategy> strategy) {
    _fillStrategy = std::move(strategy);
}
