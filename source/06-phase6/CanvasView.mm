#import "CanvasView.h"
#import "SceneBridge.h"

@implementation CanvasView {
    CVDrawingState     _state;
    NSPoint            _worldP1;
    NSMutableArray<NSValue *> *_polyPts;
    NSMutableArray<NSValue *> *_boundaryPts;
    NSPoint            _lastBackingPt;
    NSTrackingArea    *_trackingArea;
    CPShapeTool        _currentTool;
}

+ (NSOpenGLPixelFormat *)createPixelFormat {
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize,    24,
        NSOpenGLPFAAlphaSize,     8,
        NSOpenGLPFADepthSize,    16,
        NSOpenGLPFAStencilSize,   8,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersionLegacy,
        0
    };
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
}

- (void)prepareOpenGL {
    [super prepareOpenGL];
    [[self openGLContext] makeCurrentContext];
    [self setWantsBestResolutionOpenGLSurface:YES];
    [_bridge setup];
    _state        = CVStateSelect;
    _currentTool  = CPShapeToolSelect;
    _polyPts      = [NSMutableArray array];
    _boundaryPts  = [NSMutableArray array];
}

// ── Coordinate helpers ────────────────────────────────────────────

- (NSRect)backingBounds {
    return [self convertRectToBacking:[self bounds]];
}

- (NSPoint)backingPointFromEvent:(NSEvent *)event {
    NSPoint viewPt = [self convertPoint:event.locationInWindow fromView:nil];
    return [self convertPointToBacking:viewPt];
}

- (NSPoint)worldFromBacking:(NSPoint)bp {
    NSRect b = [self backingBounds];
    return [_bridge screenToWorldX:(float)bp.x y:(float)bp.y
                             viewW:(int)b.size.width h:(int)b.size.height];
}

// ── Rendering ─────────────────────────────────────────────────────

- (void)drawRect:(NSRect)dirtyRect {
    [[self openGLContext] makeCurrentContext];
    NSRect backing = [self backingBounds];
    [_bridge renderWithViewportWidth:(int)backing.size.width
                              height:(int)backing.size.height];
    [[self openGLContext] flushBuffer];

    // Notify delegate so label overlay can sync.
    if ([_canvasDelegate respondsToSelector:@selector(canvasViewDidFinishFrame:)])
        [_canvasDelegate canvasViewDidFinishFrame:self];
}

- (void)reshape {
    [super reshape];
    [self setNeedsDisplay:YES];
}

// ── Public interface ───────────────────────────────────────────────

- (void)setDrawingTool:(CPShapeTool)tool {
    _currentTool = tool;
    [_bridge clearPreview];
    [_polyPts removeAllObjects];
    [_boundaryPts removeAllObjects];

    switch (tool) {
        case CPShapeToolSelect:   _state = CVStateSelect;       break;
        case CPShapeToolLine:     _state = CVStateLineFirst;    break;
        case CPShapeToolArc:      _state = CVStateArcCenter;    break;
        case CPShapeToolPolygon:  _state = CVStatePolyDrawing;  break;
        case CPShapeToolElevPt:   _state = CVStateElevPtPlace;  break;
        case CPShapeToolBoundary: _state = CVStateBoundaryDraw; break;
    }
    [self setNeedsDisplay:YES];
}

- (void)performUndo {
    [_bridge clearSelection];
    [_bridge undo];
    [_canvasDelegate canvasViewDidDeselectShape:self];
    [self setNeedsDisplay:YES];
}

// ── Tracking area ──────────────────────────────────────────────────

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_trackingArea) [self removeTrackingArea:_trackingArea];
    _trackingArea = [[NSTrackingArea alloc]
                     initWithRect:self.bounds
                          options:NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                            owner:self
                         userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

// ── Mouse events ───────────────────────────────────────────────────

- (void)mouseDown:(NSEvent *)event {
    if (!_bridge) return;
    NSPoint bp    = [self backingPointFromEvent:event];
    NSPoint world = [self worldFromBacking:bp];
    _lastBackingPt = bp;

    BOOL isDouble = (event.clickCount == 2);
    NSRect bounds = [self backingBounds];
    int w = (int)bounds.size.width, h = (int)bounds.size.height;

    switch (_state) {
        case CVStateSelect: {
            BOOL hit = [_bridge selectAtScreenX:(float)bp.x y:(float)bp.y viewW:w h:h];
            if (hit) {
                NSInteger t    = [_bridge selectedShapeType];
                NSDictionary *props = [_bridge selectedShapeProperties];
                [_canvasDelegate canvasView:self didSelectShapeType:t properties:props];
            } else {
                [_canvasDelegate canvasViewDidDeselectShape:self];
            }
            break;
        }

        case CVStateLineFirst:
            _worldP1 = world;
            [_bridge setPreviewLineFromX:(float)world.x y:(float)world.y
                                    toX:(float)world.x y:(float)world.y];
            _state = CVStateLineDrag;
            break;

        case CVStateLineDrag:
            break;

        case CVStateArcCenter:
            _worldP1 = world;
            [_bridge setPreviewArcCX:(float)world.x cy:(float)world.y radius:0
                            startDeg:0 endDeg:360];
            _state = CVStateArcDrag;
            break;

        case CVStateArcDrag:
            break;

        case CVStatePolyDrawing: {
            if (isDouble && _polyPts.count >= 2) {
                [_bridge clearPreview];
                [_bridge addPolygonWithPoints:_polyPts
                                      strokeR:0.0f g:0.0f b:0.0f
                                        fillR:0.4f g:0.7f b:1.0f
                                    fillStyle:SBFillStyleSolid];
                [_polyPts removeAllObjects];
                _state = CVStatePolyDrawing;
            } else if (!isDouble) {
                [_polyPts addObject:[NSValue valueWithPoint:world]];
                [_bridge setPreviewPolygonVertices:_polyPts];
            }
            break;
        }

        case CVStateElevPtPlace: {
            // Capture world point for use inside the async block.
            NSPoint capturedWorld = world;

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText     = @"输入高程值";
            alert.informativeText = @"请输入该点的高程（米）";
            [alert addButtonWithTitle:@"确定"];
            [alert addButtonWithTitle:@"取消"];

            NSTextField *field = [[NSTextField alloc]
                                  initWithFrame:NSMakeRect(0, 0, 200, 24)];
            field.placeholderString = @"例如：100";
            field.stringValue       = @"";
            alert.accessoryView     = field;

            [alert beginSheetModalForWindow:[self window]
                          completionHandler:^(NSModalResponse resp) {
                if (resp == NSAlertFirstButtonReturn) {
                    float z = [field floatValue];
                    [self->_bridge addElevationPointX:(float)capturedWorld.x
                                                   y:(float)capturedWorld.y
                                           elevation:z];
                    if ([self->_canvasDelegate
                         respondsToSelector:@selector(canvasViewTerrainDidChange:)])
                        [self->_canvasDelegate canvasViewTerrainDidChange:self];
                    [self setNeedsDisplay:YES];
                }
            }];
            break;
        }

        case CVStateBoundaryDraw: {
            if (isDouble && _boundaryPts.count >= 3) {
                [_bridge clearPreview];
                [_bridge setBoundaryVertices:_boundaryPts];
                [_boundaryPts removeAllObjects];
                if ([_canvasDelegate
                     respondsToSelector:@selector(canvasViewTerrainDidChange:)])
                    [_canvasDelegate canvasViewTerrainDidChange:self];
            } else if (!isDouble) {
                [_boundaryPts addObject:[NSValue valueWithPoint:world]];
                [_bridge setPreviewPolygonVertices:_boundaryPts];
            }
            break;
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
    if (!_bridge) return;
    NSPoint bp    = [self backingPointFromEvent:event];
    NSPoint world = [self worldFromBacking:bp];

    if (event.modifierFlags & NSEventModifierFlagOption) {
        float dx = (float)(bp.x - _lastBackingPt.x);
        float dy = (float)(bp.y - _lastBackingPt.y);
        [_bridge panByDX:dx dy:dy];
        _lastBackingPt = bp;
        [self setNeedsDisplay:YES];
        return;
    }

    switch (_state) {
        case CVStateLineDrag:
            [_bridge setPreviewLineFromX:(float)_worldP1.x y:(float)_worldP1.y
                                    toX:(float)world.x y:(float)world.y];
            break;
        case CVStateArcDrag: {
            float dx = (float)(world.x - _worldP1.x);
            float dy = (float)(world.y - _worldP1.y);
            float r  = sqrtf(dx * dx + dy * dy);
            [_bridge setPreviewArcCX:(float)_worldP1.x cy:(float)_worldP1.y radius:r
                            startDeg:0 endDeg:360];
            break;
        }
        default:
            break;
    }
    _lastBackingPt = bp;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    if (!_bridge) return;
    NSPoint world = [self worldFromBacking:[self backingPointFromEvent:event]];

    switch (_state) {
        case CVStateLineDrag: {
            [_bridge clearPreview];
            [_bridge addLineFromX:(float)_worldP1.x y:(float)_worldP1.y
                              toX:(float)world.x y:(float)world.y
                           colorR:0.0f g:0.0f b:1.0f];
            _state = CVStateLineFirst;
            break;
        }
        case CVStateArcDrag: {
            [_bridge clearPreview];
            float dx = (float)(world.x - _worldP1.x);
            float dy = (float)(world.y - _worldP1.y);
            float r  = sqrtf(dx * dx + dy * dy);
            if (r > 2.0f) {
                [_bridge addArcCX:(float)_worldP1.x cy:(float)_worldP1.y radius:r
                         startDeg:0 endDeg:360
                           colorR:1.0f g:0.0f b:0.0f];
            }
            _state = CVStateArcCenter;
            break;
        }
        default:
            break;
    }
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    if (_state == CVStatePolyDrawing) {
        [_polyPts removeAllObjects];
        [_bridge clearPreview];
        [self setNeedsDisplay:YES];
    } else if (_state == CVStateBoundaryDraw) {
        [_boundaryPts removeAllObjects];
        [_bridge clearPreview];
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseMoved:(NSEvent *)event {
    if (!_bridge) return;
    NSPoint world = [self worldFromBacking:[self backingPointFromEvent:event]];
    [_canvasDelegate canvasView:self
              didMoveToWorldX:(float)world.x
                            y:(float)world.y
                    zoomLevel:[_bridge zoomLevel]];
}

- (void)scrollWheel:(NSEvent *)event {
    if (!_bridge) return;
    NSRect  bounds = [self backingBounds];
    NSPoint bp     = [self backingPointFromEvent:event];
    int w = (int)bounds.size.width, h = (int)bounds.size.height;

    float delta  = (float)event.scrollingDeltaY;
    float factor = (delta > 0) ? 1.08f : (1.0f / 1.08f);
    [_bridge zoomBy:factor atScreenX:(float)bp.x y:(float)bp.y viewW:w h:h];

    NSPoint world = [self worldFromBacking:bp];
    [_canvasDelegate canvasView:self
              didMoveToWorldX:(float)world.x
                            y:(float)world.y
                    zoomLevel:[_bridge zoomLevel]];
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder { return YES; }

@end
