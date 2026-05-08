#import <AppKit/AppKit.h>
#import "ControlPanel.h"

@class SceneBridge;

typedef NS_ENUM(NSInteger, CVDrawingState) {
    CVStateSelect        = -1,
    CVStateLineFirst     =  0,
    CVStateLineDrag      =  1,
    CVStateArcCenter     =  2,
    CVStateArcDrag       =  3,
    CVStatePolyDrawing   =  4,
    CVStateElevPtPlace   =  5,  // single click → NSAlert → addElevationPoint
    CVStateBoundaryDraw  =  6,  // like polygon; double-click closes boundary
};

@protocol CanvasViewDelegate <NSObject>
- (void)canvasView:(id)cv didSelectShapeType:(NSInteger)type
        properties:(NSDictionary *)props;
- (void)canvasViewDidDeselectShape:(id)cv;
- (void)canvasView:(id)cv didMoveToWorldX:(float)x y:(float)y zoomLevel:(float)zoom;
@optional
// Called after each drawRect: so the overlay can sync label positions.
- (void)canvasViewDidFinishFrame:(id)cv;
// Called when terrain data changes (elevation point added/removed, boundary set).
- (void)canvasViewTerrainDidChange:(id)cv;
@end

@interface CanvasView : NSOpenGLView

@property (strong) SceneBridge *bridge;
@property (weak)   id<CanvasViewDelegate> canvasDelegate;

- (void)setDrawingTool:(CPShapeTool)tool;
- (void)performUndo;
+ (NSOpenGLPixelFormat *)createPixelFormat;

@end
