#import "ShapeParamPanel.h"

static NSColor *panelBg()   { return [NSColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0]; }
static NSColor *fieldBg()   { return [NSColor colorWithRed:0.23 green:0.23 blue:0.23 alpha:1.0]; }
static NSColor *labelColor(){ return [NSColor colorWithWhite:0.75 alpha:1.0]; }
static NSColor *textColor() { return [NSColor colorWithWhite:0.92 alpha:1.0]; }

static NSTextField *makeLabel(NSString *text, NSRect frame) {
    NSTextField *lbl = [[NSTextField alloc] initWithFrame:frame];
    lbl.stringValue       = text;
    lbl.editable          = NO;
    lbl.bordered          = NO;
    lbl.backgroundColor   = [NSColor clearColor];
    lbl.textColor         = labelColor();
    lbl.font              = [NSFont systemFontOfSize:11];
    return lbl;
}

static NSTextField *makeField(NSString *placeholder, NSRect frame, NSString *defaultVal) {
    NSTextField *f = [[NSTextField alloc] initWithFrame:frame];
    f.placeholderString = placeholder;
    f.stringValue       = defaultVal;
    f.backgroundColor   = fieldBg();
    f.textColor         = textColor();
    f.drawsBackground   = YES;
    f.bezeled           = YES;
    return f;
}

@implementation ShapeParamPanel {
    NSView *_lineView;
    NSView *_arcView;
    NSView *_polygonView;
    BOOL    _editMode;

    // Header labels (one per sub-view)
    NSTextField *_lineHeader, *_arcHeader, *_polyHeader;

    // Draw/Apply buttons
    NSButton *_lineBtn, *_arcBtn, *_polyBtn;

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
        self.wantsLayer = YES;
        self.layer.backgroundColor = panelBg().CGColor;
        self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        [self buildLineView];
        [self buildArcView];
        [self buildPolygonView];
        [self switchToTool:CPShapeToolLine];
    }
    return self;
}

// ── 直线参数视图 ─────────────────────────────────────────────────

- (void)buildLineView {
    _lineView = [[NSView alloc] initWithFrame:self.bounds];
    _lineView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    CGFloat w = self.bounds.size.width;
    CGFloat y = self.bounds.size.height - 36;
    CGFloat fw = w - 20;

    _lineHeader = makeLabel(@"绘制 · 直线", NSMakeRect(10, y, fw, 20));
    _lineHeader.font      = [NSFont boldSystemFontOfSize:12];
    _lineHeader.textColor = textColor();
    [_lineView addSubview:_lineHeader]; y -= 32;

    [_lineView addSubview:makeLabel(@"起点 X", NSMakeRect(10, y, 60, 18))];
    _lx1 = makeField(@"X1", NSMakeRect(75, y, fw - 65, 22), @"100");
    [_lineView addSubview:_lx1]; y -= 28;

    [_lineView addSubview:makeLabel(@"起点 Y", NSMakeRect(10, y, 60, 18))];
    _ly1 = makeField(@"Y1", NSMakeRect(75, y, fw - 65, 22), @"100");
    [_lineView addSubview:_ly1]; y -= 28;

    [_lineView addSubview:makeLabel(@"终点 X", NSMakeRect(10, y, 60, 18))];
    _lx2 = makeField(@"X2", NSMakeRect(75, y, fw - 65, 22), @"400");
    [_lineView addSubview:_lx2]; y -= 28;

    [_lineView addSubview:makeLabel(@"终点 Y", NSMakeRect(10, y, 60, 18))];
    _ly2 = makeField(@"Y2", NSMakeRect(75, y, fw - 65, 22), @"300");
    [_lineView addSubview:_ly2]; y -= 34;

    [_lineView addSubview:makeLabel(@"颜色", NSMakeRect(10, y, 60, 18))];
    _lColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(75, y - 2, 44, 26)];
    _lColor.color = [NSColor blueColor];
    [_lineView addSubview:_lColor];

    _lineBtn = [self addActionButton:_lineView];
    [self addSubview:_lineView];
}

// ── 弧线参数视图 ─────────────────────────────────────────────────

- (void)buildArcView {
    _arcView = [[NSView alloc] initWithFrame:self.bounds];
    _arcView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    CGFloat w = self.bounds.size.width;
    CGFloat y = self.bounds.size.height - 36;
    CGFloat fw = w - 20;

    _arcHeader = makeLabel(@"绘制 · 弧线", NSMakeRect(10, y, fw, 20));
    _arcHeader.font      = [NSFont boldSystemFontOfSize:12];
    _arcHeader.textColor = textColor();
    [_arcView addSubview:_arcHeader]; y -= 32;

    [_arcView addSubview:makeLabel(@"圆心 X", NSMakeRect(10, y, 70, 18))];
    _aCX = makeField(@"CX", NSMakeRect(85, y, fw - 75, 22), @"300");
    [_arcView addSubview:_aCX]; y -= 28;

    [_arcView addSubview:makeLabel(@"圆心 Y", NSMakeRect(10, y, 70, 18))];
    _aCY = makeField(@"CY", NSMakeRect(85, y, fw - 75, 22), @"300");
    [_arcView addSubview:_aCY]; y -= 28;

    [_arcView addSubview:makeLabel(@"半径", NSMakeRect(10, y, 70, 18))];
    _aRadius = makeField(@"半径", NSMakeRect(85, y, fw - 75, 22), @"120");
    [_arcView addSubview:_aRadius]; y -= 28;

    [_arcView addSubview:makeLabel(@"起始角(°)", NSMakeRect(10, y, 70, 18))];
    _aStart = makeField(@"起始角", NSMakeRect(85, y, fw - 75, 22), @"0");
    [_arcView addSubview:_aStart]; y -= 28;

    [_arcView addSubview:makeLabel(@"终止角(°)", NSMakeRect(10, y, 70, 18))];
    _aEnd = makeField(@"终止角", NSMakeRect(85, y, fw - 75, 22), @"360");
    [_arcView addSubview:_aEnd]; y -= 34;

    [_arcView addSubview:makeLabel(@"颜色", NSMakeRect(10, y, 60, 18))];
    _aColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(85, y - 2, 44, 26)];
    _aColor.color = [NSColor redColor];
    [_arcView addSubview:_aColor];

    _arcBtn = [self addActionButton:_arcView];
    [self addSubview:_arcView];
}

// ── 多边形参数视图 ───────────────────────────────────────────────

- (void)buildPolygonView {
    _polygonView = [[NSView alloc] initWithFrame:self.bounds];
    _polygonView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    CGFloat w = self.bounds.size.width;
    CGFloat y = self.bounds.size.height - 36;
    CGFloat fw = w - 20;

    _polyHeader = makeLabel(@"绘制 · 多边形", NSMakeRect(10, y, fw, 20));
    _polyHeader.font      = [NSFont boldSystemFontOfSize:12];
    _polyHeader.textColor = textColor();
    [_polygonView addSubview:_polyHeader]; y -= 28;

    [_polygonView addSubview:makeLabel(@"顶点 (x,y;x,y;...)", NSMakeRect(10, y, fw, 18))];
    y -= 26;
    _pPoints = makeField(@"100,100;300,100;200,300",
                          NSMakeRect(10, y, fw, 22), @"100,100;300,100;200,300");
    [_polygonView addSubview:_pPoints]; y -= 36;

    [_polygonView addSubview:makeLabel(@"边框色", NSMakeRect(10, y, 60, 18))];
    _pStrokeColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(75, y - 2, 44, 26)];
    _pStrokeColor.color = [NSColor blackColor];
    [_polygonView addSubview:_pStrokeColor]; y -= 38;

    [_polygonView addSubview:makeLabel(@"填充色", NSMakeRect(10, y, 60, 18))];
    _pFillColor = [[NSColorWell alloc] initWithFrame:NSMakeRect(75, y - 2, 44, 26)];
    _pFillColor.color = [NSColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:0.7];
    [_polygonView addSubview:_pFillColor]; y -= 44;

    [_polygonView addSubview:makeLabel(@"填充样式", NSMakeRect(10, y, 60, 18))];
    _pFillStyle = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, y - 28, fw, 26)];
    [_pFillStyle addItemsWithTitles:@[@"纯色 Solid", @"斜线 Hatch", @"网格 Grid"]];
    [_polygonView addSubview:_pFillStyle];

    _polyBtn = [self addActionButton:_polygonView];
    [self addSubview:_polygonView];
}

- (NSButton *)addActionButton:(NSView *)parent {
    NSButton *btn = [[NSButton alloc] initWithFrame:NSMakeRect(10, 16, parent.bounds.size.width - 20, 34)];
    btn.bezelStyle = NSBezelStyleRounded;
    btn.buttonType = NSButtonTypeMomentaryLight;
    btn.title      = @"绘制";
    btn.target     = self;
    btn.action     = @selector(actionButtonPressed:);

    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    [para setAlignment:NSTextAlignmentCenter];
    NSAttributedString *at = [[NSAttributedString alloc]
        initWithString:@"绘制"
            attributes:@{ NSForegroundColorAttributeName: textColor(),
                          NSParagraphStyleAttributeName:  para }];
    [btn setAttributedTitle:at];
    [parent addSubview:btn];
    return btn;
}

// ── Button action ────────────────────────────────────────────────

- (void)actionButtonPressed:(id)sender {
    if (_editMode) {
        if ([_delegate respondsToSelector:@selector(paramPanelDidRequestApply:)]) {
            [_delegate paramPanelDidRequestApply:self];
        }
    } else {
        [_delegate paramPanelDidRequestDraw:self];
    }
}

// ── Public interface ──────────────────────────────────────────────

- (void)switchToTool:(CPShapeTool)tool {
    _editMode = NO;
    _lineView.hidden    = (tool != CPShapeToolLine);
    _arcView.hidden     = (tool != CPShapeToolArc);
    _polygonView.hidden = (tool != CPShapeToolPolygon);
    [self updateHeadersForEditMode:NO];
}

- (void)switchToDrawMode {
    _editMode = NO;
    [self updateHeadersForEditMode:NO];
}

- (void)showPropertiesForShapeType:(NSInteger)type params:(NSDictionary *)params {
    _editMode = YES;

    // Map shape type (0=Line, 1=Arc, 2=Polygon) to CPShapeTool (same values)
    _lineView.hidden    = (type != 0);
    _arcView.hidden     = (type != 1);
    _polygonView.hidden = (type != 2);

    if (type == 0) {
        if (params[@"x1"]) _lx1.stringValue = [NSString stringWithFormat:@"%.1f", [params[@"x1"] floatValue]];
        if (params[@"y1"]) _ly1.stringValue = [NSString stringWithFormat:@"%.1f", [params[@"y1"] floatValue]];
        if (params[@"x2"]) _lx2.stringValue = [NSString stringWithFormat:@"%.1f", [params[@"x2"] floatValue]];
        if (params[@"y2"]) _ly2.stringValue = [NSString stringWithFormat:@"%.1f", [params[@"y2"] floatValue]];
        if (params[@"color"]) _lColor.color = params[@"color"];
    } else if (type == 1) {
        if (params[@"cx"])       _aCX.stringValue     = [NSString stringWithFormat:@"%.1f", [params[@"cx"] floatValue]];
        if (params[@"cy"])       _aCY.stringValue     = [NSString stringWithFormat:@"%.1f", [params[@"cy"] floatValue]];
        if (params[@"radius"])   _aRadius.stringValue = [NSString stringWithFormat:@"%.1f", [params[@"radius"] floatValue]];
        if (params[@"startDeg"]) _aStart.stringValue  = [NSString stringWithFormat:@"%.1f", [params[@"startDeg"] floatValue]];
        if (params[@"endDeg"])   _aEnd.stringValue    = [NSString stringWithFormat:@"%.1f", [params[@"endDeg"] floatValue]];
        if (params[@"color"]) _aColor.color = params[@"color"];
    } else if (type == 2) {
        if (params[@"strokeColor"]) _pStrokeColor.color = params[@"strokeColor"];
        if (params[@"fillColor"])   _pFillColor.color   = params[@"fillColor"];
        if (params[@"fillStyle"])   [_pFillStyle selectItemAtIndex:[params[@"fillStyle"] integerValue]];
    }

    [self updateHeadersForEditMode:YES];
}

- (void)updateHeadersForEditMode:(BOOL)edit {
    NSString *lineTitle = edit ? @"编辑 · 直线"   : @"绘制 · 直线";
    NSString *arcTitle  = edit ? @"编辑 · 弧线"   : @"绘制 · 弧线";
    NSString *polyTitle = edit ? @"编辑 · 多边形" : @"绘制 · 多边形";
    NSString *btnTitle  = edit ? @"应用"          : @"绘制";

    _lineHeader.stringValue = lineTitle;
    _arcHeader.stringValue  = arcTitle;
    _polyHeader.stringValue = polyTitle;

    for (NSButton *btn in @[_lineBtn, _arcBtn, _polyBtn]) {
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        [para setAlignment:NSTextAlignmentCenter];
        NSAttributedString *at = [[NSAttributedString alloc]
            initWithString:btnTitle
                attributes:@{ NSForegroundColorAttributeName: textColor(),
                              NSParagraphStyleAttributeName:  para }];
        [btn setAttributedTitle:at];
    }
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
    NSInteger styleIdx = [_pFillStyle indexOfSelectedItem];
    return @{
        @"tool":         @(CPShapeToolPolygon),
        @"pointsString": _pPoints.stringValue,
        @"strokeColor":  _pStrokeColor.color,
        @"fillColor":    _pFillColor.color,
        @"fillStyle":    @(styleIdx),
    };
}

@end
