cmake_minimum_required(VERSION 3.23)
project(missing_dep_one_source LANGUAGES CXX)

if(NOT DEFINED ENV{A_KIND} OR "$ENV{A_KIND}" STREQUAL "")
  message(FATAL_ERROR "Environment variable A_KIND must be set to SHARED, STATIC, or OBJECT.")
endif()
set(A_KIND $ENV{A_KIND})

if(NOT DEFINED ENV{B_KIND} OR "$ENV{B_KIND}" STREQUAL "")
  message(FATAL_ERROR "Environment variable B_KIND must be set to SHARED, STATIC, or OBJECT.")
endif()
set(B_KIND $ENV{B_KIND})

add_library(A ${A_KIND} src/a.cpp)
target_compile_features(A PUBLIC cxx_std_17)
target_include_directories(A PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_library(B ${B_KIND} src/b.cpp)
target_compile_features(B PUBLIC cxx_std_17)
target_include_directories(B PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# Keep the dependency from A -> B, but intentionally omit B -> A.
target_link_libraries(A PUBLIC B)

add_executable(main src/main.cpp)
target_compile_features(main PRIVATE cxx_std_17)
target_link_libraries(main PRIVATE A B)
