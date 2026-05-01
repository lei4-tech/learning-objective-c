#import <AppKit/AppKit.h>

@class SceneBridge;

@interface CanvasView : NSOpenGLView

// AppDelegate 注入 bridge，CanvasView 不持有其创建逻辑
@property (strong) SceneBridge *bridge;

// 触发撤销并重绘（由 AppDelegate 和 ControlPanel 调用）
- (void)performUndo;

// 创建带 stencil buffer 的像素格式（供 AppDelegate 构造时传入）
+ (NSOpenGLPixelFormat *)createPixelFormat;

@end
