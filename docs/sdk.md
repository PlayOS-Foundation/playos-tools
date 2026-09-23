# PlayOS SDK

The SDK lets third-party developers build PlayOS games without the Buildroot
tree. It is the `playos-tools/sdk/` directory: the musl cross toolchain, the
frozen `libplayos` public API (`PLAYOS_API_VERSION 1`), Raylib with the
`PLATFORM_PLAYOS` backend, CMake toolchain support, `pkg-config` files, and the
three build profiles.

## Layout

```text
sdk/                          # <- PLAYOS_SDK points here
  toolchain/                  # x86_64-buildroot-linux-musl cross toolchain
  include/playos/*.h          # libplayos public headers
  include/raylib.h            # Raylib header (PLATFORM_PLAYOS backend)
  lib/                        # musl libplayos/libraylib (.so; .a when built)
  desktop/                    # native host raylib + libplayos shim (desktop profile)
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
scripts/export-sdk.sh output/ally  # populate playos-tools/sdk/ from the build
```

The export copies the musl toolchain and the device `libplayos`/`libraylib`, and
also builds the `desktop` profile (host raylib from the same vendored source,
plus the `PLAYOS_BACKEND=stub` shim) so both profiles come from one source of
truth. Set `PLAYOS_SDK` to the `sdk/` directory itself.

## Build a game

```sh
export PLAYOS_SDK=/path/to/playos-tools/sdk

# Device (musl) — shippable artifact
sdk/scripts/build-device.sh my-game

# Desktop (native window)
sdk/scripts/build-desktop.sh my-game

# Emulator (build the device profile, then boot it in QEMU)
sdk/scripts/build-emulator.sh my-game
```

### Emulator profile

The emulator runs the *device* (musl) build inside the minimal PlayOS QEMU
image (init + compositor + shell), so an artifact can be exercised without
hardware. Build the image once:

```sh
cd /path/to/playos-refdistro && make emulator-build
```

then from the SDK:

```sh
export PLAYOS_REFDISTRO=/path/to/playos-refdistro   # default: a sibling checkout
sdk/scripts/build-emulator.sh my-game               # headless; non-zero on failure
sdk/scripts/build-emulator.sh my-game build-emu --display sdl
sdk/scripts/build-emulator.sh my-game build-emu --gamepad /dev/input/event7
```

init launches the game via the `playos.autostart=<game-id>` boot token, and the
runner verifies that the game spawned and that the compositor rendered it.
Input fidelity is a human check — pass a real device with `--gamepad`. Full
design: `playos-spec/src/sdk-emulator-profile.md`.

## pkg-config

```sh
export PLAYOS_SDK=/path/to/playos-tools/sdk
export PKG_CONFIG_PATH=$PLAYOS_SDK/pkgconfig
gcc $(pkg-config --cflags --libs playos) game.c -o game
```

## Rules

- Device binaries **must** be musl-linked — never use a glibc host compiler
  for the device profile.
- The same `game.c` must build for all three profiles; do not fork source.
- The public ABI is frozen at `PLAYOS_API_VERSION 1` — do not change headers.
