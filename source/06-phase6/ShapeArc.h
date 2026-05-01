#pragma once
#include "Shape.h"

class ShapeArc : public Shape {
public:
    ShapeArc(float cx, float cy, float radius,
             float startDeg, float endDeg, Color color);
    ShapeType type() const override { return ShapeType::Arc; }
    void draw() const override;
    bool containsPoint(Point2D p, float tol) const override;

    float cx()       const { return _cx;       }
    float cy()       const { return _cy;       }
    float radius()   const { return _radius;   }
    float startDeg() const { return _startDeg; }
    float endDeg()   const { return _endDeg;   }
    Color color()    const { return _color;    }

    void setCX(float v)       { _cx       = v; }
    void setCY(float v)       { _cy       = v; }
    void setRadius(float v)   { _radius   = v; }
    void setStartDeg(float v) { _startDeg = v; }
    void setEndDeg(float v)   { _endDeg   = v; }
    void setColor(Color c)    { _color    = c; }

private:
    float _cx, _cy, _radius, _startDeg, _endDeg;
    Color _color;
    static constexpr int kSegments = 64;
};
