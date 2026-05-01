#pragma once
#include "Shape.h"
#include "FillStrategy.h"
#include <vector>
#include <memory>

class ShapePolygon : public Shape {
public:
    ShapePolygon(std::vector<Point2D> vertices,
                 Color strokeColor,
                 Color fillColor,
                 std::unique_ptr<IFillStrategy> fillStrategy);
    ShapeType type() const override { return ShapeType::Polygon; }
    void draw() const override;

    // 策略模式核心：运行时替换填充算法
    void setFillStrategy(std::unique_ptr<IFillStrategy> strategy);
private:
    std::vector<Point2D>           _vertices;
    Color                          _strokeColor;
    Color                          _fillColor;
    std::unique_ptr<IFillStrategy> _fillStrategy;
};
