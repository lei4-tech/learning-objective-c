#pragma once
#include "TerrainGrid.h"
#include "ContourLine.h"
#include <vector>

class ContourBuilder {
public:
    // Build contour lines from grid at levels: minElev + k*interval for k >= 1 up to maxElev.
    std::vector<ContourLine> build(const TerrainGrid& grid, float interval) const;
};
