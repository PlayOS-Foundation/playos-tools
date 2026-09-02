# PlayOS SDK

The SDK lets third-party developers build PlayOS games without the Buildroot
tree. It contains the musl cross toolchain, the frozen `libplayos` public API
(`PLAYOS_API_VERSION 1`), Raylib with the `PLATFORM_PLAYOS` backend, CMake
toolchain support, `pkg-config` files, and the three build profiles.

## Layout

```text
sdk/
  toolchain/                  # x86_64-buildroot-linux-musl cross toolchain
  include/playos/*.h          # libplayos public headers
  include/raylib.h            # Raylib header (PLATFORM_PLAYOS backend)
  lib/                        # musl libplayos/libraylib (.so; .a when built)
  cmake/playos-toolchain.cmake
  pkgconfig/playos.pc
  pkgconfig/raylib-playos.pc
  scripts/build-device.sh
  scripts/build-desktop.sh
  scripts/build-emulator.sh
```

## Build profiles

| Profile | Toolchain | libplayos | libraylib | Use |
|---|---|---|---|---|
| `device` | musl cross | real evdev | PLATFORM_PLAYOS | shippable `bin/game` |
| `desktop` | host gcc | host shim | desktop backend | fast iteration in a window |
| `emulator` | musl cross | real evdev | PLATFORM_PLAYOS | run the device build in QEMU |

## Generate the SDK

From `playos-refdistro` (after `make ally-build`):

```sh
make ally-sdk                      # Buildroot relocatable SDK tarball (optional)
scripts/export-sdk.sh output/ally  # populate this sdk/ tree from the build
```

Set `PLAYOS_SDK` to this directory's parent (`playos-tools/`) so the cmake
toolchain and pkg-config files resolve.

## Build a game

```sh
export PLAYOS_SDK=/path/to/playos-tools

# Device (musl)
sdk/scripts/build-device.sh my-game

# Desktop (native window)
sdk/scripts/build-desktop.sh my-game

# Emulator (run the device build in QEMU)
sdk/scripts/build-emulator.sh build-device
```

## pkg-config

```sh
export PKG_CONFIG_PATH=$PLAYOS_SDK/sdk/pkgconfig
gcc $(pkg-config --cflags --libs playos) game.c -o game
```

## Rules

- Device binaries **must** be musl-linked — never use a glibc host compiler
  for the device profile.
- The same `game.c` must build for all three profiles; do not fork source.
- The public ABI is frozen at `PLAYOS_API_VERSION 1` — do not change headers.
