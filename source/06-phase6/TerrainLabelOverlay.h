#import <AppKit/AppKit.h>

// Transparent NSView overlay covering the canvas.
// Draws elevation point and contour labels via NSAttributedString.
// Passes all mouse events through to the canvas below (hitTest: returns nil).
@interface TerrainLabelOverlay : NSView

// Each label dict: @{@"x": NSNumber, @"y": NSNumber,
//                   @"text": NSString, @"isContour": NSNumber (BOOL)}
// Coordinates are in the overlay's bounds (NSView logical pixels, origin bottom-left).
- (void)setLabels:(NSArray<NSDictionary *> *)labels;

@end
