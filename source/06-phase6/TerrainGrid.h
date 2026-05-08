#pragma once
#include "ElevationPoint.h"
#include <vector>

class TerrainGrid {
public:
    // Domain bounding box in world coordinates (set by compute).
    float x0 = 0, y0 = 0, x1 = 1, y1 = 1;

    // Compute IDW height field from scattered elevation points.
    // gridW/gridH: number of grid columns/rows.
    void compute(const std::vector<ElevationPoint>& pts, int gridW = 256, int gridH = 256);

    float at(int col, int row) const;
    float minElev() const { return _minE; }
    float maxElev() const { return _maxE; }
    int   gridW()   const { return _gridW; }
    int   gridH()   const { return _gridH; }

private:
    std::vector<float> _data;
    float _minE = 0, _maxE = 1;
    int   _gridW = 0, _gridH = 0;
};
