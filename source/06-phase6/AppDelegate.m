#import "AppDelegate.h"
#import "CanvasView.h"
#import "SceneBridge.h"

// 列宽常量
static const CGFloat kCtrlW  = 160.0;
static const CGFloat kParamW = 220.0;
static const CGFloat kWinW   = 1060.0;
static const CGFloat kWinH   = 600.0;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self setupMenuBar];

    // 1. 创建 Bridge（C++ 核心层在此初始化）
    _bridge = [[SceneBridge alloc] init];

    // 2. 创建窗口
    NSRect frame = NSMakeRect(100, 100, kWinW, kWinH);
    _window = [[NSWindow alloc]
                initWithContentRect:frame
                          styleMask:NSWindowStyleMaskTitled |
                                    NSWindowStyleMaskClosable |
                                    NSWindowStyleMaskResizable |
                                    NSWindowStyleMaskMiniaturizable
                            backing:NSBackingStoreBuffered
                              defer:NO];
    [_window setTitle:@"06-Phase6：设计模式绘图示例"];

    // 3. 组装三列布局
    CGFloat canvasX = kCtrlW;
    CGFloat canvasW = kWinW - kCtrlW - kParamW;

    // 左：工具面板
    _controlPanel = [[ControlPanel alloc] initWithFrame:NSMakeRect(0, 0, kCtrlW, kWinH)];
    _controlPanel.delegate = self;

    // 中：OpenGL 画布
    NSOpenGLPixelFormat *pf = [CanvasView createPixelFormat];
    _canvasView = [[CanvasView alloc] initWithFrame:NSMakeRect(canvasX, 0, canvasW, kWinH)
                                        pixelFormat:pf];
    _canvasView.bridge = _bridge;

    // 右：参数面板
    _paramPanel = [[ShapeParamPanel alloc] initWithFrame:NSMakeRect(canvasX + canvasW, 0, kParamW, kWinH)];
    _paramPanel.delegate = self;

    NSView *content = _window.contentView;
    [content addSubview:_controlPanel];
    [content addSubview:_canvasView];
    [content addSubview:_paramPanel];

    [_window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

// ── 菜单栏 ─────────────────────────────────────────────────────────

- (void)setupMenuBar {
    NSMenu *menuBar = [[NSMenu alloc] init];

    // 应用菜单（第一项）
    NSMenuItem *appItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] init];
    [appMenu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
    [appItem setSubmenu:appMenu];
    [menuBar addItem:appItem];

    // 编辑菜单
    NSMenuItem *editItem = [[NSMenuItem alloc] init];
    NSMenu *editMenu = [[NSMenu alloc] initWithTitle:@"编辑"];
    NSMenuItem *undoItem = [[NSMenuItem alloc] initWithTitle:@"撤销"
                                                       action:@selector(undoAction:)
                                                keyEquivalent:@"z"];
    undoItem.target = self;
    [editMenu addItem:undoItem];
    [editItem setSubmenu:editMenu];
    [menuBar addItem:editItem];

    [NSApp setMainMenu:menuBar];
}

- (IBAction)undoAction:(id)sender {
    [_canvasView performUndo];
}

// ── ControlPanelDelegate ──────────────────────────────────────────

- (void)controlPanel:(id)panel didSelectTool:(CPShapeTool)tool {
    [_paramPanel switchToTool:tool];
}

- (void)controlPanelDidRequestUndo:(id)panel {
    [_canvasView performUndo];
}

- (void)controlPanelDidRequestClear:(id)panel {
    [_bridge clearAll];
    [_canvasView setNeedsDisplay:YES];
}

// ── ShapeParamPanelDelegate ───────────────────────────────────────

- (void)paramPanelDidRequestDraw:(id)panel {
    NSDictionary *p = [_paramPanel currentParams];
    CPShapeTool tool = (CPShapeTool)[p[@"tool"] integerValue];

    switch (tool) {
        case CPShapeToolLine: {
            CGFloat r, g, b, a;
            [[p[@"color"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&r green:&g blue:&b alpha:&a];
            [_bridge addLineFromX:[p[@"x1"] floatValue] y:[p[@"y1"] floatValue]
                              toX:[p[@"x2"] floatValue] y:[p[@"y2"] floatValue]
                           colorR:(float)r g:(float)g b:(float)b];
            break;
        }
        case CPShapeToolArc: {
            CGFloat r, g, b, a;
            [[p[@"color"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&r green:&g blue:&b alpha:&a];
            [_bridge addArcCX:[p[@"cx"] floatValue]
                           cy:[p[@"cy"] floatValue]
                       radius:[p[@"radius"] floatValue]
                     startDeg:[p[@"startDeg"] floatValue]
                       endDeg:[p[@"endDeg"] floatValue]
                       colorR:(float)r g:(float)g b:(float)b];
            break;
        }
        case CPShapeToolPolygon: {
            NSArray<NSValue *> *points = [self parsePointsString:p[@"pointsString"]];
            if (points.count < 3) break;

            CGFloat sr, sg, sb, sa;
            [[p[@"strokeColor"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&sr green:&sg blue:&sb alpha:&sa];
            CGFloat fr, fg, fb, fa;
            [[p[@"fillColor"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&fr green:&fg blue:&fb alpha:&fa];

            [_bridge addPolygonWithPoints:points
                                  strokeR:(float)sr g:(float)sg b:(float)sb
                                    fillR:(float)fr g:(float)fg b:(float)fb
                                fillStyle:(SBFillStyle)[p[@"fillStyle"] integerValue]];
            break;
        }
    }

    [_canvasView setNeedsDisplay:YES];
}

// ── 工具方法 ──────────────────────────────────────────────────────

// 解析 "x1,y1;x2,y2;..." 格式的顶点字符串
- (NSArray<NSValue *> *)parsePointsString:(NSString *)s {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *pair in [s componentsSeparatedByString:@";"]) {
        NSArray *xy = [pair componentsSeparatedByString:@","];
        if (xy.count == 2) {
            CGFloat x = [xy[0] doubleValue];
            CGFloat y = [xy[1] doubleValue];
            [result addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
        }
    }
    return result;
}

@end
