#include "ShapeLine.h"
#include <OpenGL/gl.h>
#include <cmath>
#include <algorithm>

ShapeLine::ShapeLine(Point2D start, Point2D end, Color color)
    : _start(start), _end(end), _color(color) {}

void ShapeLine::draw() const {
    glColor4f(_color.r, _color.g, _color.b, _color.a);
    glBegin(GL_LINES);
    glVertex2f(_start.x, _start.y);
    glVertex2f(_end.x,   _end.y);
    glEnd();
}

bool ShapeLine::containsPoint(Point2D p, float tol) const {
    float dx = _end.x - _start.x;
    float dy = _end.y - _start.y;
    float len2 = dx * dx + dy * dy;
    float t = 0.0f;
    if (len2 >= 1e-6f) {
        t = ((p.x - _start.x) * dx + (p.y - _start.y) * dy) / len2;
        t = std::max(0.0f, std::min(1.0f, t));
    }
    float nx = _start.x + t * dx - p.x;
    float ny = _start.y + t * dy - p.y;
    return sqrtf(nx * nx + ny * ny) <= tol;
}
