#pragma once
#include "TerrainGrid.h"
#include "ContourLine.h"
#include "ElevationPoint.h"
#include "ColorScheme.h"
#include <OpenGL/gl.h>
#include <vector>

class TerrainRenderer {
public:
    // Must be called once the OpenGL context is active.
    void setup();
    void cleanup();

    // Upload normalised 8-bit height map from grid data.
    void uploadHeightField(const TerrainGrid& grid);

    // Render terrain fill quad with the active color scheme (shader-based).
    void renderFill(const TerrainGrid& grid, ColorScheme scheme);

    // Render contour lines with fixed-function pipeline.
    void renderContourLines(const std::vector<ContourLine>& contours);

    // Render elevation point markers: cross + centre dot.
    void renderElevationMarkers(const std::vector<ElevationPoint>& pts);

private:
    GLuint compileShader(GLenum type, const char* src);

    GLuint _prog  = 0;
    GLuint _tex   = 0;
    bool   _ready = false;
};
