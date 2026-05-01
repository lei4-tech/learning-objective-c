#include "FillStrategy.h"
#include <OpenGL/gl.h>
#include <cmath>
#include <algorithm>

// ── 内部辅助函数 ──────────────────────────────────────────────────

// 将多边形区域写入 stencil=1，随后只允许在该区域内绘制
static void beginStencilClip(const std::vector<Point2D>& v) {
    glEnable(GL_STENCIL_TEST);
    glStencilFunc(GL_ALWAYS, 1, 0xFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);  // 不写颜色缓冲
    glBegin(GL_TRIANGLE_FAN);
    for (auto& p : v) glVertex2f(p.x, p.y);
    glEnd();
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    glStencilFunc(GL_EQUAL, 1, 0xFF);                     // 仅在 stencil==1 处通过
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
}

// 清除 stencil，恢复正常绘制状态
static void endStencilClip() {
    glDisable(GL_STENCIL_TEST);
    glClear(GL_STENCIL_BUFFER_BIT);
}

static void getBBox(const std::vector<Point2D>& v,
                    float& minX, float& minY, float& maxX, float& maxY) {
    minX = minY =  1e9f;
    maxX = maxY = -1e9f;
    for (auto& p : v) {
        minX = std::min(minX, p.x); minY = std::min(minY, p.y);
        maxX = std::max(maxX, p.x); maxY = std::max(maxY, p.y);
    }
}

// 在包围盒内生成一组平行线（angle 为方向角，spacing 为间距）
static void drawParallelLines(float cx, float cy, float diag,
                               float angleDeg, float spacing, const Color& c) {
    float angleRad = angleDeg * static_cast<float>(M_PI) / 180.0f;
    float cosA = cosf(angleRad), sinA = sinf(angleRad);

    glColor4f(c.r, c.g, c.b, c.a);
    glBegin(GL_LINES);
    for (float t = -diag; t <= diag; t += spacing) {
        // t 是垂直于 angle 方向的偏移；沿 angle 方向延伸 diag
        float ox = -sinA * t, oy = cosA * t;
        glVertex2f(cx + ox - cosA * diag, cy + oy - sinA * diag);
        glVertex2f(cx + ox + cosA * diag, cy + oy + sinA * diag);
    }
    glEnd();
}

// ── SolidFillStrategy ──────────────────────────────────────────────

void SolidFillStrategy::fill(const std::vector<Point2D>& v, const Color& c) const {
    glColor4f(c.r, c.g, c.b, c.a);
    glBegin(GL_POLYGON);
    for (auto& p : v) glVertex2f(p.x, p.y);
    glEnd();
}

// ── HatchFillStrategy ─────────────────────────────────────────────

HatchFillStrategy::HatchFillStrategy(float spacing, float angleDeg)
    : _spacing(spacing), _angleDeg(angleDeg) {}

void HatchFillStrategy::fill(const std::vector<Point2D>& v, const Color& c) const {
    beginStencilClip(v);

    float minX, minY, maxX, maxY;
    getBBox(v, minX, minY, maxX, maxY);
    float cx   = (minX + maxX) * 0.5f;
    float cy   = (minY + maxY) * 0.5f;
    float diag = sqrtf((maxX - minX) * (maxX - minX) + (maxY - minY) * (maxY - minY));

    drawParallelLines(cx, cy, diag, _angleDeg, _spacing, c);

    endStencilClip();
}

// ── GridFillStrategy ──────────────────────────────────────────────

GridFillStrategy::GridFillStrategy(float spacing) : _spacing(spacing) {}

void GridFillStrategy::fill(const std::vector<Point2D>& v, const Color& c) const {
    beginStencilClip(v);

    float minX, minY, maxX, maxY;
    getBBox(v, minX, minY, maxX, maxY);
    float cx   = (minX + maxX) * 0.5f;
    float cy   = (minY + maxY) * 0.5f;
    float diag = sqrtf((maxX - minX) * (maxX - minX) + (maxY - minY) * (maxY - minY));

    drawParallelLines(cx, cy, diag,  45.0f, _spacing, c);  // 45° 斜线
    drawParallelLines(cx, cy, diag, 135.0f, _spacing, c);  // 135° 斜线

    endStencilClip();
}
