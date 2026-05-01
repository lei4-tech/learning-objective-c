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
        float px = _cx + _radius * cosf(t);
        float py = _cy + _radius * sinf(t);
        glVertex2f(px, py);
    }
    glEnd();
}
