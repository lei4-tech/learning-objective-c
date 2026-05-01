#pragma once
#include "Shape.h"
#include <algorithm>

// Header-only viewport: stores zoom level and camera position (world coord at screen centre).
// Provides coordinate conversion helpers used by OpenGLRenderer and SceneBridge.
struct Viewport {
    float zoom    = 1.0f;
    float cameraX = 0.0f;
    float cameraY = 0.0f;

    void initCenter(int w, int h) {
        cameraX = w * 0.5f;
        cameraY = h * 0.5f;
    }

    // Convert backing-pixel screen position to world coordinate.
    Point2D screenToWorld(float sx, float sy, int w, int h) const {
        return { cameraX + (sx - w * 0.5f) / zoom,
                 cameraY + (sy - h * 0.5f) / zoom };
    }

    // Zoom centred on cursor: the world point under the cursor stays fixed.
    void zoomBy(float factor, float sx, float sy, int w, int h) {
        Point2D pivot = screenToWorld(sx, sy, w, h);
        zoom *= factor;
        zoom = std::max(0.05f, std::min(50.0f, zoom));
        cameraX = pivot.x - (sx - w * 0.5f) / zoom;
        cameraY = pivot.y - (sy - h * 0.5f) / zoom;
    }

    void panBy(float dx, float dy) {
        cameraX -= dx / zoom;
        cameraY -= dy / zoom;
    }

    void reset(int w, int h) {
        zoom = 1.0f;
        initCenter(w, h);
    }
};
