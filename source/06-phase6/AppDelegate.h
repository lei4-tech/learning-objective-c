#import <Cocoa/Cocoa.h>
#import "ControlPanel.h"
#import "ShapeParamPanel.h"
#import "CanvasView.h"

@class SceneBridge;

@interface AppDelegate : NSObject <NSApplicationDelegate,
                                   ControlPanelDelegate,
                                   ShapeParamPanelDelegate,
                                   CanvasViewDelegate>

@property (strong) NSWindow        *window;
@property (strong) CanvasView      *canvasView;
@property (strong) ControlPanel    *controlPanel;
@property (strong) ShapeParamPanel *paramPanel;
@property (strong) SceneBridge     *bridge;
@property (strong) NSTextField     *statusLabel;

@end
