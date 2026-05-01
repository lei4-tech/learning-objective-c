#import "ControlPanel.h"

static NSColor *sidebarBg()  { return [NSColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0]; }
static NSColor *activeColor(){ return [NSColor colorWithRed:0.29 green:0.62 blue:1.0  alpha:1.0]; }
static NSColor *textColor()  { return [NSColor colorWithWhite:0.88 alpha:1.0]; }

@implementation ControlPanel {
    NSArray<NSButton *> *_toolButtons;
    NSInteger            _selectedTag;
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = sidebarBg().CGColor;
        self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        [self setupButtons];
    }
    return self;
}

// Helper: create a styled tool button.
- (NSButton *)makeButtonTitle:(NSString *)title tag:(NSInteger)tag y:(CGFloat)y {
    NSButton *btn = [[NSButton alloc] initWithFrame:NSMakeRect(10, y, 140, 34)];
    btn.bezelStyle  = NSBezelStyleRounded;
    btn.buttonType  = NSButtonTypeMomentaryLight;
    btn.tag         = tag;
    btn.target      = self;
    btn.action      = @selector(buttonClicked:);

    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    [para setAlignment:NSTextAlignmentCenter];
    NSAttributedString *attrTitle = [[NSAttributedString alloc]
        initWithString:title
            attributes:@{ NSForegroundColorAttributeName: textColor(),
                          NSParagraphStyleAttributeName:  para,
                          NSFontAttributeName: [NSFont systemFontOfSize:13] }];
    [btn setAttributedTitle:attrTitle];
    return btn;
}

- (void)setupButtons {
    CGFloat y = self.bounds.size.height - 40;

    // Section header "TOOLS"
    [self addSubview:[self sectionLabel:@"TOOLS" y:y]]; y -= 28;

    struct { NSString *t; NSInteger tag; } tools[] = {
        { @"选择",   CPShapeToolSelect  },
        { @"直线",   CPShapeToolLine    },
        { @"弧线",   CPShapeToolArc     },
        { @"多边形", CPShapeToolPolygon },
    };

    NSMutableArray *btns = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        NSButton *btn = [self makeButtonTitle:tools[i].t tag:tools[i].tag y:y];
        [self addSubview:btn];
        [btns addObject:btn];
        y -= 40;
    }
    _toolButtons = [btns copy];
    _selectedTag = CPShapeToolSelect;
    [self updateButtonAppearance];

    // Separator
    NSBox *sep = [[NSBox alloc] initWithFrame:NSMakeRect(10, y + 6, 140, 1)];
    sep.boxType = NSBoxSeparator;
    [self addSubview:sep];
    y -= 16;

    // Section header "ACTIONS"
    [self addSubview:[self sectionLabel:@"ACTIONS" y:y]]; y -= 28;

    struct { NSString *t; SEL action; } actions[] = {
        { @"撤销 (⌘Z)", @selector(requestUndo:)      },
        { @"清空",       @selector(requestClear:)     },
        { @"重置视图",   @selector(requestResetView:) },
    };
    for (int i = 0; i < 3; i++) {
        NSButton *btn = [[NSButton alloc] initWithFrame:NSMakeRect(10, y, 140, 34)];
        btn.bezelStyle = NSBezelStyleRounded;
        btn.buttonType = NSButtonTypeMomentaryLight;
        btn.target     = self;
        btn.action     = actions[i].action;

        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        [para setAlignment:NSTextAlignmentCenter];
        NSAttributedString *at = [[NSAttributedString alloc]
            initWithString:actions[i].t
                attributes:@{ NSForegroundColorAttributeName: textColor(),
                              NSParagraphStyleAttributeName:  para,
                              NSFontAttributeName: [NSFont systemFontOfSize:13] }];
        [btn setAttributedTitle:at];
        [self addSubview:btn];
        y -= 40;
    }
}

- (NSTextField *)sectionLabel:(NSString *)text y:(CGFloat)y {
    NSTextField *lbl = [[NSTextField alloc] initWithFrame:NSMakeRect(10, y, 140, 16)];
    lbl.stringValue       = text;
    lbl.editable          = NO;
    lbl.bordered          = NO;
    lbl.backgroundColor   = [NSColor clearColor];
    lbl.textColor         = [NSColor colorWithWhite:0.5 alpha:1.0];
    lbl.font              = [NSFont systemFontOfSize:9 weight:NSFontWeightSemibold];
    return lbl;
}

- (void)updateButtonAppearance {
    for (NSButton *btn in _toolButtons) {
        BOOL active = (btn.tag == _selectedTag);
        btn.wantsLayer = YES;
        btn.layer.cornerRadius = 6.0;
        btn.layer.backgroundColor = active
            ? activeColor().CGColor
            : [NSColor colorWithWhite:0.28 alpha:1.0].CGColor;

        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        [para setAlignment:NSTextAlignmentCenter];
        NSColor *tc = active ? [NSColor whiteColor] : textColor();
        NSAttributedString *at = [[NSAttributedString alloc]
            initWithString:btn.title
                attributes:@{ NSForegroundColorAttributeName: tc,
                              NSParagraphStyleAttributeName:  para,
                              NSFontAttributeName: [NSFont systemFontOfSize:13] }];
        [btn setAttributedTitle:at];
    }
}

- (void)buttonClicked:(NSButton *)sender {
    _selectedTag = sender.tag;
    [self updateButtonAppearance];
    [_delegate controlPanel:self didSelectTool:(CPShapeTool)sender.tag];
}

- (void)requestUndo:(id)sender      { [_delegate controlPanelDidRequestUndo:self]; }
- (void)requestClear:(id)sender     { [_delegate controlPanelDidRequestClear:self]; }
- (void)requestResetView:(id)sender { [_delegate controlPanelDidRequestResetView:self]; }

@end
