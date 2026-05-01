project(01-phase1 LANGUAGES OBJC OBJCXX)

add_executable(01-phase1 main.m)

if(APPLE)
    target_compile_options(01-phase1 PRIVATE -fobjc-arc)
    target_link_libraries(01-phase1 "-framework Foundation")
endif()