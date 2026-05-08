#import "TerrainLabelOverlay.h"

@implementation TerrainLabelOverlay {
    NSArray<NSDictionary *> *_labels;
}

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _labels = @[];
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor clearColor].CGColor;
    }
    return self;
}

- (void)setLabels:(NSArray<NSDictionary *> *)labels {
    _labels = labels ? [labels copy] : @[];
    [self setNeedsDisplay:YES];
}

- (BOOL)isOpaque { return NO; }

// Pass all mouse events through to the canvas view below.
- (NSView *)hitTest:(NSPoint)aPoint { return nil; }

- (void)drawRect:(NSRect)dirtyRect {
    if (_labels.count == 0) return;

    for (NSDictionary *lbl in _labels) {
        CGFloat x     = [lbl[@"x"] doubleValue];
        CGFloat y     = [lbl[@"y"] doubleValue];
        BOOL isCont   = [lbl[@"isContour"] boolValue];
        NSString *text = lbl[@"text"];
        if (!text) continue;

        NSFont  *font      = isCont
            ? [NSFont systemFontOfSize:8]
            : [NSFont boldSystemFontOfSize:10];
        NSColor *textColor = isCont
            ? [NSColor colorWithRed:0.1 green:0.1 blue:0.45 alpha:1.0]
            : [NSColor colorWithWhite:0.15 alpha:1.0];

        NSDictionary *attrs = @{
            NSFontAttributeName:            font,
            NSForegroundColorAttributeName: textColor,
        };

        NSSize sz    = [text sizeWithAttributes:attrs];
        NSRect bgRct = NSMakeRect(x - 2, y - 1, sz.width + 4, sz.height + 2);

        // Semi-transparent white pill background.
        [[NSColor colorWithWhite:1.0 alpha:0.72] setFill];
        NSBezierPath *pill = [NSBezierPath bezierPathWithRoundedRect:bgRct
                                                             xRadius:3 yRadius:3];
        [pill fill];

        [text drawAtPoint:NSMakePoint(x, y) withAttributes:attrs];
    }
}

@end
