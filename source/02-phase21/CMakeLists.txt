project(02-phase21 LANGUAGES OBJC OBJCXX)

# GLOB 自动收集目录下所有 .m / .mm 源文件，新增文件后需重新运行 cmake
file(GLOB SOURCES "*.m" "*.mm")

add_executable(02-phase21 ${SOURCES})

if(APPLE)
    target_compile_options(02-phase21 PRIVATE -fobjc-arc)
    target_link_libraries(02-phase21 "-framework Foundation")
endif()
