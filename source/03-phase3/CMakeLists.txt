project(03-phase3 LANGUAGES OBJC OBJCXX)

add_executable(03-phase3 main.m)

if(APPLE)
    target_compile_options(03-phase3 PRIVATE -fobjc-arc)
    target_link_libraries(03-phase3 "-framework Foundation")
endif()