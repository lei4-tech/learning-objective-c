#pragma once
#include "Shape.h"

class ShapeLine : public Shape {
public:
    ShapeLine(Point2D start, Point2D end, Color color);
    ShapeType type() const override { return ShapeType::Line; }
    void draw() const override;
private:
    Point2D _start, _end;
    Color   _color;
};
