project(06-phase6 LANGUAGES OBJC OBJCXX CXX)

# GLOB 收集所有 .m / .mm / .cpp 源文件，新增文件后需重新运行 cmake
file(GLOB SOURCES "*.m" "*.mm" "*.cpp")

add_executable(06-phase6 ${SOURCES})

if(APPLE)
    target_compile_options(06-phase6 PRIVATE -fobjc-arc)

    # 全局消除 OpenGL deprecated 警告（macOS 10.14+ 已废弃但仍可用）
    target_compile_definitions(06-phase6 PRIVATE GL_SILENCE_DEPRECATION)

    target_link_libraries(06-phase6
        "-framework Foundation"
        "-framework Cocoa"
        "-framework OpenGL"
    )
endif()
