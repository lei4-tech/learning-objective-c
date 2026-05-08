#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SBFillStyle) {
    SBFillStyleSolid = 0,
    SBFillStyleHatch = 1,
    SBFillStyleGrid  = 2,
};

// ObjC++ Bridge：将 C++ 的 Scene / CommandManager / ShapeFactory / OpenGLRenderer
// 封装为纯 ObjC 接口，GUI 层无需了解任何 C++ 细节
@interface SceneBridge : NSObject

// Must be called once the OpenGL context is active.
- (void)setup;

// ── Shape creation (via Command history) ─────────────────────────
- (void)addLineFromX:(float)x1 y:(float)y1
                  toX:(float)x2 y:(float)y2
               colorR:(float)r g:(float)g b:(float)b;

- (void)addArcCX:(float)cx cy:(float)cy
           radius:(float)radius
         startDeg:(float)startDeg
           endDeg:(float)endDeg
           colorR:(float)r g:(float)g b:(float)b;

- (void)addPolygonWithPoints:(NSArray<NSValue *> *)points
                     strokeR:(float)sr g:(float)sg b:(float)sb
                       fillR:(float)fr g:(float)fg b:(float)fb
                   fillStyle:(SBFillStyle)style;

- (void)undo;
- (BOOL)canUndo;
- (void)clearAll;

// ── Selection ────────────────────────────────────────────────────
- (BOOL)selectAtScreenX:(float)sx y:(float)sy viewW:(int)w h:(int)h;
- (void)clearSelection;
- (NSInteger)selectedShapeType;
- (NSDictionary *)selectedShapeProperties;
- (void)updateSelectedShapeProperties:(NSDictionary *)props;

// ── Preview ──────────────────────────────────────────────────────
- (void)setPreviewLineFromX:(float)x1 y:(float)y1 toX:(float)x2 y:(float)y2;
- (void)setPreviewArcCX:(float)cx cy:(float)cy radius:(float)r
               startDeg:(float)sd endDeg:(float)ed;
- (void)setPreviewPolygonVertices:(NSArray<NSValue *> *)pts;
- (void)clearPreview;

// ── Viewport ─────────────────────────────────────────────────────
- (void)zoomBy:(float)factor atScreenX:(float)sx y:(float)sy viewW:(int)w h:(int)h;
- (void)panByDX:(float)dx dy:(float)dy;
- (void)resetViewportWithViewW:(int)w h:(int)h;
- (float)zoomLevel;
- (NSPoint)screenToWorldX:(float)sx y:(float)sy viewW:(int)w h:(int)h;

// ── Terrain / Elevation ──────────────────────────────────────────

// Add a single elevation point; triggers grid+contour recompute on next render.
- (void)addElevationPointX:(float)x y:(float)y elevation:(float)z;
- (void)removeLastElevationPoint;
- (void)clearElevationData;
- (NSInteger)elevationPointCount;

// Terrain display parameters (trigger lazy recompute).
- (void)setContourInterval:(float)interval;
- (void)setColorScheme:(NSInteger)scheme;

// Closed boundary polygon — clips terrain fill, contours, and labels.
- (void)setBoundaryVertices:(NSArray<NSValue *> *)pts;
- (void)clearBoundary;
- (NSInteger)boundaryVertexCount;

// Returns label descriptors for the overlay view (call after render).
// Each dict: @{@"wx": NSNumber, @"wy": NSNumber,
//             @"text": NSString, @"isContour": NSNumber (BOOL)}
- (NSArray<NSDictionary *> *)terrainLabelWorldPositions;

// Convert world coordinates to NSView logical-point coordinates in the canvas.
// w/h: backing-pixel dimensions; s: backingScaleFactor.
- (NSPoint)worldToViewX:(float)wx y:(float)wy viewW:(int)w h:(int)h scaleFactor:(CGFloat)s;

// ── Rendering ────────────────────────────────────────────────────
- (void)renderWithViewportWidth:(int)w height:(int)h;

@end
