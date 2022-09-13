cmake_minimum_required(VERSION 3.10)

project(C_to_Odin)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories("dependencies/include")
link_directories("dependencies/clang")
link_libraries("libclang.lib")

file(GLOB_RECURSE source_list "src/*.cpp")

add_executable(${PROJECT_NAME} ${source_list})
add_custom_command(OUTPUT output Command Assignment6 ARGS "src/main.cpp")