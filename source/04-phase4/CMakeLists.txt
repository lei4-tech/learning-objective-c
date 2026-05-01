project(04-phase4 LANGUAGES OBJC OBJCXX)

add_executable(04-phase4 main.m)

if(APPLE)
    target_compile_options(04-phase4 PRIVATE -fobjc-arc)
    target_link_libraries(04-phase4 "-framework Foundation")
endif()
