#include "Command.h"
#include "Scene.h"
#include "Shape.h"
#include <utility>

DrawCommand::DrawCommand(Scene& scene, std::unique_ptr<Shape> shape)
    : _scene(scene), _shape(std::move(shape)) {}

void DrawCommand::execute() {
    _shapePtr = _shape.get();
    _scene.addShape(std::move(_shape));  // 所有权转入 Scene
}

void DrawCommand::undo() {
    // 从 Scene 取回所有权，以便下次 execute() 可以重新使用
    _shape    = _scene.removeShape(_shapePtr);
    _shapePtr = nullptr;
}
