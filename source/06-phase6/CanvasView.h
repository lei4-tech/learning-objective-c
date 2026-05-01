#import <AppKit/AppKit.h>
#import "ControlPanel.h"

@class SceneBridge;

typedef NS_ENUM(NSInteger, CVDrawingState) {
    CVStateSelect      = -1,
    CVStateLineFirst   =  0,
    CVStateLineDrag    =  1,
    CVStateArcCenter   =  2,
    CVStateArcDrag     =  3,
    CVStatePolyDrawing =  4,
};

@protocol CanvasViewDelegate <NSObject>
- (void)canvasView:(id)cv didSelectShapeType:(NSInteger)type
        properties:(NSDictionary *)props;
- (void)canvasViewDidDeselectShape:(id)cv;
- (void)canvasView:(id)cv didMoveToWorldX:(float)x y:(float)y zoomLevel:(float)zoom;
@end

@interface CanvasView : NSOpenGLView

@property (strong) SceneBridge *bridge;
@property (weak)   id<CanvasViewDelegate> canvasDelegate;

// Called by AppDelegate when the user clicks a tool button.
- (void)setDrawingTool:(CPShapeTool)tool;

- (void)performUndo;
+ (NSOpenGLPixelFormat *)createPixelFormat;

@end
