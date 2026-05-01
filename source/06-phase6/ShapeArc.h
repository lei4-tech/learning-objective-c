#pragma once
#include "Shape.h"

class ShapeArc : public Shape {
public:
    // cx/cy: 圆心坐标，startDeg/endDeg: 起止角度（度数，逆时针）
    ShapeArc(float cx, float cy, float radius,
             float startDeg, float endDeg, Color color);
    ShapeType type() const override { return ShapeType::Arc; }
    void draw() const override;  // 用 64 段 GL_LINE_STRIP 逼近圆弧
private:
    float _cx, _cy, _radius, _startDeg, _endDeg;
    Color _color;
    static constexpr int kSegments = 64;
};
