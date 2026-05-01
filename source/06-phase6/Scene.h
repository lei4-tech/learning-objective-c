#pragma once
#include "Shape.h"
#include <vector>
#include <memory>

// 场景容器：持有所有图形的所有权
class Scene {
public:
    void addShape(std::unique_ptr<Shape> shape);
    // 移除并返回所有权（供 DrawCommand::undo 使用）
    std::unique_ptr<Shape> removeShape(Shape* ptr);
    void clear();
    const std::vector<std::unique_ptr<Shape>>& shapes() const;
private:
    std::vector<std::unique_ptr<Shape>> _shapes;
};
