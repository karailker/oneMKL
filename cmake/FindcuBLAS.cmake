#==========================================================================
#  Copyright (C) Codeplay Software Limited
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  For your convenience, a copy of the License has been included in this
#  repository.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#=========================================================================

# Use the CUDAToolkit package instead of FindCUDA
find_package(CUDAToolkit 10.0 REQUIRED)

# Obtain the SYCL binary directory from the CXX compiler
get_filename_component(SYCL_BINARY_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)

# The OpenCL include file from CUDA is OpenCL 1.1 and is not compatible with DPC++
# OpenCL include headers 1.2 onward are required. This bypasses NVIDIA OpenCL headers
find_path(OPENCL_INCLUDE_DIR CL/cl.h OpenCL/cl.h
  HINTS
    ${OPENCL_INCLUDE_DIR}
    ${SYCL_BINARY_DIR}/../include/sycl/
    ${SYCL_BINARY_DIR}/../../include/sycl/
)

# Workaround to avoid duplicate half creation in both CUDA and SYCL
add_compile_definitions(CUDA_NO_HALF)

# Find Threads package
find_package(Threads REQUIRED)

# Include the module to handle standard arguments
include(FindPackageHandleStandardArgs)

get_target_property(CUBLAS_PATH CUDA::cublas IMPORTED_LOCATION)

if(NOT TARGET ONEMKL::cuBLAS::cuBLAS)
  add_library(ONEMKL::cuBLAS::cuBLAS SHARED IMPORTED)

  if(USE_ADD_SYCL_TO_TARGET_INTEGRATION)
    # Handle standard arguments for cuBLAS integration with SYCL
    find_package_handle_standard_args(cuBLAS
      REQUIRED_VARS
        CUDAToolkit_INCLUDE_DIRS
        CUDAToolkit_LIBRARY_DIR
        CUDAToolkit_LIBRARY_ROOT
    )
    set_target_properties(ONEMKL::cuBLAS::cuBLAS PROPERTIES
      IMPORTED_LOCATION ${CUBLAS_PATH}
      INTERFACE_INCLUDE_DIRECTORIES "${CUDAToolkit_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "Threads::Threads;CUDA::cuda_driver;CUDA::cudart;CUDA::cublas"
    )
  else()
    # Handle standard arguments for cuBLAS without SYCL
    find_package_handle_standard_args(cuBLAS
      REQUIRED_VARS
        CUDAToolkit_INCLUDE_DIRS
        CUDAToolkit_LIBRARY_DIR
        CUDAToolkit_LIBRARY_ROOT
        OPENCL_INCLUDE_DIR
    )
    set_target_properties(ONEMKL::cuBLAS::cuBLAS PROPERTIES
      IMPORTED_LOCATION ${CUBLAS_PATH}
      INTERFACE_INCLUDE_DIRECTORIES "${OPENCL_INCLUDE_DIR};${CUDAToolkit_INCLUDE_DIRS}"
      INTERFACE_LINK_LIBRARIES "Threads::Threads;CUDA::cuda_driver;CUDA::cudart;CUDA::cublas"
    )
  endif()
endif()
