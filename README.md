# Objective-C 快速入门

面向拥有 C/C++/Java/C# 背景的开发者。核心要点：**Objective-C 不支持类的多继承**，以协议（Protocol）机制替代；内存管理使用 ARC（自动引用计数）；方法调用采用消息传递语法。

项目使用 CMake 组织所有源代码。

## 构建

```bash
cmake -S . -B build
cmake --build build
# 产物输出到 bin/
```

## 学习路径

### 阶段一：基础语法 — [source/01-phase1/](source/01-phase1/)

- `NSString`、基本类型变量声明
- `if/else` 条件分支、`for` 循环
- `NSLog` 格式化输出（`%@` 对象占位符、`%d` 整数占位符）
- `@"..."` 与 C 字符串 `"..."` 的区别

### 阶段二：面向对象 — [source/02-phase2/](source/02-phase2/)

单文件版本。涵盖：

- `@interface` / `@implementation` 接口与实现分离
- `@property` 属性声明
- `[[ClassName alloc] init]` 对象创建（`alloc` 分配内存，`init` 初始化）
- `[object message]` 消息传递语法
- 协议（Protocol）基础：`@protocol`、多协议遵守 `<P1, P2>`

多文件版本 — [source/02-phase21/](source/02-phase21/)：将协议和类拆分为独立 `.h`/`.m` 文件，CMakeLists.txt 使用 `file(GLOB)` 收集源文件。

### 阶段三：协议进阶 — [source/03-phase3/](source/03-phase3/)

单文件版本。在阶段二基础上新增：

- `@required` / `@optional` 修饰协议方法
- `respondsToSelector:` 运行时检查可选方法是否已实现

多文件版本 — [source/03-phase31/](source/03-phase31/)：协议头文件独立，演示真实工程中协议的组织方式。

### 阶段四：Category 与 ARC — [source/04-phase4/](source/04-phase4/)

单文件版本。涵盖：

- **Category（分类）**：`@interface ClassName (CategoryName)` 为已有类外挂方法，无需源码、无需继承
- **ARC 内存管理**：`strong` 强引用持有对象，`weak` 弱引用在对象销毁后自动置 `nil`
- 循环引用（Retain Cycle）及其解决方案：互相引用的两端，一端用 `weak`

多文件版本 — [source/04-phase41/](source/04-phase41/)：Category 按 `ClassName+CategoryName.h/.m` 惯例命名；`Boss` 与 `Employee` 互相引用时，用 `@class` 前向声明代替 `#import` 打破头文件循环依赖。

### 阶段五：Objective-C++ 混编 — [source/05-phase5/](source/05-phase5/)

- 入口文件使用 `.mm` 后缀，同一文件中同时使用 C++ 标准库（`std::cout`）与 ObjC 对象
- ObjC 类定义仍保留在 `.h`/`.m` 文件中，由 `.mm` 文件调用
- 适用场景：在已有 C++ 工程中逐步接入 ObjC/Cocoa API，或反向在 ObjC 工程中复用 C++ 库

### 阶段六：综合实践 — [source/06-phase6/](source/06-phase6/)

macOS OpenGL 绘图应用，综合运用前五阶段全部知识，重点展示四种设计模式。

**功能**：
- 鼠标点击/拖拽绘制直线、弧线、闭合多边形（含纯色/斜线/网格三种填充）
- 点击图形选中后，右侧属性面板切换为编辑模式，修改参数即时刷新外观
- 滚轮缩放（以鼠标为中心）、Option+拖拽平移、重置视图
- 状态栏实时显示鼠标世界坐标与缩放比例；画布显示点阵网格

**架构**（三层严格隔离）：

```
ObjC GUI 层 (.m/.mm)     AppDelegate · CanvasView · ControlPanel · ShapeParamPanel
        ↓ ObjC 消息
ObjC++ Bridge 层 (.mm)   SceneBridge（C++ ivar，纯 ObjC 接口）
        ↓ C++ 调用
C++ Core 层 (.h/.cpp)    Shape · Viewport · Scene · OpenGLRenderer
                         ShapeFactory · Command · CommandManager · IFillStrategy
```

**设计模式**：

| 模式 | 位置 | 要点 |
|------|------|------|
| 工厂 | `ShapeFactory` | 调用方传参数包 struct，不直接构造具体类 |
| 命令 | `DrawCommand` + `CommandManager` | `execute`/`undo` 对称；`unique_ptr<Shape>` 所有权在 Command ↔ Scene 间转移 |
| 策略 | `IFillStrategy` + 三实现 | `ShapePolygon::draw()` 只调用接口；stencil buffer 裁剪纹理线 |
| 委托 | 三个 `@protocol` | `ControlPanelDelegate`、`ShapeParamPanelDelegate`、`CanvasViewDelegate` |
