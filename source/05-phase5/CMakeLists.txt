project(05-phase5 LANGUAGES OBJC OBJCXX)

file(GLOB SOURCES "*.m" "*.mm")

add_executable(05-phase5 ${SOURCES})

if(APPLE)
    target_compile_options(05-phase5 PRIVATE -fobjc-arc)
    target_link_libraries(05-phase5 "-framework Foundation")
endif()
