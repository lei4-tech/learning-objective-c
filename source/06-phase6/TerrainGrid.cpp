#include "TerrainGrid.h"
#include <algorithm>
#include <limits>
#include <cmath>

void TerrainGrid::compute(const std::vector<ElevationPoint>& pts, int gridW, int gridH) {
    if (pts.empty()) return;

    _gridW = gridW;
    _gridH = gridH;

    // Compute bounding box with 10% padding.
    float minX = pts[0].pos.x, maxX = pts[0].pos.x;
    float minY = pts[0].pos.y, maxY = pts[0].pos.y;
    for (auto& p : pts) {
        minX = std::min(minX, p.pos.x);
        maxX = std::max(maxX, p.pos.x);
        minY = std::min(minY, p.pos.y);
        maxY = std::max(maxY, p.pos.y);
    }
    // Add 10% padding, handle degenerate case where all points coincide.
    float padX = std::max((maxX - minX) * 0.1f, 50.0f);
    float padY = std::max((maxY - minY) * 0.1f, 50.0f);
    x0 = minX - padX;  x1 = maxX + padX;
    y0 = minY - padY;  y1 = maxY + padY;

    _data.resize((size_t)gridW * gridH);

    float dx = (x1 - x0) / (gridW - 1);
    float dy = (y1 - y0) / (gridH - 1);

    _minE =  std::numeric_limits<float>::max();
    _maxE = -std::numeric_limits<float>::max();

    for (int row = 0; row < gridH; row++) {
        for (int col = 0; col < gridW; col++) {
            float wx = x0 + col * dx;
            float wy = y0 + row * dy;

            float sumW = 0.0f, sumWZ = 0.0f;
            bool exact = false;

            for (auto& p : pts) {
                float ddx = wx - p.pos.x;
                float ddy = wy - p.pos.y;
                float d2 = ddx * ddx + ddy * ddy;
                if (d2 < 1e-6f) {
                    // Exactly on a point — use its elevation directly.
                    _data[row * gridW + col] = p.elevation;
                    exact = true;
                    break;
                }
                float w = 1.0f / d2;
                sumW  += w;
                sumWZ += w * p.elevation;
            }

            if (!exact) {
                _data[row * gridW + col] = sumWZ / sumW;
            }

            float v = _data[row * gridW + col];
            _minE = std::min(_minE, v);
            _maxE = std::max(_maxE, v);
        }
    }

    // Ensure min != max to avoid divide-by-zero in normalisation.
    if (_maxE - _minE < 1e-6f) {
        _minE -= 0.5f;
        _maxE += 0.5f;
    }
}

float TerrainGrid::at(int col, int row) const {
    return _data[row * _gridW + col];
}
