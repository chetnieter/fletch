if (NOT fletch_BUILD_CXX11)
  message(FATAL_ERROR "CXX11 must be enabled to use pybind11")
endif()

if (PYTHON_EXECUTABLE)
  set(pybind_PYTHON_ARGS -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE})
endif()

# If a patch file exists, apply it
set (pybind11_patch ${fletch_SOURCE_DIR}/Patches/pybind11/${pybind11_version})
if (EXISTS ${pybind11_patch})
  set(pybind11_PATCH_COMMAND ${CMAKE_COMMAND}
      -Dpybind11_patch:PATH=${pybind11_patch}
      -Dpybind11_source:PATH=${fletch_BUILD_PREFIX}/src/pybind11
      -P ${pybind11_patch}/Patch.cmake
    )
endif()

ExternalProject_Add(pybind11
  URL ${pybind11_url}
  URL_MD5 ${pybind11_md5}
  ${COMMON_EP_ARGS}
  ${COMMON_CMAKE_EP_ARGS}
  PATCH_COMMAND ${pybind11_PATCH_COMMAND}
  CMAKE_ARGS
    ${COMMON_CMAKE_ARGS}
    -DCMAKE_CXX_STANDARD=17
    # PYTHON_EXECUTABLE addded to cover when it's installed in nonstandard loc.
    # But don't pass if python isn't enabled. It will prevent pybind from finding it.
    ${pybind_PYTHON_ARGS}
    -DPYBIND11_TEST:BOOL=OFF # To remove dependencies; build can still be tested manually
  )

fletch_external_project_force_install(PACKAGE pybind11)

set(pybind11_ROOT "${fletch_BUILD_INSTALL_PREFIX}" CACHE PATH "" FORCE)
file(APPEND ${fletch_CONFIG_INPUT} "
################################
# pybind11
################################
set(pybind11_ROOT \${fletch_ROOT})
set(pybind11_DIR \${fletch_ROOT}/share/cmake/pybind11/)
set(fletch_ENABLED_pybind11 TRUE)
")
