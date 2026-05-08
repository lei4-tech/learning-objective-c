#import "AppDelegate.h"
#import "CanvasView.h"
#import "SceneBridge.h"

static const CGFloat kCtrlW   = 160.0;
static const CGFloat kParamW  = 220.0;
static const CGFloat kWinW    = 1200.0;
static const CGFloat kWinH    = 700.0;
static const CGFloat kStatusH = 24.0;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self setupMenuBar];

    _bridge = [[SceneBridge alloc] init];

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

    CGFloat canvasX = kCtrlW;
    CGFloat canvasW = kWinW - kCtrlW - kParamW;
    CGFloat canvasH = kWinH - kStatusH;

    // Left: tool panel
    _controlPanel = [[ControlPanel alloc]
                     initWithFrame:NSMakeRect(0, 0, kCtrlW, kWinH)];
    _controlPanel.delegate = self;

    // Centre: OpenGL canvas (above the status strip)
    NSOpenGLPixelFormat *pf = [CanvasView createPixelFormat];
    _canvasView = [[CanvasView alloc]
                   initWithFrame:NSMakeRect(canvasX, kStatusH, canvasW, canvasH)
                     pixelFormat:pf];
    _canvasView.bridge         = _bridge;
    _canvasView.canvasDelegate = self;

    // Transparent label overlay — same frame, sits on top of canvas.
    _labelOverlay = [[TerrainLabelOverlay alloc]
                     initWithFrame:NSMakeRect(canvasX, kStatusH, canvasW, canvasH)];

    // Status strip below canvas
    NSView *statusBar = [[NSView alloc]
                         initWithFrame:NSMakeRect(canvasX, 0, canvasW, kStatusH)];
    statusBar.wantsLayer = YES;
    statusBar.layer.backgroundColor = [NSColor colorWithRed:0.15 green:0.15
                                                      blue:0.15 alpha:1.0].CGColor;

    _statusLabel = [[NSTextField alloc]
                    initWithFrame:NSMakeRect(8, 4, canvasW - 16, 16)];
    _statusLabel.editable        = NO;
    _statusLabel.bordered        = NO;
    _statusLabel.backgroundColor = [NSColor clearColor];
    _statusLabel.textColor       = [NSColor colorWithWhite:0.65 alpha:1.0];
    _statusLabel.font            = [NSFont monospacedSystemFontOfSize:10
                                                               weight:NSFontWeightRegular];
    _statusLabel.stringValue     = @"x: 0   y: 0 · 100%";
    [statusBar addSubview:_statusLabel];

    // Right: param panel (full height)
    _paramPanel = [[ShapeParamPanel alloc]
                   initWithFrame:NSMakeRect(canvasX + canvasW, 0, kParamW, kWinH)];
    _paramPanel.delegate = self;

    NSView *content = _window.contentView;
    [content addSubview:_controlPanel];
    [content addSubview:_canvasView];
    [content addSubview:_labelOverlay];    // on top of canvas, transparent
    [content addSubview:statusBar];
    [content addSubview:_paramPanel];

    [_window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

// ── Menu bar ──────────────────────────────────────────────────────

- (void)setupMenuBar {
    NSMenu *menuBar = [[NSMenu alloc] init];

    NSMenuItem *appItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu     = [[NSMenu alloc] init];
    [appMenu addItemWithTitle:@"退出" action:@selector(terminate:) keyEquivalent:@"q"];
    [appItem setSubmenu:appMenu];
    [menuBar addItem:appItem];

    NSMenuItem *editItem = [[NSMenuItem alloc] init];
    NSMenu *editMenu     = [[NSMenu alloc] initWithTitle:@"编辑"];
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
    [_canvasView setDrawingTool:tool];
    if (tool >= CPShapeToolLine) {
        [_paramPanel switchToTool:tool];
    } else {
        // Select tool — show draw mode for whatever tool was last visible.
        [_paramPanel switchToDrawMode];
    }
}

- (void)controlPanelDidRequestUndo:(id)panel {
    [_canvasView performUndo];
}

- (void)controlPanelDidRequestClear:(id)panel {
    [_bridge clearAll];
    [_paramPanel switchToDrawMode];
    [_canvasView setNeedsDisplay:YES];
}

- (void)controlPanelDidRequestResetView:(id)panel {
    NSRect backing = [_canvasView convertRectToBacking:[_canvasView bounds]];
    [_bridge resetViewportWithViewW:(int)backing.size.width h:(int)backing.size.height];
    [_canvasView setNeedsDisplay:YES];
    _statusLabel.stringValue = @"x: 0   y: 0 · 100%";
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
            CGFloat sr, sg, sb, sa, fr, fg, fb, fa;
            [[p[@"strokeColor"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&sr green:&sg blue:&sb alpha:&sa];
            [[p[@"fillColor"] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]
             getRed:&fr green:&fg blue:&fb alpha:&fa];
            [_bridge addPolygonWithPoints:points
                                  strokeR:(float)sr g:(float)sg b:(float)sb
                                    fillR:(float)fr g:(float)fg b:(float)fb
                                fillStyle:(SBFillStyle)[p[@"fillStyle"] integerValue]];
            break;
        }
        default:
            break;
    }
    [_canvasView setNeedsDisplay:YES];
}

- (void)paramPanelDidRequestApply:(id)panel {
    NSDictionary *p = [_paramPanel currentParams];
    [_bridge updateSelectedShapeProperties:p];
    [_canvasView setNeedsDisplay:YES];
}

- (void)paramPanelDidRequestClearTerrain:(id)panel {
    [_bridge clearElevationData];
    [_bridge clearBoundary];
    [_paramPanel updateElevationPointCount:0];
    [_paramPanel updateBoundaryVertexCount:0];
    [_labelOverlay setLabels:@[]];
    [_canvasView setNeedsDisplay:YES];
}

- (void)paramPanelDidRequestClearBoundary:(id)panel {
    [_bridge clearBoundary];
    [_paramPanel updateBoundaryVertexCount:0];
    [_canvasView setNeedsDisplay:YES];
}

- (void)paramPanelDidChangeContourInterval:(id)panel interval:(float)v {
    [_bridge setContourInterval:v];
    [_canvasView setNeedsDisplay:YES];
}

- (void)paramPanelDidChangeColorScheme:(id)panel scheme:(NSInteger)s {
    [_bridge setColorScheme:s];
    [_canvasView setNeedsDisplay:YES];
}

// ── CanvasViewDelegate ────────────────────────────────────────────

- (void)canvasView:(id)cv didSelectShapeType:(NSInteger)type
        properties:(NSDictionary *)props {
    [_paramPanel showPropertiesForShapeType:type params:props];
}

- (void)canvasViewDidDeselectShape:(id)cv {
    [_paramPanel switchToDrawMode];
}

- (void)canvasView:(id)cv didMoveToWorldX:(float)x y:(float)y zoomLevel:(float)zoom {
    _statusLabel.stringValue = [NSString stringWithFormat:@"x: %.0f   y: %.0f · %.0f%%",
                                x, y, zoom * 100.0f];
}

- (void)canvasViewDidFinishFrame:(id)cv {
    NSRect backing = [_canvasView convertRectToBacking:[_canvasView bounds]];
    CGFloat scale  = [_canvasView.window backingScaleFactor];
    int w = (int)backing.size.width, h = (int)backing.size.height;

    NSArray<NSDictionary *> *worldLabels = [_bridge terrainLabelWorldPositions];
    NSMutableArray *viewLabels = [NSMutableArray arrayWithCapacity:worldLabels.count];

    for (NSDictionary *wl in worldLabels) {
        NSPoint vp = [_bridge worldToViewX:[wl[@"wx"] floatValue]
                                         y:[wl[@"wy"] floatValue]
                                      viewW:w h:h scaleFactor:scale];
        // Bounds check (vp is in canvas-view logical coordinates, origin bottom-left).
        NSRect cb = _canvasView.bounds;
        if (vp.x < 0 || vp.x > cb.size.width || vp.y < 0 || vp.y > cb.size.height)
            continue;

        [viewLabels addObject:@{
            @"x":         @(vp.x),
            @"y":         @(vp.y),
            @"text":      wl[@"text"],
            @"isContour": wl[@"isContour"],
        }];
    }

    [_labelOverlay setLabels:viewLabels];
}

- (void)canvasViewTerrainDidChange:(id)cv {
    [_paramPanel updateElevationPointCount:[_bridge elevationPointCount]];
    [_paramPanel updateBoundaryVertexCount:[_bridge boundaryVertexCount]];
    // Immediately refresh label overlay with updated terrain data.
    [self canvasViewDidFinishFrame:cv];
}

// ── Utility ───────────────────────────────────────────────────────

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
