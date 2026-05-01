#pragma once
#include <memory>

class Scene;
class Shape;

// 命令模式接口：每次绘图操作封装为可撤销的命令对象
class ICommand {
public:
    virtual ~ICommand() = default;
    virtual void execute() = 0;
    virtual void undo()    = 0;
    virtual const char* description() const = 0;
};

// 具体命令：向场景添加一个图形
class DrawCommand : public ICommand {
public:
    // scene 以引用持有，shape 所有权转入命令
    DrawCommand(Scene& scene, std::unique_ptr<Shape> shape);
    void execute() override;  // 将 shape 移入 Scene
    void undo()    override;  // 将 shape 从 Scene 取回
    const char* description() const override { return "DrawShape"; }
private:
    Scene&                 _scene;
    std::unique_ptr<Shape> _shape;   // undo 后重新持有
    Shape*                 _shapePtr = nullptr;  // execute 后用于定位
};
