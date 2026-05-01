#pragma once
#include "Shape.h"
#include "FillStrategy.h"
#include <memory>
#include <string>
#include <vector>

// 参数包：避免过长参数列表，每种图形独立 struct
struct LineParams {
    Point2D start, end;
    Color   color;
};

struct ArcParams {
    float cx, cy, radius, startDeg, endDeg;
    Color color;
};

struct PolygonParams {
    std::vector<Point2D> vertices;
    Color                strokeColor, fillColor;
    std::string          fillStrategyName;  // "Solid" / "Hatch" / "Grid"
};

// 工厂模式：调用方只提供参数包，不直接 new 具体类
class ShapeFactory {
public:
    static std::unique_ptr<Shape> createLine(const LineParams& p);
    static std::unique_ptr<Shape> createArc(const ArcParams& p);
    static std::unique_ptr<Shape> createPolygon(const PolygonParams& p);
private:
    // 内部 Strategy 工厂，根据名称创建对应填充策略
    static std::unique_ptr<IFillStrategy> makeFillStrategy(const std::string& name);
};
