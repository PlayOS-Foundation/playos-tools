#!/bin/sh
# build-emulator.sh — build a PlayOS game for the device profile and boot it in
# the PlayOS emulator (S15-T7).
#
# The device build is the same musl artifact that would ship to hardware; this
# script stages it (binary + manifest + assets) and hands it to the refdistro
# emulator runner, which installs it onto a `playos-data` disk and boots with
# `playos.autostart=<game-id>`. Design:
# playos-spec/src/sdk-emulator-profile.md
#
# Usage:
#   PLAYOS_SDK=/path/to/playos-tools ./build-emulator.sh <source-dir> [build-dir] [runner args...]
#
# Environment:
#   PLAYOS_SDK        the SDK root (the playos-tools checkout)
#   PLAYOS_REFDISTRO  a playos-refdistro checkout (default: the sibling of the SDK's parent)
#
# The runner args are passed through: --timeout SECS, --display sdl,
# --gamepad /dev/input/eventN, --keep (see refdistro scripts/emulator-run.sh).
set -eu

SDK="${PLAYOS_SDK:?PLAYOS_SDK must point at the playos-sdk root}"
SRC="${1:?usage: build-emulator.sh <source-dir> [build-dir] [runner args...]}"
BUILD="${2:-build-emulator}"
if [ "$#" -ge 2 ]; then
    shift 2
else
    shift
fi

REFDISTRO="${PLAYOS_REFDISTRO:-$SDK/../../playos-refdistro}"
RUNNER="$REFDISTRO/scripts/emulator-run.sh"
if [ ! -f "$RUNNER" ]; then
    echo "error: emulator runner not found at $RUNNER" >&2
    echo "Set PLAYOS_REFDISTRO to a playos-refdistro checkout." >&2
    exit 1
fi

if [ ! -f "$SDK/toolchain/bin/x86_64-buildroot-linux-musl-gcc" ]; then
    echo "error: SDK toolchain not found under $SDK/toolchain" >&2
    echo "Run refdistro scripts/export-sdk.sh first." >&2
    exit 1
fi

# ── Build the device profile (musl) ───────────────────────────────────────
cmake -S "$SRC" -B "$BUILD" \
    -DCMAKE_TOOLCHAIN_FILE="$SDK/cmake/playos-toolchain.cmake" \
    -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD"

BIN="$BUILD/bin/game"
[ -x "$BIN" ] || BIN="$BUILD/game"
if [ ! -x "$BIN" ]; then
    echo "error: no device game binary found under $BUILD" >&2
    exit 1
fi
echo "==> Device build: $BIN"
file "$BIN"
echo "    (device ABI: the interpreter must be ld-musl-x86_64.so.1)"

# ── Stage the on-device layout (/data/games/<id>/) ────────────────────────
PAYLOAD="$BUILD/game-payload"
rm -rf "$PAYLOAD"
mkdir -p "$PAYLOAD/bin"
cp "$BIN" "$PAYLOAD/bin/game"
cp "$SRC/manifest.json" "$PAYLOAD/manifest.json"
for d in assets resources; do
    [ -d "$SRC/$d" ] && cp -a "$SRC/$d" "$PAYLOAD/"
done
chmod -R u+rwX,go+rX "$PAYLOAD"

GAME_ID="$(sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$SRC/manifest.json" | head -1)"

echo "==> Emulator payload staged at $PAYLOAD"
if [ -n "$GAME_ID" ]; then
    exec bash "$RUNNER" --game-dir "$PAYLOAD" --game-id "$GAME_ID" "$@"
else
    exec bash "$RUNNER" --game-dir "$PAYLOAD" "$@"
fi
