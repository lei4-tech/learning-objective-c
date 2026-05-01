#pragma once
#include "Shape.h"

class ShapeLine : public Shape {
public:
    ShapeLine(Point2D start, Point2D end, Color color);
    ShapeType type() const override { return ShapeType::Line; }
    void draw() const override;
    bool containsPoint(Point2D p, float tol) const override;

    Point2D start() const { return _start; }
    Point2D end()   const { return _end;   }
    Color   color() const { return _color; }

    void setStart(Point2D s) { _start = s; }
    void setEnd(Point2D e)   { _end   = e; }
    void setColor(Color c)   { _color = c; }

private:
    Point2D _start, _end;
    Color   _color;
};
