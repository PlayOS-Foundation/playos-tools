#!/bin/sh
# build-emulator.sh — run a device-profile PlayOS game in the QEMU emulator.
#
# Usage:
#   ./build-emulator.sh <device-build-dir> [qemu-image]
set -eu

DEVICE_BUILD="${1:?usage: build-emulator.sh <device-build-dir> [qemu-image]}"
QEMU_IMG="${2:-/home/nikmes/playos/playos-refdistro/output/qemu/images/playos-qemu-usb.img}"

echo "error: emulator profile wiring is implemented in Sprint 15-T7" >&2
exit 1
