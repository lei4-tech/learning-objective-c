#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, CPShapeTool) {
    CPShapeToolSelect  = -1,
    CPShapeToolLine    =  0,
    CPShapeToolArc     =  1,
    CPShapeToolPolygon =  2,
};

@protocol ControlPanelDelegate <NSObject>
- (void)controlPanel:(id)panel didSelectTool:(CPShapeTool)tool;
- (void)controlPanelDidRequestUndo:(id)panel;
- (void)controlPanelDidRequestClear:(id)panel;
- (void)controlPanelDidRequestResetView:(id)panel;
@end

@interface ControlPanel : NSView
@property (weak) id<ControlPanelDelegate> delegate;
@end
