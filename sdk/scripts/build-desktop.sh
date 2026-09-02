#!/bin/sh
# build-desktop.sh — build a PlayOS game for the desktop profile.
#
# Uses the native host compiler, the desktop libplayos shim, and Raylib's
# desktop backend. Same game.c source as the device profile.
#
# Usage:
#   ./build-desktop.sh <source-dir> [build-dir]
set -eu

SRC="${1:?usage: build-desktop.sh <source-dir> [build-dir]}"
BUILD="${2:-build-desktop}"

cmake -S "$SRC" -B "$BUILD" \
    -DCMAKE_BUILD_TYPE=Debug \
    -DPLAYOS_PROFILE=desktop
cmake --build "$BUILD"

echo "==> Desktop build: $BUILD"
