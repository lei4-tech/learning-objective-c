project(03-phase31 LANGUAGES OBJC OBJCXX)

file(GLOB SOURCES "*.m" "*.mm")

add_executable(03-phase31 ${SOURCES})

if(APPLE)
    target_compile_options(03-phase31 PRIVATE -fobjc-arc)
    target_link_libraries(03-phase31 "-framework Foundation")
endif()
