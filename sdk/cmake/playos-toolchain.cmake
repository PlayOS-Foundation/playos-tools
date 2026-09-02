# PlayOS device toolchain (musl)

# The PlayOS device ABI is musl. Set PLAYOS_SDK to the SDK root (the directory
# containing include/, lib/, toolchain/, cmake/, pkgconfig/).
if(NOT DEFINED ENV{PLAYOS_SDK})
    message(FATAL_ERROR "PLAYOS_SDK must point at the playos-sdk root")
endif()

set(PLAYOS_SDK "$ENV{PLAYOS_SDK}")
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(TOOLCHAIN_PREFIX "${PLAYOS_SDK}/toolchain")

set(CMAKE_C_COMPILER   "${TOOLCHAIN_PREFIX}/bin/x86_64-buildroot-linux-musl-gcc")
set(CMAKE_CXX_COMPILER "${TOOLCHAIN_PREFIX}/bin/x86_64-buildroot-linux-musl-g++")

# Only search the musl sysroot for libraries/headers; never host /usr.
set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_PREFIX}/x86_64-buildroot-linux-musl/sysroot")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Device binaries must link musl; add the SDK lib dir for libplayos/libraylib.
list(APPEND CMAKE_PREFIX_PATH "${PLAYOS_SDK}")
link_directories("${PLAYOS_SDK}/lib")
