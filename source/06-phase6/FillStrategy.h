#pragma once
#include "Shape.h"
#include <vector>

// 策略模式接口：填充算法可在运行时替换
class IFillStrategy {
public:
    virtual ~IFillStrategy() = default;
    virtual void fill(const std::vector<Point2D>& vertices, const Color& fillColor) const = 0;
    virtual const char* name() const = 0;
};

// 策略一：纯色填充（GL_POLYGON）
class SolidFillStrategy : public IFillStrategy {
public:
    void fill(const std::vector<Point2D>& v, const Color& c) const override;
    const char* name() const override { return "Solid"; }
};

// 策略二：斜线纹理（stencil buffer 裁剪 + 平行斜线）
class HatchFillStrategy : public IFillStrategy {
public:
    explicit HatchFillStrategy(float spacing = 10.0f, float angleDeg = 45.0f);
    void fill(const std::vector<Point2D>& v, const Color& c) const override;
    const char* name() const override { return "Hatch"; }
private:
    float _spacing, _angleDeg;
};

// 策略三：网格纹理（两组斜线叠加）
class GridFillStrategy : public IFillStrategy {
public:
    explicit GridFillStrategy(float spacing = 10.0f);
    void fill(const std::vector<Point2D>& v, const Color& c) const override;
    const char* name() const override { return "Grid"; }
private:
    float _spacing;
};
