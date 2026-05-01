#pragma once

class Scene;

// 纯 C++ 渲染器，封装所有 OpenGL 调用，对上层屏蔽 GL 细节
class OpenGLRenderer {
public:
    void setup();  // 初始化 GL 状态，必须在 OpenGL 上下文激活后调用
    void render(const Scene& scene, int viewportW, int viewportH);
private:
    void beginFrame(int w, int h);  // 清屏 + 正投影矩阵
    void endFrame();
};
