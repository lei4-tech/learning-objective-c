#import <Cocoa/Cocoa.h>
#import "ControlPanel.h"
#import "SceneBridge.h"

@protocol ShapeParamPanelDelegate <NSObject>
- (void)paramPanelDidRequestDraw:(id)panel;
@end

@interface ShapeParamPanel : NSView
@property (weak) id<ShapeParamPanelDelegate> delegate;

// 切换到对应工具的参数控件
- (void)switchToTool:(CPShapeTool)tool;

// 返回当前工具的参数字典，由 AppDelegate 传给 SceneBridge
// 直线：@{@"tool", @"x1", @"y1", @"x2", @"y2", @"color"}
// 弧线：@{@"tool", @"cx", @"cy", @"radius", @"startDeg", @"endDeg", @"color"}
// 多边形：@{@"tool", @"pointsString", @"strokeColor", @"fillColor", @"fillStyle"}
- (NSDictionary *)currentParams;
@end
