#pragma once
#include "Shape.h"
#include "FillStrategy.h"
#include <vector>
#include <memory>
#include <string>

class ShapePolygon : public Shape {
public:
    ShapePolygon(std::vector<Point2D> vertices,
                 Color strokeColor,
                 Color fillColor,
                 std::unique_ptr<IFillStrategy> fillStrategy);
    ShapeType type() const override { return ShapeType::Polygon; }
    void draw() const override;
    bool containsPoint(Point2D p, float tol) const override;

    const std::vector<Point2D>& vertices()    const { return _vertices;    }
    Color                       strokeColor() const { return _strokeColor; }
    Color                       fillColor()   const { return _fillColor;   }
    const std::string&          fillStrategyName() const { return _fillStrategyName; }

    void setVertices(std::vector<Point2D> v) { _vertices = std::move(v); }
    void setStrokeColor(Color c)             { _strokeColor = c; }
    void setFillColor(Color c)               { _fillColor   = c; }
    void setFillStrategyByName(const std::string& name);

    // 策略模式核心：运行时替换填充算法
    void setFillStrategy(std::unique_ptr<IFillStrategy> strategy);

private:
    std::vector<Point2D>           _vertices;
    Color                          _strokeColor;
    Color                          _fillColor;
    std::unique_ptr<IFillStrategy> _fillStrategy;
    std::string                    _fillStrategyName;
};
