#!/bin/sh
# build-device.sh — build a PlayOS game for the device profile (musl).
#
# Usage:
#   PLAYOS_SDK=/path/to/sdk ./build-device.sh <source-dir> [build-dir]
set -eu

SDK="${PLAYOS_SDK:?PLAYOS_SDK must point at the playos-sdk root}"
SRC="${1:?usage: build-device.sh <source-dir> [build-dir]}"
BUILD="${2:-build-device}"

if [ ! -f "$SDK/toolchain/bin/x86_64-buildroot-linux-musl-gcc" ]; then
    echo "error: SDK toolchain not found under $SDK/toolchain" >&2
    echo "Run refdistro scripts/export-sdk.sh first." >&2
    exit 1
fi

cmake -S "$SRC" -B "$BUILD" \
    -DCMAKE_TOOLCHAIN_FILE="$SDK/cmake/playos-toolchain.cmake" \
    -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD"

echo "==> Device build: $BUILD"
file "$BUILD"/game* 2>/dev/null || true
