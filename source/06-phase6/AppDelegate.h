#import <Cocoa/Cocoa.h>
#import "ControlPanel.h"
#import "ShapeParamPanel.h"

@class CanvasView;
@class SceneBridge;

@interface AppDelegate : NSObject <NSApplicationDelegate,
                                   ControlPanelDelegate,
                                   ShapeParamPanelDelegate>

@property (strong) NSWindow       *window;
@property (strong) CanvasView     *canvasView;
@property (strong) ControlPanel   *controlPanel;
@property (strong) ShapeParamPanel *paramPanel;
@property (strong) SceneBridge    *bridge;

@end
