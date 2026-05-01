#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, CPShapeTool) {
    CPShapeToolLine    = 0,
    CPShapeToolArc     = 1,
    CPShapeToolPolygon = 2,
};

// 委托模式：ControlPanel 通过协议向外传递用户操作，不直接持有其他视图
@protocol ControlPanelDelegate <NSObject>
- (void)controlPanel:(id)panel didSelectTool:(CPShapeTool)tool;
- (void)controlPanelDidRequestUndo:(id)panel;
- (void)controlPanelDidRequestClear:(id)panel;
@end

@interface ControlPanel : NSView
@property (weak) id<ControlPanelDelegate> delegate;
@end
