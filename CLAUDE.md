# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Configure and build all phases
cmake -S . -B build && cmake --build build

# Build a single phase
cmake --build build --target 06-phase6

# Run a phase (all executables land in bin/)
./bin/06-phase6
./bin/01-phase1
```

Executables go to `bin/`, libraries to `lib/`. The root `CMakeLists.txt` requires CMake ≥ 3.30 and sets `CMAKE_OBJCXX_STANDARD 14`.

## Project Structure

Each learning phase lives in `source/<phase-dir>/` as an independent CMake target. Phases numbered `XX-phaseY` with a suffix like `21`/`31`/`41` are multi-file rewrites of the preceding single-file phase (e.g. `02-phase21` splits `02-phase2` into separate `.h`/`.m` files).

To add a new phase: create `source/<new-dir>/CMakeLists.txt` and append `add_subdirectory(<new-dir>)` to `source/CMakeLists.txt`.

## CMake Rules (apply to every phase)

- Declare `LANGUAGES OBJC OBJCXX` (add `CXX` when `.cpp` files are present)
- Multi-file phases use `file(GLOB SOURCES "*.m" "*.mm" "*.cpp")` — re-run `cmake -S . -B build` after adding files
- Always inside `if(APPLE)`: `target_compile_options(... PRIVATE -fobjc-arc)` and `target_link_libraries(... "-framework Foundation")`
- Phase 06 additionally links Cocoa and OpenGL, and defines `GL_SILENCE_DEPRECATION`

## Code Conventions

- Pure Objective-C: `.m`; mixing C++: `.mm`; pure C++: `.cpp`
- No manual `retain`/`release` — ARC only
- Category files follow `ClassName+CategoryName.h/.m`
- When `.h` files would create circular imports, use `@class Foo` forward declaration in the header and `#import "Foo.h"` in the `.m`

## 06-phase6 Architecture

The most complex phase. Three strict layers — a file may only reference layers below it:

```
ObjC GUI (.m / .mm)          AppDelegate · CanvasView · ControlPanel · ShapeParamPanel
        ↓ ObjC messages only
ObjC++ Bridge (.mm)          SceneBridge  (C++ ivars, pure ObjC interface)
        ↓ C++ calls
C++ Core (.h / .cpp)         Shape · ShapeFactory · Command · CommandManager
                             IFillStrategy · Scene · OpenGLRenderer
```

**C++ Core** headers must never `#import` any ObjC framework. **Bridge** `.mm` files may `#include` C++ and `#import` ObjC simultaneously. **GUI** `.m` files import only ObjC headers — they never see C++ types.

Key design patterns in 06-phase6:
- **Factory** — `ShapeFactory::create*()` takes parameter structs (`LineParams` etc.), never constructs shapes directly
- **Command** — `DrawCommand` owns the `unique_ptr<Shape>`; `execute()` moves it into `Scene`, `undo()` moves it back; `CommandManager` holds the undo stack
- **Strategy** — `IFillStrategy` with `SolidFill`, `HatchFill`, `GridFill`; hatch/grid use stencil buffer clipping

OpenGL setup notes: coordinate origin is bottom-left (`glOrtho(0,w,0,h,-1,1)`); canvas renders at backing-pixel resolution via `convertRectToBacking:`; pixel format must request `NSOpenGLPFAStencilSize, 8` for hatch/grid fills.

## Git Commit Convention

Format: `<type>: <subject>` (Conventional Commits)

| type | when |
|------|------|
| `feat` | new phase or new example |
| `fix` | correct example code |
| `docs` | README or comment changes |
| `chore` | build config changes |

Subject language follows the conversation context — Chinese for most phases, English was used for the 06-phase6 initial commit.
