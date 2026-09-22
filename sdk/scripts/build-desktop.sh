#!/bin/sh
# build-desktop.sh — build a PlayOS game for the desktop profile.
#
# Native host compiler, the SDK's desktop raylib (default X11/Wayland backend) and
# the host libplayos shim. Same game source as the device profile; see
# playos-spec/src/sdk-desktop-shim.md.
#
# Usage:
#   PLAYOS_SDK=/path/to/playos-sdk ./build-desktop.sh <source-dir> [build-dir]
set -eu

SDK="${PLAYOS_SDK:?PLAYOS_SDK must point at the playos-sdk root}"
SRC="${1:?usage: build-desktop.sh <source-dir> [build-dir]}"
BUILD="${2:-build-desktop}"

# The desktop profile needs no cross toolchain: the host compiler builds it.
DESKTOP="$SDK/desktop"

if [ ! -f "$DESKTOP/install/lib/libplayos.so" ] || [ ! -f "$DESKTOP/raylib/lib/libraylib.so" ]; then
    echo "error: desktop artifacts missing under $DESKTOP" >&2
    echo "Run refdistro scripts/export-sdk.sh first (it builds both profiles)." >&2
    exit 1
fi

# The sample's CMakeLists is not modified: these are the paths it already looks in.
# The rpath is set so the built game runs without LD_LIBRARY_PATH.
RPATH="$DESKTOP/install/lib;$DESKTOP/raylib/lib"

cmake -S "$SRC" -B "$BUILD" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DPLAYOS_PROFILE=desktop \
    -DPLAYOS_PLATFORM_API_DIR="$DESKTOP" \
    -DRAYLIB_DIR="$DESKTOP/raylib" \
    -DCMAKE_BUILD_RPATH="$RPATH" \
    -DCMAKE_INSTALL_RPATH="$RPATH"
cmake --build "$BUILD"

echo "==> Desktop build: $BUILD"
BIN="$BUILD/bin/game"
[ -x "$BIN" ] || BIN="$BUILD/game"
if [ -x "$BIN" ]; then
    file "$BIN"
    echo "    (desktop ABI: glibc, against the SDK's raylib and libplayos)"
else
    echo "warning: no game binary found under $BUILD" >&2
fi
