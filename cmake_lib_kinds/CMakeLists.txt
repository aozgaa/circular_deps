cmake_minimum_required(VERSION 3.23)
project(circular_deps LANGUAGES CXX)

if(NOT DEFINED ENV{A_KIND} OR "$ENV{A_KIND}" STREQUAL "")
  message(FATAL_ERROR "Environment variable A_KIND must be set to SHARED, STATIC, or OBJECT.")
endif()
set(A_KIND $ENV{A_KIND})

if(NOT DEFINED ENV{B_KIND} OR "$ENV{B_KIND}" STREQUAL "")
  message(FATAL_ERROR "Environment variable B_KIND must be set to SHARED, STATIC, or OBJECT.")
endif()
set(B_KIND $ENV{B_KIND})

add_library(A ${A_KIND} src/a.cpp)
target_sources(A
  PUBLIC
    FILE_SET a_headers TYPE HEADERS
      BASE_DIRS include
      FILES include/a.hpp
)

add_library(B ${B_KIND} src/b.cpp)
target_sources(B
  PUBLIC
    FILE_SET b_headers TYPE HEADERS
      BASE_DIRS include
      FILES include/b.hpp
)

target_link_libraries(A PUBLIC B)
target_link_libraries(B PUBLIC A)

add_executable(main src/main.cpp)
target_link_libraries(main PRIVATE A B)
