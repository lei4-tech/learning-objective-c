# 06-phase6：GUI + OpenGL + 设计模式综合示例

本阶段是前五个阶段的综合实践，将 C++ 算法层、ObjC++ 桥接层、Objective-C GUI 层结合在一个真实的 macOS 绘图应用中，重点展示四种经典设计模式。

---

## 功能说明

### 绘图
- **鼠标绘制**：在画布上直接点击/拖拽创建图形
  - 直线：点击起点，拖拽到终点后松开
  - 弧线：点击圆心，拖拽确定半径后松开
  - 多边形：逐点单击，双击闭合；右键取消
- **面板绘制**：在右侧参数面板中输入精确坐标后点击"绘制"
- 支持三种几何图形：**直线**、**弧线**、**闭合多边形**
- 多边形支持三种填充方式：**纯色**、**斜线纹理**、**网格纹理**

### 选择与属性编辑
- 选择"选择"工具，点击画布上的图形进行选中（蓝色包围框高亮）
- 选中后，右侧参数面板切换为**编辑模式**，显示该图形的当前属性
- 修改参数后点击"应用"即时刷新图形外观

### 画布交互
- **滚轮缩放**：滚动鼠标滚轮，以鼠标位置为中心缩放画布
- **Option + 拖拽**：平移画布
- **重置视图**：点击左侧"重置视图"按钮，恢复 100% 缩放并居中
- **状态栏**：底部实时显示鼠标世界坐标和当前缩放比例（如 `x: 320   y: 240 · 125%`）
- **点阵网格**：白色画布上显示浅色点阵，随缩放同步变换

### 历史管理
- **Undo（撤销）**：Cmd+Z 或左侧"撤销"按钮逐步撤销绘图操作
- **清空**：清除所有图形

### 界面布局

```
┌─────────────┬──────────────────────────────┬──────────────────────┐
│  工具面板    │                              │   参数面板            │
│  160pt       │     OpenGL 画布              │   220pt              │
│              │     白色背景 + 点阵网格       │                      │
│  TOOLS       │                              │  绘制 · 直线          │
│  [选择]      │                              │  ─────────────────   │
│  [直线]      │                              │  起点 X  [100    ]   │
│  [弧线]      │                              │  起点 Y  [100    ]   │
│  [多边形]    │                              │  ...                 │
│  ─────────   │                              │  [绘制] / [应用]     │
│  ACTIONS     │                              │                      │
│  [撤销 ⌘Z]   │                              │  编辑 · 直线（选中后）│
│  [清空]      │                              │  ─────────────────   │
│  [重置视图]  │                              │  ...属性字段...       │
│              ├──────────────────────────────┤  [应用]              │
│              │  x: 320   y: 240 · 100%      │                      │
└─────────────┴──────────────────────────────┴──────────────────────┘
                  状态栏 24pt
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
  Shape 继承体系 · Viewport · ShapeFactory · DrawCommand · CommandManager
  IFillStrategy · Scene · OpenGLRenderer
```

**层次约束**：C++ Core 层头文件只能 `#include` 标准库；Bridge 层（`.mm`）负责跨越语言边界；GUI 层的 `.m` 文件只 `#import` ObjC 头文件。

---

## 设计模式

### 工厂模式（Factory）

**文件**：`ShapeFactory.h / .cpp`

调用方只需传入参数包（`LineParams` / `ArcParams` / `PolygonParams`），不直接构造具体类。`createPolygon` 内部还调用了 Strategy 工厂来创建填充对象。

### 命令模式（Command）

**文件**：`Command.h / .cpp`、`CommandManager.h / .cpp`

每次绘图操作被封装为 `DrawCommand` 对象，包含对称的 `execute()` 和 `undo()`。`CommandManager` 维护历史栈，Cmd+Z 直接映射到 `undo()`。

### 策略模式（Strategy）

**文件**：`FillStrategy.h / .cpp`

`ShapePolygon` 持有 `IFillStrategy` 接口指针，`draw()` 只调用 `fill()`，不知道具体算法。运行时支持通过 `setFillStrategyByName()` 替换算法。

| 策略类 | 算法 |
|--------|------|
| `SolidFillStrategy` | `GL_POLYGON` 直接填充 |
| `HatchFillStrategy` | stencil buffer 裁剪 + 平行斜线 |
| `GridFillStrategy` | stencil buffer 裁剪 + 两组斜线 |

### 委托模式（Delegate）

ObjC GUI 层的标准解耦方式，三个独立的 `@protocol`：

| 协议 | 声明位置 | 实现者 |
|------|----------|--------|
| `ControlPanelDelegate` | `ControlPanel.h` | `AppDelegate` |
| `ShapeParamPanelDelegate` | `ShapeParamPanel.h` | `AppDelegate` |
| `CanvasViewDelegate` | `CanvasView.h` | `AppDelegate` |

---

## 关键实现细节

**Viewport（视口）**：`Viewport.h` 是 header-only C++ struct，存储 `zoom`、`cameraX/Y`。`glOrtho` 以 camera 为中心构建投影矩阵；`zoomBy()` 以鼠标位置为 pivot 保证鼠标下的世界点不动：
```
pivot = screenToWorld(cursor)
zoom  *= factor
cameraX = pivot.x - (cursor.x - w/2) / zoom
```

**Hit Test**：`Shape` 新增纯虚 `containsPoint(Point2D, float tol)`：
- `ShapeLine`：点到线段距离 ≤ tol
- `ShapeArc`：点到圆心距离 ≈ radius（误差 ≤ tol）且角度在弧线范围内
- `ShapePolygon`：边缘 proximity（同 Line 距离算法）或 ray-casting 点在多边形内

**鼠标绘制状态机**（`CanvasView.mm`）：

```
工具        初始状态           交互
直线   CVStateLineFirst   → mouseDown 记录 p1 → CVStateLineDrag
                         → mouseDragged 更新 preview line
                         → mouseUp 提交 addLine → CVStateLineFirst
弧线   CVStateArcCenter  → mouseDown 记录圆心 → CVStateArcDrag
                         → mouseDragged 计算半径更新 preview arc
                         → mouseUp 提交 addArc → CVStateArcCenter
多边形 CVStatePolyDrawing → mouseDown 追加顶点，更新 preview polygon
                         → double-click 闭合 addPolygon
                         → rightMouseDown 取消
选择   CVStateSelect     → mouseDown hitTest → 选中/取消选中 → 通知 delegate
```

**Option+拖拽平移**：`mouseDragged:` 检测 `NSEventModifierFlagOption`，将 backing-pixel 位移传给 `panByDX:dy:`。

**坐标系**：鼠标事件给出 NSView 逻辑点 → `convertPointToBacking:` 转为 backing 像素 → `screenToWorld()` 转为世界坐标，全程与 OpenGL 投影一致，支持 Retina 屏幕。

**弧线折线逼近**：`ShapeArc::draw()` 将角度范围等分为 64 段，以 `GL_LINE_STRIP` 绘制。

**填充纹理裁剪**：`HatchFill` / `GridFill` 使用 stencil buffer，需在像素格式中申请 `NSOpenGLPFAStencilSize, 8`。

**无 Info.plist 启动**：`main.mm` 中手动创建 `NSApplication`，设置 `NSApplicationActivationPolicyRegular`。

---

## 文件清单

| 文件 | 层次 | 职责 |
|------|------|------|
| `Shape.h` | C++ Core | 抽象基类；定义 `Color`、`Point2D`；纯虚 `draw()`、`containsPoint()` |
| `ShapeLine.h/.cpp` | C++ Core | 直线；点到线段距离 hit test；getters / setters |
| `ShapeArc.h/.cpp` | C++ Core | 弧线；radial + angle-range hit test；getters / setters |
| `ShapePolygon.h/.cpp` | C++ Core | 多边形；ray-casting hit test；`setFillStrategyByName()` |
| `Viewport.h` | C++ Core | Header-only；zoom / cameraX/Y；`screenToWorld`、`zoomBy`、`panBy` |
| `FillStrategy.h/.cpp` | C++ Core | 策略接口 + Solid / Hatch / Grid 三种实现 |
| `ShapeFactory.h/.cpp` | C++ Core | 工厂方法，参数包结构体 |
| `Command.h/.cpp` | C++ Core | `ICommand` 接口 + `DrawCommand` |
| `CommandManager.h/.cpp` | C++ Core | 命令历史栈，`undo()` / `canUndo()` |
| `Scene.h/.cpp` | C++ Core | 图形容器；新增 `hitTest()` |
| `OpenGLRenderer.h/.cpp` | C++ Core | 视口投影（Viewport）；网格；选中高亮；preview 渲染 |
| `SceneBridge.h` | Bridge | 纯 ObjC 接口；新增选择、属性编辑、preview、视口控制 API |
| `SceneBridge.mm` | Bridge | C++ ivar；持有 `Shape* _selectedShape` 和 `PreviewState` |
| `main.mm` | GUI | 无 Info.plist 启动入口 |
| `AppDelegate.h/.m` | GUI | 1200×700 窗口；实现三个 Delegate 协议；状态栏标签 |
| `CanvasView.h/.mm` | GUI | 鼠标绘制状态机；滚轮缩放；Option+拖拽平移；`CanvasViewDelegate` |
| `ControlPanel.h/.m` | GUI | 深色面板（DarkAqua）；选择/绘图工具按钮；重置视图 |
| `ShapeParamPanel.h/.m` | GUI | 绘制/编辑双模式；`showPropertiesForShapeType:params:` |

---

## 编译与运行

```bash
cmake -S . -B build && cmake --build build --target 06-phase6
./bin/06-phase6
```

## 测试步骤

1. **鼠标绘制直线**：点击"直线"工具 → 在画布上拖拽 → 松开后直线出现
2. **鼠标绘制弧线**：点击"弧线"工具 → 点击圆心拖拽半径 → 松开后弧线出现
3. **鼠标绘制多边形**：点击"多边形"工具 → 逐点单击添加顶点 → 双击闭合
4. **面板绘制**：在右侧参数面板输入坐标和颜色 → 点击"绘制"
5. **选择与编辑**：点击"选择"工具 → 点击已有图形 → 右侧面板切换为编辑模式 → 修改参数 → 点击"应用"
6. **缩放**：滚动鼠标滚轮，状态栏缩放比例变化，画布以鼠标为中心缩放
7. **平移**：按住 Option 键拖拽画布
8. **重置视图**：点击"重置视图"，恢复 100% 缩放
9. **撤销**：Cmd+Z 或点击"撤销"，最后一个图形消失
10. **清空**：点击"清空"，所有图形消失
