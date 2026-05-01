# 06-phase6：GUI + OpenGL + 设计模式综合示例

本阶段是前五个阶段的综合实践，将 C++ 算法层、ObjC++ 桥接层、Objective-C GUI 层结合在一个真实的 macOS 绘图应用中，重点展示三种经典设计模式。

---

## 功能说明

- 用 OpenGL 在画布上绘制三种几何图形：**直线**、**弧线**、**闭合多边形**
- 多边形支持三种填充方式：**纯色**、**斜线纹理**、**网格纹理**
- 支持 **Undo（撤销）**：通过菜单 Cmd+Z 或界面按钮逐步撤销绘图操作
- 支持 **清空**画布

### 界面布局

```
┌─────────────┬──────────────────────────┬────────────────────┐
│  工具面板    │                          │   参数面板          │
│  160pt      │     OpenGL 画布           │   220pt            │
│             │     680pt × 600pt         │                    │
│  [直线]     │                          │  ← 随工具切换       │
│  [弧线]     │                          │  直线：起/终点坐标  │
│  [多边形]   │                          │       颜色          │
│  ─────────  │                          │  弧线：圆心/半径    │
│  [撤销 ⌘Z]  │                          │       起止角度      │
│  [清空]     │                          │  多边形：顶点输入   │
│             │                          │       边色/填充色   │
│             │                          │       填充样式      │
│             │                          │  ──────────────── │
│             │                          │  [绘制] 按钮        │
└─────────────┴──────────────────────────┴────────────────────┘
```

### 多边形顶点输入格式

在顶点输入框中按 `x,y;x,y;...` 格式输入，至少 3 个顶点，例如：

```
100,100;300,100;200,300
```

---

## 架构分层

```
ObjC GUI 层（.m / .mm）
  AppDelegate · CanvasView · ControlPanel · ShapeParamPanel
        │  委托模式（Delegate Protocol）
        ▼
ObjC++ Bridge 层（.mm）
  SceneBridge  ← 将 C++ 接口封装为纯 ObjC 方法，GUI 层不接触任何 C++ 类型
        │
        ▼
C++ Core 层（.cpp / .h，不含任何 ObjC 头文件）
  Shape 继承体系 · ShapeFactory · DrawCommand · CommandManager
  IFillStrategy · Scene · OpenGLRenderer
```

**层次约束**：C++ Core 层的头文件只能 `#include` 标准库；Bridge 层（`.mm`）负责跨越语言边界；GUI 层的 `.m` 文件只 `#import` ObjC 头文件。

---

## 设计模式

### 工厂模式（Factory）

**文件**：`ShapeFactory.h / .cpp`

调用方只需传入参数包（`LineParams` / `ArcParams` / `PolygonParams`），不直接构造具体类。`createPolygon` 内部还调用了 Strategy 工厂来创建填充对象。

```cpp
// 调用方
auto shape = ShapeFactory::createLine({ {100,100}, {300,200}, {0,0,1,1} });
```

### 命令模式（Command）

**文件**：`Command.h / .cpp`、`CommandManager.h / .cpp`

每次绘图操作被封装为 `DrawCommand` 对象，包含对称的 `execute()` 和 `undo()`。`CommandManager` 维护历史栈，Cmd+Z 直接映射到 `undo()`。

```
execute()：shape 所有权从 Command 转入 Scene
undo()   ：shape 所有权从 Scene 归还 Command（可再次 execute）
```

### 策略模式（Strategy）

**文件**：`FillStrategy.h / .cpp`

`ShapePolygon` 持有 `IFillStrategy` 接口指针，`draw()` 只调用 `fill()`，不知道具体算法。三种策略：

| 策略类 | 算法 |
|--------|------|
| `SolidFillStrategy` | `GL_POLYGON` 直接填充 |
| `HatchFillStrategy` | stencil buffer 裁剪 + 平行斜线 |
| `GridFillStrategy` | stencil buffer 裁剪 + 两组斜线 |

`setFillStrategy()` 允许运行时替换算法，是策略模式的核心演示。

### 委托模式（Delegate）

ObjC GUI 层的标准解耦方式，`ControlPanel` 和 `ShapeParamPanel` 均定义了独立的 `@protocol`，AppDelegate 实现两个协议，负责协调各组件。

---

## 关键实现细节

**弧线折线逼近**：`ShapeArc::draw()` 将角度范围等分为 64 段，逐段计算 `cos/sin` 后以 `GL_LINE_STRIP` 绘制。

**填充纹理裁剪**：`HatchFill` / `GridFill` 使用 stencil buffer 将纹理线条严格限制在多边形区域内，需在像素格式中申请 `NSOpenGLPFAStencilSize, 8`。

**C++ ivar in ObjC++**：`SceneBridge.mm` 中直接在 `@implementation {}` 里声明 `Scene`、`CommandManager`、`OpenGLRenderer` 三个 C++ 对象作为实例变量。ARC 管理 ObjC 对象生命周期，C++ 对象的构造/析构由 C++ RAII 处理，两者互不干扰。

**坐标系**：`glOrtho(0, w, 0, h, -1, 1)` 设置正投影，原点在左下角，与 NSView 坐标系一致。画布尺寸以 backing pixel 为单位（`convertRectToBacking:`），支持 Retina 屏幕。

**无 Info.plist 启动**：`main.mm` 中手动创建 `NSApplication`，设置 `NSApplicationActivationPolicyRegular`，不依赖任何 Bundle 配置文件。

---

## 文件清单

| 文件 | 层次 | 职责 |
|------|------|------|
| `Shape.h` | C++ Core | 抽象基类，定义 `Color`、`Point2D`、纯虚 `draw()` |
| `ShapeLine.h/.cpp` | C++ Core | 直线 |
| `ShapeArc.h/.cpp` | C++ Core | 弧线，64 段折线逼近 |
| `ShapePolygon.h/.cpp` | C++ Core | 多边形，持有 `IFillStrategy` |
| `FillStrategy.h/.cpp` | C++ Core | 策略接口 + Solid / Hatch / Grid 三种实现 |
| `ShapeFactory.h/.cpp` | C++ Core | 工厂方法，参数包结构体 |
| `Command.h/.cpp` | C++ Core | `ICommand` 接口 + `DrawCommand` |
| `CommandManager.h/.cpp` | C++ Core | 命令历史栈，`undo()` / `canUndo()` |
| `Scene.h/.cpp` | C++ Core | 图形容器，`addShape` / `removeShape` |
| `OpenGLRenderer.h/.cpp` | C++ Core | 正投影设置，遍历 Scene 调用 `draw()` |
| `SceneBridge.h` | Bridge | 纯 ObjC 接口声明 |
| `SceneBridge.mm` | Bridge | C++ 对象作为 ivar，翻译 ObjC 调用 |
| `main.mm` | GUI | 无 Info.plist 启动入口 |
| `AppDelegate.h/.m` | GUI | 窗口布局、菜单栏、实现两个 Delegate 协议 |
| `CanvasView.h/.mm` | GUI | NSOpenGLView 子类，调用 Bridge 渲染 |
| `ControlPanel.h/.m` | GUI | 工具选择按钮，定义 `ControlPanelDelegate` |
| `ShapeParamPanel.h/.m` | GUI | 参数输入控件，定义 `ShapeParamPanelDelegate` |
