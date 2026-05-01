#include "ShapeFactory.h"
#include "ShapeLine.h"
#include "ShapeArc.h"
#include "ShapePolygon.h"

std::unique_ptr<Shape> ShapeFactory::createLine(const LineParams& p) {
    return std::make_unique<ShapeLine>(p.start, p.end, p.color);
}

std::unique_ptr<Shape> ShapeFactory::createArc(const ArcParams& p) {
    return std::make_unique<ShapeArc>(p.cx, p.cy, p.radius,
                                      p.startDeg, p.endDeg, p.color);
}

std::unique_ptr<Shape> ShapeFactory::createPolygon(const PolygonParams& p) {
    return std::make_unique<ShapePolygon>(p.vertices, p.strokeColor, p.fillColor,
                                          makeFillStrategy(p.fillStrategyName));
}

std::unique_ptr<IFillStrategy> ShapeFactory::makeFillStrategy(const std::string& name) {
    if (name == "Hatch") return std::make_unique<HatchFillStrategy>();
    if (name == "Grid")  return std::make_unique<GridFillStrategy>();
    return std::make_unique<SolidFillStrategy>();
}
