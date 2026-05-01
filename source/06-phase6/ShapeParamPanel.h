#import <Cocoa/Cocoa.h>
#import "ControlPanel.h"

@protocol ShapeParamPanelDelegate <NSObject>
- (void)paramPanelDidRequestDraw:(id)panel;
@optional
- (void)paramPanelDidRequestApply:(id)panel;  // invoked in edit mode
@end

@interface ShapeParamPanel : NSView
@property (weak) id<ShapeParamPanelDelegate> delegate;

// Draw mode: show input controls for the given tool.
- (void)switchToTool:(CPShapeTool)tool;

// Edit mode: populate controls with selected shape properties and switch to edit UI.
- (void)showPropertiesForShapeType:(NSInteger)type params:(NSDictionary *)params;

// Return to draw mode (clears selection state).
- (void)switchToDrawMode;

// Returns current field values as a parameter dictionary.
// Draw mode  — same keys as AppDelegate used before (tool, x1/y1/x2/y2/color, etc.)
// Edit mode  — same keys, suitable for updateSelectedShapeProperties:
- (NSDictionary *)currentParams;

@end
