#import "SceneBridge.h"
#import <AppKit/AppKit.h>

#include "Scene.h"
#include "OpenGLRenderer.h"
#include "CommandManager.h"
#include "ShapeFactory.h"
#include "Command.h"
#include "ShapeLine.h"
#include "ShapeArc.h"
#include "ShapePolygon.h"
#include <vector>

// Internal preview state (C++ struct, lives inside @implementation {})
struct PreviewState {
    enum Type { None, Line, Arc, Polygon } type = None;
    Point2D p1, p2;                   // Line
    float cx, cy, radius;             // Arc
    float startDeg, endDeg;           // Arc
    std::vector<Point2D> pts;         // Polygon
};

@implementation SceneBridge {
    Scene          _scene;
    CommandManager _cmdManager;
    OpenGLRenderer _renderer;
    Shape*         _selectedShape;    // non-owning; cleared on undo/clear
    PreviewState   _preview;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedShape = nullptr;
    }
    return self;
}

- (void)setup {
    _renderer.setup();
}

// ── Shape creation ───────────────────────────────────────────────

- (void)addLineFromX:(float)x1 y:(float)y1
                  toX:(float)x2 y:(float)y2
               colorR:(float)r g:(float)g b:(float)b {
    LineParams p{ {x1, y1}, {x2, y2}, {r, g, b, 1.0f} };
    auto shape = ShapeFactory::createLine(p);
    auto cmd   = std::make_unique<DrawCommand>(_scene, std::move(shape));
    _cmdManager.execute(std::move(cmd));
}

- (void)addArcCX:(float)cx cy:(float)cy
           radius:(float)radius
         startDeg:(float)startDeg
           endDeg:(float)endDeg
           colorR:(float)r g:(float)g b:(float)b {
    ArcParams p{ cx, cy, radius, startDeg, endDeg, {r, g, b, 1.0f} };
    auto shape = ShapeFactory::createArc(p);
    auto cmd   = std::make_unique<DrawCommand>(_scene, std::move(shape));
    _cmdManager.execute(std::move(cmd));
}

- (void)addPolygonWithPoints:(NSArray<NSValue *> *)points
                     strokeR:(float)sr g:(float)sg b:(float)sb
                       fillR:(float)fr g:(float)fg b:(float)fb
                   fillStyle:(SBFillStyle)style {
    std::vector<Point2D> vertices;
    for (NSValue *v in points) {
        NSPoint pt = [v pointValue];
        vertices.push_back({ static_cast<float>(pt.x), static_cast<float>(pt.y) });
    }

    std::string strategyName;
    switch (style) {
        case SBFillStyleHatch: strategyName = "Hatch"; break;
        case SBFillStyleGrid:  strategyName = "Grid";  break;
        default:               strategyName = "Solid"; break;
    }

    PolygonParams p{ vertices, {sr, sg, sb, 1.0f}, {fr, fg, fb, 1.0f}, strategyName };
    auto shape = ShapeFactory::createPolygon(p);
    auto cmd   = std::make_unique<DrawCommand>(_scene, std::move(shape));
    _cmdManager.execute(std::move(cmd));
}

- (void)undo {
    _selectedShape = nullptr;
    _cmdManager.undo();
}

- (BOOL)canUndo {
    return _cmdManager.canUndo() ? YES : NO;
}

- (void)clearAll {
    _selectedShape = nullptr;
    _scene.clear();
    _cmdManager.clear();
}

// ── Selection ────────────────────────────────────────────────────

- (BOOL)selectAtScreenX:(float)sx y:(float)sy viewW:(int)w h:(int)h {
    Point2D world = _renderer.viewport().screenToWorld(sx, sy, w, h);
    float tol = 8.0f / _renderer.viewport().zoom;
    _selectedShape = _scene.hitTest(world, tol);
    return _selectedShape != nullptr ? YES : NO;
}

- (void)clearSelection {
    _selectedShape = nullptr;
}

- (NSInteger)selectedShapeType {
    if (!_selectedShape) return -1;
    return static_cast<NSInteger>(_selectedShape->type());
}

- (NSDictionary *)selectedShapeProperties {
    if (!_selectedShape) return nil;

    if (_selectedShape->type() == ShapeType::Line) {
        auto* line = static_cast<ShapeLine*>(_selectedShape);
        Color c = line->color();
        return @{
            @"tool":  @(0),  // CPShapeToolLine
            @"x1":    @(line->start().x),
            @"y1":    @(line->start().y),
            @"x2":    @(line->end().x),
            @"y2":    @(line->end().y),
            @"color": [NSColor colorWithRed:c.r green:c.g blue:c.b alpha:c.a],
        };
    }
    if (_selectedShape->type() == ShapeType::Arc) {
        auto* arc = static_cast<ShapeArc*>(_selectedShape);
        Color c = arc->color();
        return @{
            @"tool":     @(1),  // CPShapeToolArc
            @"cx":       @(arc->cx()),
            @"cy":       @(arc->cy()),
            @"radius":   @(arc->radius()),
            @"startDeg": @(arc->startDeg()),
            @"endDeg":   @(arc->endDeg()),
            @"color":    [NSColor colorWithRed:c.r green:c.g blue:c.b alpha:c.a],
        };
    }
    // Polygon
    auto* poly = static_cast<ShapePolygon*>(_selectedShape);
    NSMutableArray<NSValue *> *pts = [NSMutableArray array];
    for (auto& v : poly->vertices())
        [pts addObject:[NSValue valueWithPoint:NSMakePoint(v.x, v.y)]];

    Color sc = poly->strokeColor(), fc = poly->fillColor();
    NSString *styleName = [NSString stringWithUTF8String:poly->fillStrategyName().c_str()];
    NSInteger styleIdx = 0;
    if ([styleName isEqualToString:@"Hatch"])      styleIdx = 1;
    else if ([styleName isEqualToString:@"Grid"])  styleIdx = 2;

    return @{
        @"tool":        @(2),  // CPShapeToolPolygon
        @"points":      pts,
        @"strokeColor": [NSColor colorWithRed:sc.r green:sc.g blue:sc.b alpha:sc.a],
        @"fillColor":   [NSColor colorWithRed:fc.r green:fc.g blue:fc.b alpha:fc.a],
        @"fillStyle":   @(styleIdx),
    };
}

- (void)updateSelectedShapeProperties:(NSDictionary *)props {
    if (!_selectedShape || !props) return;

    if (_selectedShape->type() == ShapeType::Line) {
        auto* line = static_cast<ShapeLine*>(_selectedShape);
        if (props[@"x1"]) line->setStart({ [props[@"x1"] floatValue], [props[@"y1"] floatValue] });
        if (props[@"x2"]) line->setEnd({ [props[@"x2"] floatValue], [props[@"y2"] floatValue] });
        if (props[@"color"]) {
            CGFloat r, g, b, a;
            [[props[@"color"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&r green:&g blue:&b alpha:&a];
            line->setColor({ (float)r, (float)g, (float)b, (float)a });
        }
    } else if (_selectedShape->type() == ShapeType::Arc) {
        auto* arc = static_cast<ShapeArc*>(_selectedShape);
        if (props[@"cx"])       arc->setCX([props[@"cx"] floatValue]);
        if (props[@"cy"])       arc->setCY([props[@"cy"] floatValue]);
        if (props[@"radius"])   arc->setRadius([props[@"radius"] floatValue]);
        if (props[@"startDeg"]) arc->setStartDeg([props[@"startDeg"] floatValue]);
        if (props[@"endDeg"])   arc->setEndDeg([props[@"endDeg"] floatValue]);
        if (props[@"color"]) {
            CGFloat r, g, b, a;
            [[props[@"color"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&r green:&g blue:&b alpha:&a];
            arc->setColor({ (float)r, (float)g, (float)b, (float)a });
        }
    } else if (_selectedShape->type() == ShapeType::Polygon) {
        auto* poly = static_cast<ShapePolygon*>(_selectedShape);
        if (props[@"strokeColor"]) {
            CGFloat r, g, b, a;
            [[props[@"strokeColor"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&r green:&g blue:&b alpha:&a];
            poly->setStrokeColor({ (float)r, (float)g, (float)b, (float)a });
        }
        if (props[@"fillColor"]) {
            CGFloat r, g, b, a;
            [[props[@"fillColor"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&r green:&g blue:&b alpha:&a];
            poly->setFillColor({ (float)r, (float)g, (float)b, (float)a });
        }
        if (props[@"fillStyle"]) {
            NSInteger idx = [props[@"fillStyle"] integerValue];
            const char* names[] = { "Solid", "Hatch", "Grid" };
            if (idx >= 0 && idx <= 2) poly->setFillStrategyByName(names[idx]);
        }
    }
}

// ── Preview ──────────────────────────────────────────────────────

- (void)setPreviewLineFromX:(float)x1 y:(float)y1 toX:(float)x2 y:(float)y2 {
    _preview.type = PreviewState::Line;
    _preview.p1 = { x1, y1 };
    _preview.p2 = { x2, y2 };
}

- (void)setPreviewArcCX:(float)cx cy:(float)cy radius:(float)r
               startDeg:(float)sd endDeg:(float)ed {
    _preview.type     = PreviewState::Arc;
    _preview.cx       = cx; _preview.cy = cy; _preview.radius = r;
    _preview.startDeg = sd; _preview.endDeg = ed;
}

- (void)setPreviewPolygonVertices:(NSArray<NSValue *> *)pts {
    _preview.type = PreviewState::Polygon;
    _preview.pts.clear();
    for (NSValue *v in pts) {
        NSPoint pt = [v pointValue];
        _preview.pts.push_back({ static_cast<float>(pt.x), static_cast<float>(pt.y) });
    }
}

- (void)clearPreview {
    _preview.type = PreviewState::None;
    _preview.pts.clear();
}

// ── Viewport ─────────────────────────────────────────────────────

- (void)zoomBy:(float)factor atScreenX:(float)sx y:(float)sy viewW:(int)w h:(int)h {
    _renderer.viewport().zoomBy(factor, sx, sy, w, h);
}

- (void)panByDX:(float)dx dy:(float)dy {
    _renderer.viewport().panBy(dx, dy);
}

- (void)resetViewportWithViewW:(int)w h:(int)h {
    _renderer.viewport().reset(w, h);
}

- (float)zoomLevel {
    return _renderer.viewport().zoom;
}

- (NSPoint)screenToWorldX:(float)sx y:(float)sy viewW:(int)w h:(int)h {
    Point2D p = _renderer.viewport().screenToWorld(sx, sy, w, h);
    return NSMakePoint(p.x, p.y);
}

// ── Rendering ────────────────────────────────────────────────────

- (void)renderWithViewportWidth:(int)w height:(int)h {
    _renderer.render(_scene, w, h);

    if (_selectedShape) {
        _renderer.renderSelectionHighlight(_selectedShape);
    }

    switch (_preview.type) {
        case PreviewState::Line:
            _renderer.renderPreviewLine(_preview.p1, _preview.p2);
            break;
        case PreviewState::Arc:
            _renderer.renderPreviewArc(_preview.cx, _preview.cy, _preview.radius,
                                       _preview.startDeg, _preview.endDeg);
            break;
        case PreviewState::Polygon:
            _renderer.renderPreviewPolygon(_preview.pts);
            break;
        default:
            break;
    }

    _renderer.endFrame();
}

@end
