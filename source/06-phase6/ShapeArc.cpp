#include "ShapeArc.h"
#include <OpenGL/gl.h>
#include <cmath>

ShapeArc::ShapeArc(float cx, float cy, float radius,
                   float startDeg, float endDeg, Color color)
    : _cx(cx), _cy(cy), _radius(radius)
    , _startDeg(startDeg), _endDeg(endDeg)
    , _color(color) {}

void ShapeArc::draw() const {
    glColor4f(_color.r, _color.g, _color.b, _color.a);
    glBegin(GL_LINE_STRIP);
    float startRad = _startDeg * static_cast<float>(M_PI) / 180.0f;
    float endRad   = _endDeg   * static_cast<float>(M_PI) / 180.0f;
    for (int i = 0; i <= kSegments; ++i) {
        float t  = startRad + (endRad - startRad) * i / static_cast<float>(kSegments);
        glVertex2f(_cx + _radius * cosf(t), _cy + _radius * sinf(t));
    }
    glEnd();
}

bool ShapeArc::containsPoint(Point2D p, float tol) const {
    float dx   = p.x - _cx;
    float dy   = p.y - _cy;
    float dist = sqrtf(dx * dx + dy * dy);
    if (fabsf(dist - _radius) > tol) return false;

    float startRad = _startDeg * static_cast<float>(M_PI) / 180.0f;
    float endRad   = _endDeg   * static_cast<float>(M_PI) / 180.0f;
    float angle    = atan2f(dy, dx);

    // Normalise angle into [startRad, startRad + span]
    float span = endRad - startRad;
    while (angle < startRad) angle += 2.0f * static_cast<float>(M_PI);
    return angle <= startRad + span + 1e-4f;
}
