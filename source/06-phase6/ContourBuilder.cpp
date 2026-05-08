#include "ContourBuilder.h"
#include <cmath>

// ── Marching Squares ─────────────────────────────────────────────────────────
// Corner bit order: bit0 = BL, bit1 = BR, bit2 = TR, bit3 = TL
// Edge IDs used internally: 0=Bottom, 1=Right, 2=Top, 3=Left

static Point2D interpEdge(float va, float vb,
                           float xa, float ya, float xb, float yb,
                           float threshold)
{
    float t = (threshold - va) / (vb - va);
    return { xa + t * (xb - xa), ya + t * (yb - ya) };
}

std::vector<ContourLine> ContourBuilder::build(const TerrainGrid& grid, float interval) const {
    std::vector<ContourLine> result;
    if (grid.gridW() < 2 || grid.gridH() < 2 || interval <= 0.0f) return result;

    float minE = grid.minElev();
    float maxE = grid.maxElev();

    // Contour levels: first level above minE, up to (but not including) maxE.
    float firstLevel = std::ceil(minE / interval) * interval;
    if (firstLevel <= minE) firstLevel += interval;

    std::vector<float> levels;
    for (float lev = firstLevel; lev < maxE; lev += interval)
        levels.push_back(lev);

    if (levels.empty()) return result;

    float dx = (grid.x1 - grid.x0) / (grid.gridW() - 1);
    float dy = (grid.y1 - grid.y0) / (grid.gridH() - 1);

    for (float threshold : levels) {
        ContourLine contour;
        contour.elevation = threshold;

        for (int row = 0; row < grid.gridH() - 1; row++) {
            for (int col = 0; col < grid.gridW() - 1; col++) {
                float bl = grid.at(col,     row);
                float br = grid.at(col + 1, row);
                float tr = grid.at(col + 1, row + 1);
                float tl = grid.at(col,     row + 1);

                int idx = 0;
                if (bl > threshold) idx |= 1;
                if (br > threshold) idx |= 2;
                if (tr > threshold) idx |= 4;
                if (tl > threshold) idx |= 8;

                if (idx == 0 || idx == 15) continue;

                // World coordinates of cell corners.
                float wx0 = grid.x0 + col       * dx;
                float wx1 = grid.x0 + (col + 1) * dx;
                float wy0 = grid.y0 + row       * dy;
                float wy1 = grid.y0 + (row + 1) * dy;

                // Interpolated crossing point on each edge.
                auto ptB = [&]{ return interpEdge(bl, br, wx0, wy0, wx1, wy0, threshold); };
                auto ptR = [&]{ return interpEdge(br, tr, wx1, wy0, wx1, wy1, threshold); };
                auto ptT = [&]{ return interpEdge(tl, tr, wx0, wy1, wx1, wy1, threshold); };
                auto ptL = [&]{ return interpEdge(bl, tl, wx0, wy0, wx0, wy1, threshold); };

                switch (idx) {
                    case  1: contour.segments.push_back({ptB(), ptL()}); break;
                    case  2: contour.segments.push_back({ptB(), ptR()}); break;
                    case  3: contour.segments.push_back({ptR(), ptL()}); break;
                    case  4: contour.segments.push_back({ptR(), ptT()}); break;
                    case  5: // saddle: BL+TR above
                        contour.segments.push_back({ptB(), ptL()});
                        contour.segments.push_back({ptR(), ptT()});
                        break;
                    case  6: contour.segments.push_back({ptB(), ptT()}); break;
                    case  7: contour.segments.push_back({ptT(), ptL()}); break;
                    case  8: contour.segments.push_back({ptT(), ptL()}); break;
                    case  9: contour.segments.push_back({ptB(), ptT()}); break;
                    case 10: // saddle: TL+BR above
                        contour.segments.push_back({ptB(), ptR()});
                        contour.segments.push_back({ptT(), ptL()});
                        break;
                    case 11: contour.segments.push_back({ptR(), ptT()}); break;
                    case 12: contour.segments.push_back({ptR(), ptL()}); break;
                    case 13: contour.segments.push_back({ptB(), ptR()}); break;
                    case 14: contour.segments.push_back({ptB(), ptL()}); break;
                }
            }
        }

        // Label position: centroid of all segment midpoints.
        if (!contour.segments.empty()) {
            float sx = 0, sy = 0;
            for (auto& seg : contour.segments) {
                sx += (seg.first.x + seg.second.x) * 0.5f;
                sy += (seg.first.y + seg.second.y) * 0.5f;
            }
            float n = (float)contour.segments.size();
            contour.labelPos = { sx / n, sy / n };
            result.push_back(std::move(contour));
        }
    }

    return result;
}
