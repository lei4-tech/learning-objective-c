#import <Foundation/Foundation.h>

// 填充样式枚举，镜像 C++ 侧的 Strategy 名称
typedef NS_ENUM(NSInteger, SBFillStyle) {
    SBFillStyleSolid = 0,
    SBFillStyleHatch = 1,
    SBFillStyleGrid  = 2,
};

// ObjC++ Bridge：将 C++ 的 Scene / CommandManager / ShapeFactory / OpenGLRenderer
// 封装为纯 ObjC 接口，GUI 层无需了解任何 C++ 细节
@interface SceneBridge : NSObject

// 必须在 OpenGL 上下文激活后调用（由 CanvasView.prepareOpenGL 触发）
- (void)setup;

- (void)addLineFromX:(float)x1 y:(float)y1
                  toX:(float)x2 y:(float)y2
               colorR:(float)r g:(float)g b:(float)b;

- (void)addArcCX:(float)cx cy:(float)cy
           radius:(float)radius
         startDeg:(float)startDeg
           endDeg:(float)endDeg
           colorR:(float)r g:(float)g b:(float)b;

// points: NSArray of NSValue(CGPoint)
- (void)addPolygonWithPoints:(NSArray<NSValue *> *)points
                     strokeR:(float)sr g:(float)sg b:(float)sb
                       fillR:(float)fr g:(float)fg b:(float)fb
                   fillStyle:(SBFillStyle)style;

- (void)undo;
- (BOOL)canUndo;

// 由 CanvasView.drawRect: 调用，执行实际 OpenGL 绘制
- (void)renderWithViewportWidth:(int)w height:(int)h;

- (void)clearAll;

@end
