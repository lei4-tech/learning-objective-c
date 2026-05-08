#pragma once
#include "Shape.h"
#include <vector>
#include <utility>

struct ContourLine {
    float elevation;
    std::vector<std::pair<Point2D, Point2D>> segments;
    Point2D labelPos;   // world-space centroid of segment midpoints
};
