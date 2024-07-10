cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

file(GLOB rnoh_amap3d_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_amap3d SHARED ${rnoh_amap3d_SRC})
target_include_directories(rnoh_amap3d PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(rnoh_amap3d PUBLIC rnoh)