#import "SceneBridge.h"

// C++ Core 层头文件（.mm 文件可同时 #include C++ 和 #import ObjC）
#include "Scene.h"
#include "OpenGLRenderer.h"
#include "CommandManager.h"
#include "ShapeFactory.h"
#include "Command.h"

@implementation SceneBridge {
    // C++ 对象作为 ObjC ivar：由 ObjC 对象析构时自动销毁，ARC 不干预
    Scene          _scene;
    CommandManager _cmdManager;
    OpenGLRenderer _renderer;
}

- (void)setup {
    _renderer.setup();
}

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
    _cmdManager.undo();
}

- (BOOL)canUndo {
    return _cmdManager.canUndo() ? YES : NO;
}

- (void)renderWithViewportWidth:(int)w height:(int)h {
    _renderer.render(_scene, w, h);
}

- (void)clearAll {
    _scene.clear();
    _cmdManager.clear();
}

@end
