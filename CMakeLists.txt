cmake_minimum_required(VERSION 3.30)

project(learning-objective-cpp LANGUAGES OBJC OBJCXX)


# Require Obejctive-C++ 14
set(CMAKE_OBJCXX_STANDARD 14)
set(CMAKE_OBJCXX_STANDARD_REQUIRED ON)


# Set the output directory for the executable
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib)


# add subprojects
add_subdirectory(source)
