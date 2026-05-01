#include "ShapeLine.h"
#include <OpenGL/gl.h>

ShapeLine::ShapeLine(Point2D start, Point2D end, Color color)
    : _start(start), _end(end), _color(color) {}

void ShapeLine::draw() const {
    glColor4f(_color.r, _color.g, _color.b, _color.a);
    glBegin(GL_LINES);
    glVertex2f(_start.x, _start.y);
    glVertex2f(_end.x,   _end.y);
    glEnd();
}
