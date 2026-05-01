#import "ShapeParamPanel.h"

// ── 内部辅助：创建带标签的输入行 ──────────────────────────────────
static NSTextField *makeLabel(NSString *text, NSRect frame) {
    NSTextField *lbl = [[NSTextField alloc] initWithFrame:frame];
    lbl.stringValue = text;
    lbl.editable    = NO;
    lbl.bordered    = NO;
    lbl.backgroundColor = [NSColor clearColor];
    lbl.font = [NSFont systemFontOfSize:11];
    return lbl;
}

static NSTextField *makeField(NSString *placeholder, NSRect frame, NSString *defaultVal) {
    NSTextField *f = [[NSTextField alloc] initWithFrame:frame];
    f.placeholderString = placeholder;
    f.stringValue       = defaultVal;
    return f;
}

// ── ShapeParamPanel ───────────────────────────────────────────────

@implementation ShapeParamPanel {
    NSView *_lineView;
    NSView *_arcView;
    NSView *_polygonView;

    // 直线字段
    NSTextField *_lx1, *_ly1, *_lx2, *_ly2;
    NSColorWell *_lColor;

    // 弧线字段
    NSTextField *_aCX, *_aCY, *_aRadius, *_aStart, *_aEnd;
    NSColorWell *_aColor;

    // 多边形字段
    NSTextField *_pPoints;
    NSColorWell *_pStrokeColor, *_pFillColor;
    NSPopUpButton *_pFillStyle;
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildLineView];
        [self buildArcView];
        [self buildPolygonView];
        [self switchToTool:CPShapeToolLine];

        // 绘制右侧边框
    }
    return self;
}

// ── 直线参数视图 ──

- (void)buildLineView {
    _lineView = [[NSView alloc] initWithFrame:self.bounds];
    _lineView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    CGFloat w = self.bounds.size.width;
    CGFloat y = self.bounds.size.height - 40;
    CGFloat fw = w - 20;  // 字段宽度

    [_lineView addSubview:makeLabel(@"直线参数", NSMakeRect(10, y, fw, 20))];
    y -= 28;

    [_lineView addSubview:makeLabel(@"起点 X", NSMakeRect(10, y, 60, 18))];
    _lx1 = makeField(@"X1", NSMakeRect(75, y, fw - 65, 22), @"100");
    [_lineView addSubview:_lx1]; y -= 26;

    [_lineView addSubview:makeLabel(@"起点 Y", NSMakeRect(10, y, 60, 18))];
    _ly1 = makeField(@"Y1", NSMakeRect(75, y, fw - 65, 22), @"100");
    [_lineView addSubview:_ly1]; y -= 26;

    [_lineView addSubview:makeLabel(@"终点 X", NSMakeRect(10, y, 60, 18))];
    _lx2 = makeField(@"X2", NSMakeRect(75, y, fw - 65, 22), @"400");
    [_lineView addSubview:_lx2]; y -= 26;

    [_lineView addSubview:makeLabel(@"终点 Y", NSMakeRect(10, y, 60, 18))];
    _ly2 = makeField(@"Y2", NSMakeRect(75, y, fw - 65, 22), @"300");
    [_lineView addSubview:_ly2]; y -= 32;

    [_lineView addSubview:makeLabel(@"颜色", NSMakeRect(10, y, 60, 18))];
    _lColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(75, y - 2, 44, 26)];
    _lColor.color = [NSColor blueColor];
    [_lineView addSubview:_lColor]; y -= 50;

    [self addDrawButton:_lineView y:y];
    [self addSubview:_lineView];
}

// ── 弧线参数视图 ──

- (void)buildArcView {
    _arcView = [[NSView alloc] initWithFrame:self.bounds];
    _arcView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    CGFloat w = self.bounds.size.width;
    CGFloat y = self.bounds.size.height - 40;
    CGFloat fw = w - 20;

    [_arcView addSubview:makeLabel(@"弧线参数", NSMakeRect(10, y, fw, 20))];
    y -= 28;

    [_arcView addSubview:makeLabel(@"圆心 X", NSMakeRect(10, y, 70, 18))];
    _aCX = makeField(@"CX", NSMakeRect(85, y, fw - 75, 22), @"300");
    [_arcView addSubview:_aCX]; y -= 26;

    [_arcView addSubview:makeLabel(@"圆心 Y", NSMakeRect(10, y, 70, 18))];
    _aCY = makeField(@"CY", NSMakeRect(85, y, fw - 75, 22), @"300");
    [_arcView addSubview:_aCY]; y -= 26;

    [_arcView addSubview:makeLabel(@"半径", NSMakeRect(10, y, 70, 18))];
    _aRadius = makeField(@"半径", NSMakeRect(85, y, fw - 75, 22), @"120");
    [_arcView addSubview:_aRadius]; y -= 26;

    [_arcView addSubview:makeLabel(@"起始角(°)", NSMakeRect(10, y, 70, 18))];
    _aStart = makeField(@"起始角", NSMakeRect(85, y, fw - 75, 22), @"0");
    [_arcView addSubview:_aStart]; y -= 26;

    [_arcView addSubview:makeLabel(@"终止角(°)", NSMakeRect(10, y, 70, 18))];
    _aEnd = makeField(@"终止角", NSMakeRect(85, y, fw - 75, 22), @"270");
    [_arcView addSubview:_aEnd]; y -= 26;
    y -= 4;
    [_arcView addSubview:makeLabel(@"颜色", NSMakeRect(10, y, 60, 18))];
    _aColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(85, y - 2, 44, 26)];
    _aColor.color = [NSColor redColor];
    [_arcView addSubview:_aColor]; y -= 50;

    [self addDrawButton:_arcView y:y];
    [self addSubview:_arcView];
}

// ── 多边形参数视图 ──

- (void)buildPolygonView {
    _polygonView = [[NSView alloc] initWithFrame:self.bounds];
    _polygonView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    CGFloat w = self.bounds.size.width;
    CGFloat y = self.bounds.size.height - 40;
    CGFloat fw = w - 20;

    [_polygonView addSubview:makeLabel(@"多边形参数", NSMakeRect(10, y, fw, 20))];
    y -= 24;
    [_polygonView addSubview:makeLabel(@"顶点 (x,y;x,y;...)", NSMakeRect(10, y, fw, 18))];
    y -= 26;
    _pPoints = makeField(@"100,100;300,100;200,300",
                          NSMakeRect(10, y, fw, 22), @"100,100;300,100;200,300");
    [_polygonView addSubview:_pPoints]; y -= 32;

    [_polygonView addSubview:makeLabel(@"边框色", NSMakeRect(10, y, 60, 18))];
    _pStrokeColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(75, y - 2, 44, 26)];
    _pStrokeColor.color = [NSColor blackColor];
    [_polygonView addSubview:_pStrokeColor]; y -= 36;

    [_polygonView addSubview:makeLabel(@"填充色", NSMakeRect(10, y, 60, 18))];
    _pFillColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(75, y - 2, 44, 26)];
    _pFillColor.color = [NSColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:0.7];
    [_polygonView addSubview:_pFillColor]; y -= 40;

    [_polygonView addSubview:makeLabel(@"填充样式", NSMakeRect(10, y, 60, 18))];
    _pFillStyle = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, y - 26, fw, 26)];
    [_pFillStyle addItemsWithTitles:@[@"纯色 Solid", @"斜线 Hatch", @"网格 Grid"]];
    [_polygonView addSubview:_pFillStyle]; y -= 60;

    [self addDrawButton:_polygonView y:y];
    [self addSubview:_polygonView];
}

- (void)addDrawButton:(NSView *)parent y:(CGFloat)y {
    NSButton *btn = [NSButton buttonWithTitle:@"绘制"
                                       target:self
                                       action:@selector(drawAction:)];
    btn.frame = NSMakeRect(10, 16, parent.bounds.size.width - 20, 32);
    btn.bezelStyle = NSBezelStyleRounded;
    [parent addSubview:btn];
}

// ── 公开接口 ──

- (void)switchToTool:(CPShapeTool)tool {
    _lineView.hidden    = (tool != CPShapeToolLine);
    _arcView.hidden     = (tool != CPShapeToolArc);
    _polygonView.hidden = (tool != CPShapeToolPolygon);
}

- (NSDictionary *)currentParams {
    if (!_lineView.hidden) {
        return @{
            @"tool":  @(CPShapeToolLine),
            @"x1":    @(_lx1.floatValue),
            @"y1":    @(_ly1.floatValue),
            @"x2":    @(_lx2.floatValue),
            @"y2":    @(_ly2.floatValue),
            @"color": _lColor.color,
        };
    }
    if (!_arcView.hidden) {
        return @{
            @"tool":     @(CPShapeToolArc),
            @"cx":       @(_aCX.floatValue),
            @"cy":       @(_aCY.floatValue),
            @"radius":   @(_aRadius.floatValue),
            @"startDeg": @(_aStart.floatValue),
            @"endDeg":   @(_aEnd.floatValue),
            @"color":    _aColor.color,
        };
    }
    // 多边形
    NSInteger styleIdx = [_pFillStyle indexOfSelectedItem];
    return @{
        @"tool":         @(CPShapeToolPolygon),
        @"pointsString": _pPoints.stringValue,
        @"strokeColor":  _pStrokeColor.color,
        @"fillColor":    _pFillColor.color,
        @"fillStyle":    @(styleIdx),
    };
}

- (void)drawAction:(id)sender {
    [_delegate paramPanelDidRequestDraw:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor separatorColor] setFill];
    NSRectFill(NSMakeRect(0, 0, 1, self.bounds.size.height));
}

@end
