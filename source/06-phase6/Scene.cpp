#include "Scene.h"
#include <algorithm>

void Scene::addShape(std::unique_ptr<Shape> shape) {
    _shapes.push_back(std::move(shape));
}

std::unique_ptr<Shape> Scene::removeShape(Shape* ptr) {
    auto it = std::find_if(_shapes.begin(), _shapes.end(),
                           [ptr](const auto& s) { return s.get() == ptr; });
    if (it == _shapes.end()) return nullptr;
    auto shape = std::move(*it);
    _shapes.erase(it);
    return shape;
}

void Scene::clear() {
    _shapes.clear();
}

const std::vector<std::unique_ptr<Shape>>& Scene::shapes() const {
    return _shapes;
}
