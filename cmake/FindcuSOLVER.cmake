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

find_package(CUDAToolkit 10.0 REQUIRED)
get_filename_component(SYCL_BINARY_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
# the OpenCL include file from cuda is opencl 1.1 and it is not compatible with DPC++
# the OpenCL include headers 1.2 onward is required. This is used to bypass NVIDIA OpenCL headers
find_path(OPENCL_INCLUDE_DIR CL/cl.h OpenCL/cl.h 
HINTS 
${OPENCL_INCLUDE_DIR}
${SYCL_BINARY_DIR}/../include/sycl/
)
# this is work around to avoid duplication half creation in both cuda and SYCL
add_compile_definitions(CUDA_NO_HALF)

find_package(Threads REQUIRED)

include(FindPackageHandleStandardArgs)

get_target_property(CUSOLVER_PATH CUDA::cusolver IMPORTED_LOCATION)

find_package_handle_standard_args(cuSOLVER
    REQUIRED_VARS
      CUDAToolkit_INCLUDE_DIRS
      CUDAToolkit_LIBRARY_DIR
      CUDAToolkit_LIBRARY_ROOT
      OPENCL_INCLUDE_DIR
)
if(NOT TARGET ONEMKL::cuSOLVER::cuSOLVER)
  add_library(ONEMKL::cuSOLVER::cuSOLVER SHARED IMPORTED)
  set_target_properties(ONEMKL::cuSOLVER::cuSOLVER PROPERTIES
      IMPORTED_LOCATION ${CUSOLVER_PATH}
      INTERFACE_INCLUDE_DIRECTORIES "${OPENCL_INCLUDE_DIR};${CUDA_TOOLKIT_INCLUDE}"
      INTERFACE_LINK_LIBRARIES "Threads::Threads;${CUDA_CUDA_LIBRARY};${CUDA_LIBRARIES}"
  )

endif()
