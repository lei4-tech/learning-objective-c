#import "CanvasView.h"
#import "SceneBridge.h"

@implementation CanvasView

+ (NSOpenGLPixelFormat *)createPixelFormat {
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize,    24,
        NSOpenGLPFAAlphaSize,     8,
        NSOpenGLPFADepthSize,    16,
        NSOpenGLPFAStencilSize,   8,   // HatchFill / GridFill 需要 stencil buffer
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy,  // GL 2.1 固定管线
        0
    };
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
    [[self openGLContext] makeCurrentContext];
    // 开启 Retina 分辨率渲染
    [self setWantsBestResolutionOpenGLSurface:YES];
    // 初始化 GL 状态（混合、抗锯齿等）
    [_bridge setup];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[self openGLContext] makeCurrentContext];

    // 使用 backing 坐标获取实际像素尺寸（Retina 屏幕为逻辑尺寸的 2 倍）
    NSRect backing = [self convertRectToBacking:[self bounds]];
    [_bridge renderWithViewportWidth:(int)backing.size.width
                              height:(int)backing.size.height];

    [[self openGLContext] flushBuffer];
}

- (void)reshape {
    [super reshape];
    [self setNeedsDisplay:YES];
}

- (void)performUndo {
    [_bridge undo];
    [self setNeedsDisplay:YES];
}

@end
