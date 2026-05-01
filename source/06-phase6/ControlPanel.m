#import "ControlPanel.h"

@implementation ControlPanel

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButtons];
    }
    return self;
}

- (void)setupButtons {
    // 工具选择按钮（纵向排列）
    struct { NSString *title; SEL action; } tools[] = {
        { @"直线",   @selector(selectLine:) },
        { @"弧线",   @selector(selectArc:) },
        { @"多边形", @selector(selectPolygon:) },
    };

    CGFloat y = self.bounds.size.height - 50;
    for (int i = 0; i < 3; i++) {
        NSButton *btn = [NSButton buttonWithTitle:tools[i].title
                                           target:self
                                           action:tools[i].action];
        btn.frame = NSMakeRect(10, y, 140, 30);
        [self addSubview:btn];
        y -= 38;
    }

    // 分隔线（用 NSBox）
    NSBox *sep = [[NSBox alloc] initWithFrame:NSMakeRect(10, y + 8, 140, 1)];
    sep.boxType = NSBoxSeparator;
    [self addSubview:sep];
    y -= 20;

    // 操作按钮
    struct { NSString *title; SEL action; } ops[] = {
        { @"撤销 (⌘Z)", @selector(requestUndo:) },
        { @"清空",       @selector(requestClear:) },
    };
    for (int i = 0; i < 2; i++) {
        NSButton *btn = [NSButton buttonWithTitle:ops[i].title
                                           target:self
                                           action:ops[i].action];
        btn.frame = NSMakeRect(10, y, 140, 30);
        [self addSubview:btn];
        y -= 38;
    }
}

- (void)selectLine:(id)sender    { [_delegate controlPanel:self didSelectTool:CPShapeToolLine]; }
- (void)selectArc:(id)sender     { [_delegate controlPanel:self didSelectTool:CPShapeToolArc]; }
- (void)selectPolygon:(id)sender { [_delegate controlPanel:self didSelectTool:CPShapeToolPolygon]; }
- (void)requestUndo:(id)sender   { [_delegate controlPanelDidRequestUndo:self]; }
- (void)requestClear:(id)sender  { [_delegate controlPanelDidRequestClear:self]; }

// 绘制左侧分隔边框
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor separatorColor] setFill];
    NSRectFill(NSMakeRect(self.bounds.size.width - 1, 0, 1, self.bounds.size.height));
}

@end
