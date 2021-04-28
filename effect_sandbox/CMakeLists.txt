cmake_minimum_required(VERSION 3.10)

project(effect_sandbox)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT(CMAKE_BUILD_TYPE STREQUAL "Debug"))
    add_compile_options(-O3)
endif()

link_directories("/usr/local/lib")

set(3RD_SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/3rd)

if(MSVC)
    include(${CMAKE_CURRENT_LIST_DIR}/cmake/opencv-windows.cmake)
else()
    include(${CMAKE_CURRENT_LIST_DIR}/cmake/opencv-desktop.cmake)
endif()

file(GLOB VOCHI_SOURCES ${CMAKE_CURRENT_LIST_DIR}/*.cpp)
file(GLOB VOCHI_HEADERS ${CMAKE_CURRENT_LIST_DIR}/*.h)


include_directories(${CMAKE_CURRENT_LIST_DIR})

add_executable(effects_cli ${VOCHI_SOURCES} ${VOCHI_HEADERS})
target_link_libraries(effects_cli ${OPENCV_LIBS})

#MINMAX are evil
target_compile_definitions(effects_cli PRIVATE -DMIN=std::min)
target_compile_definitions(effects_cli PRIVATE -DMAX=std::max)

if(APPLE)
    target_link_libraries(effects_cli "-framework Foundation" "-framework AppKit")
endif()

add_custom_target(createAssetsBundle ALL
                   COMMAND ${CMAKE_COMMAND} -E copy_directory
                       ${CMAKE_CURRENT_LIST_DIR}/../frames ${CMAKE_CURRENT_BINARY_DIR}/frames)

