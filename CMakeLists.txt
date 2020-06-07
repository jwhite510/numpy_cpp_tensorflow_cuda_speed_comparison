cmake_minimum_required(VERSION 3.0)
project(cudacompare)

add_definitions("-std=c++11")

set(CMAKE_BUILD_TYPE Debug)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -ccbin=g++-6")
# set(CUDA_NVCC_FLAGS "${CUDA_NVCC_FLAGS} -ccbin=g++-6")
# message(${CMAKE_CUDA_FLAGS})
set(CUDA_HOST_COMPILER "g++-6")

find_package(CUDA REQUIRED)
# add_executable(a.out main.cpp)
# target_link_libraries(a.out ${OpenCV_LIBS})
# cuda_add_executable(
# 	add_cuda
# 	src/main.cu
# 	)

cuda_add_library( fdtd SHARED src/fdtdwrapper.cu)


