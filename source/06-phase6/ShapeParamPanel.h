#import <Cocoa/Cocoa.h>
#import "ControlPanel.h"

@protocol ShapeParamPanelDelegate <NSObject>
- (void)paramPanelDidRequestDraw:(id)panel;
@optional
- (void)paramPanelDidRequestApply:(id)panel;
- (void)paramPanelDidRequestClearTerrain:(id)panel;
- (void)paramPanelDidRequestClearBoundary:(id)panel;
- (void)paramPanelDidChangeContourInterval:(id)panel interval:(float)v;
- (void)paramPanelDidChangeColorScheme:(id)panel scheme:(NSInteger)s;
@end

@interface ShapeParamPanel : NSView
@property (weak) id<ShapeParamPanelDelegate> delegate;

- (void)switchToTool:(CPShapeTool)tool;
- (void)showPropertiesForShapeType:(NSInteger)type params:(NSDictionary *)params;
- (void)switchToDrawMode;
- (NSDictionary *)currentParams;

// Update elevation point / boundary vertex counts shown in terrain sub-views.
- (void)updateElevationPointCount:(NSInteger)count;
- (void)updateBoundaryVertexCount:(NSInteger)count;

@end
