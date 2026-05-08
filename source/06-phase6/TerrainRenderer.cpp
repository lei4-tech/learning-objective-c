#include "TerrainRenderer.h"
#include <OpenGL/gl.h>
#include <cmath>
#include <vector>
#include <cstdio>

// ── GLSL 1.20 Shaders ────────────────────────────────────────────────────────

static const char* kVertSrc = R"GLSL(
#version 120
void main() {
    gl_Position  = gl_ModelViewProjectionMatrix * gl_Vertex;
    gl_TexCoord[0] = gl_MultiTexCoord0;
}
)GLSL";

static const char* kFragSrc = R"GLSL(
#version 120
uniform sampler2D uHeightMap;
uniform int       uScheme;

vec4 rainbow(float t) {
    if (t < 0.25)      return mix(vec4(0.0,0.0,1.0,0.85), vec4(0.0,1.0,1.0,0.85), t*4.0);
    else if (t < 0.5)  return mix(vec4(0.0,1.0,1.0,0.85), vec4(0.0,1.0,0.0,0.85), (t-0.25)*4.0);
    else if (t < 0.75) return mix(vec4(0.0,1.0,0.0,0.85), vec4(1.0,1.0,0.0,0.85), (t-0.5)*4.0);
    else               return mix(vec4(1.0,1.0,0.0,0.85), vec4(1.0,0.0,0.0,0.85), (t-0.75)*4.0);
}

vec4 terrain(float t) {
    if (t < 0.25)      return mix(vec4(0.1,0.4,0.1,0.85), vec4(0.5,0.7,0.3,0.85), t*4.0);
    else if (t < 0.5)  return mix(vec4(0.5,0.7,0.3,0.85), vec4(0.7,0.6,0.3,0.85), (t-0.25)*4.0);
    else if (t < 0.75) return mix(vec4(0.7,0.6,0.3,0.85), vec4(0.5,0.4,0.3,0.85), (t-0.5)*4.0);
    else               return mix(vec4(0.5,0.4,0.3,0.85), vec4(1.0,1.0,1.0,0.85), (t-0.75)*4.0);
}

vec4 blueRed(float t) {
    return mix(vec4(0.0,0.3,0.9,0.85), vec4(0.9,0.1,0.0,0.85), t);
}

vec4 grayscale(float t) {
    float v = t * 0.85 + 0.1;
    return vec4(v, v, v, 0.85);
}

void main() {
    float h = texture2D(uHeightMap, gl_TexCoord[0].xy).r;
    if      (uScheme == 0) gl_FragColor = rainbow(h);
    else if (uScheme == 1) gl_FragColor = terrain(h);
    else if (uScheme == 2) gl_FragColor = blueRed(h);
    else                   gl_FragColor = grayscale(h);
}
)GLSL";

// ── Internal helpers ──────────────────────────────────────────────────────────

GLuint TerrainRenderer::compileShader(GLenum type, const char* src) {
    GLuint sh = glCreateShader(type);
    glShaderSource(sh, 1, &src, nullptr);
    glCompileShader(sh);
    GLint ok = 0;
    glGetShaderiv(sh, GL_COMPILE_STATUS, &ok);
    if (!ok) {
        char buf[512];
        glGetShaderInfoLog(sh, sizeof(buf), nullptr, buf);
        fprintf(stderr, "[TerrainRenderer] shader error: %s\n", buf);
    }
    return sh;
}

// ── Public API ────────────────────────────────────────────────────────────────

void TerrainRenderer::setup() {
    if (_ready) return;

    GLuint vert = compileShader(GL_VERTEX_SHADER,   kVertSrc);
    GLuint frag = compileShader(GL_FRAGMENT_SHADER, kFragSrc);

    _prog = glCreateProgram();
    glAttachShader(_prog, vert);
    glAttachShader(_prog, frag);
    glLinkProgram(_prog);

    GLint ok = 0;
    glGetProgramiv(_prog, GL_LINK_STATUS, &ok);
    if (!ok) {
        char buf[512];
        glGetProgramInfoLog(_prog, sizeof(buf), nullptr, buf);
        fprintf(stderr, "[TerrainRenderer] link error: %s\n", buf);
    }

    glDeleteShader(vert);
    glDeleteShader(frag);

    glGenTextures(1, &_tex);
    glBindTexture(GL_TEXTURE_2D, _tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);

    _ready = true;
}

void TerrainRenderer::cleanup() {
    if (_prog) { glDeleteProgram(_prog); _prog = 0; }
    if (_tex)  { glDeleteTextures(1, &_tex); _tex = 0; }
    _ready = false;
}

void TerrainRenderer::uploadHeightField(const TerrainGrid& grid) {
    if (!_ready || grid.gridW() == 0) return;

    float range = grid.maxElev() - grid.minElev();

    std::vector<unsigned char> buf((size_t)grid.gridW() * grid.gridH());
    for (int row = 0; row < grid.gridH(); row++) {
        for (int col = 0; col < grid.gridW(); col++) {
            float n = (grid.at(col, row) - grid.minElev()) / range;
            buf[row * grid.gridW() + col] = (unsigned char)(n * 255.0f + 0.5f);
        }
    }

    glBindTexture(GL_TEXTURE_2D, _tex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE,
                 grid.gridW(), grid.gridH(), 0,
                 GL_LUMINANCE, GL_UNSIGNED_BYTE, buf.data());
    glBindTexture(GL_TEXTURE_2D, 0);
}

void TerrainRenderer::renderFill(const TerrainGrid& grid, ColorScheme scheme) {
    if (!_ready) return;

    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _tex);
    glUseProgram(_prog);

    GLint locTex    = glGetUniformLocation(_prog, "uHeightMap");
    GLint locScheme = glGetUniformLocation(_prog, "uScheme");
    glUniform1i(locTex,    0);
    glUniform1i(locScheme, (GLint)scheme);

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f, 0.0f); glVertex2f(grid.x0, grid.y0);
        glTexCoord2f(1.0f, 0.0f); glVertex2f(grid.x1, grid.y0);
        glTexCoord2f(1.0f, 1.0f); glVertex2f(grid.x1, grid.y1);
        glTexCoord2f(0.0f, 1.0f); glVertex2f(grid.x0, grid.y1);
    glEnd();

    glUseProgram(0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);
}

void TerrainRenderer::renderContourLines(const std::vector<ContourLine>& contours) {
    glLineWidth(1.2f);
    glColor4f(0.25f, 0.25f, 0.25f, 0.85f);
    glBegin(GL_LINES);
    for (auto& cl : contours) {
        for (auto& seg : cl.segments) {
            glVertex2f(seg.first.x,  seg.first.y);
            glVertex2f(seg.second.x, seg.second.y);
        }
    }
    glEnd();
    glLineWidth(1.5f);  // restore default
}

void TerrainRenderer::renderElevationMarkers(const std::vector<ElevationPoint>& pts) {
    const float armLen = 8.0f;

    // Centre dots.
    glPointSize(6.0f);
    glColor4f(0.8f, 0.2f, 0.0f, 1.0f);
    glBegin(GL_POINTS);
    for (auto& p : pts) glVertex2f(p.pos.x, p.pos.y);
    glEnd();
    glPointSize(1.0f);

    // Cross arms.
    glLineWidth(1.5f);
    glBegin(GL_LINES);
    for (auto& p : pts) {
        glVertex2f(p.pos.x - armLen, p.pos.y);
        glVertex2f(p.pos.x + armLen, p.pos.y);
        glVertex2f(p.pos.x, p.pos.y - armLen);
        glVertex2f(p.pos.x, p.pos.y + armLen);
    }
    glEnd();
}
