#pragma once

enum class ShapeType { Line, Arc, Polygon };

// 颜色和二维坐标定义在此处，供所有 Shape 子类共享
struct Color   { float r, g, b, a; };
struct Point2D { float x, y; };

// 所有图形的抽象基类，纯虚 draw() 由 OpenGLRenderer 调用
class Shape {
public:
    virtual ~Shape() = default;
    virtual ShapeType type() const = 0;
    virtual void draw() const = 0;
    // Hit test in world coordinates; tol is pick tolerance in world units.
    virtual bool containsPoint(Point2D p, float tol) const = 0;
};
