project(04-phase41 LANGUAGES OBJC OBJCXX)

file(GLOB SOURCES "*.m" "*.mm")

add_executable(04-phase41 ${SOURCES})

if(APPLE)
    target_compile_options(04-phase41 PRIVATE -fobjc-arc)
    target_link_libraries(04-phase41 "-framework Foundation")
endif()
