project(02-phase2 LANGUAGES OBJC OBJCXX)

add_executable(02-phase2 main.m)

if(APPLE)
    target_compile_options(02-phase2 PRIVATE -fobjc-arc)
    target_link_libraries(02-phase2 "-framework Foundation")
endif()