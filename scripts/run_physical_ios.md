# Run Flutter on physical iOS devices

`run_physical_ios.sh` runs `flutter run` on **physical** iPhones/iPads (not simulators). Device discovery matches Xcode pairing (Core Device / usbmux).

By default it targets **your two Xcode-connected iPhones**, in order:

1. **Art_iPhone15**
2. **Art_iPhone17**

Names are the same as in **Xcode → Window → Devices and Simulators** and in `flutter devices`. Only **connected** devices in that list are used; missing ones are skipped with a warning.

## Prerequisites

- **Bash** — the script is `#!/usr/bin/env bash` (use `./scripts/run_physical_ios.sh`; avoid `sh`, which may be a different shell).
- Flutter SDK on `PATH`
- [`jq`](https://jqlang.github.io/jq/) for JSON parsing (macOS: often `brew install jq`)
- For `xcode-list`: Xcode command-line tools (`xcrun`)
- Devices: unlocked, trusted, developer mode if required, same signing setup as a normal Flutter/Xcode run

## How to run

From the **repository root** (`uydosh_mobile`):

```bash
cd /path/to/uydosh_mobile

# See default targets + what Flutter sees + what a run would use
./scripts/run_physical_ios.sh list

# Build & run on every connected default iPhone (Art_iPhone15, Art_iPhone17), in parallel
./scripts/run_physical_ios.sh

# Same, with separate log files per device
mkdir -p /tmp/flutter-logs
LOG_DIR=/tmp/flutter-logs ./scripts/run_physical_ios.sh

# Release: applies to the one-time `flutter build ios` when 2+ devices, and to each `flutter run`
./scripts/run_physical_ios.sh --release
```

### Xcode device table (no Flutter build)

```bash
./scripts/run_physical_ios.sh xcode-list
```

### Built-in help

```bash
./scripts/run_physical_ios.sh --help
```

## Environment variables

| Variable | Description |
|----------|-------------|
| `TARGET_IPHONE_NAMES` | Comma-separated device **names** (override defaults). Example: `TARGET_IPHONE_NAMES="Art_iPhone15"` runs on one phone only. |
| `ALL_PHYSICAL_IOS` | If `1`, `true`, or `yes`: run on **every** physical iOS device Flutter lists (not only the default two). |
| `LIMIT` | After the name filter, use at most this many devices (order preserved: default list order, or Flutter name sort when `ALL_PHYSICAL_IOS=1`). |
| `LOG_DIR` | Per-device log files: `LOG_DIR/flutter-run-<name>.log`. |

## Behaviour notes

- **Parallel runs**: Multiple devices ⇒ multiple `flutter run` processes; terminal output is **interleaved** unless `LOG_DIR` is set.
- **Pre-build (two or more devices only)**: If `LIMIT` and filters leave **more than one** device, the script runs **`flutter build ios`** once before starting the parallel `flutter run`s. That greatly reduces **“Xcode build failed due to concurrent builds”** (Flutter may still print a retry line occasionally; it usually recovers after the shared build finishes). With **one** device, there is no pre-build step.
- **Flags on the pre-build**: The pre-build copies **`--release`**, **`--profile`**, and **`--dart-define`** / **`--dart-define=...`** from your command line into `flutter build ios`. Other `flutter run` flags are **not** passed to `flutter build ios`—they still apply to each **`flutter run`**.
- **Wireless vs USB**: Devices shown as **wireless** in `flutter devices` can be slow to install or attach (Flutter warns on newer iOS). Prefer a **USB** cable for faster, more reliable runs when both are available.
- **Exit code**: Non-zero if any parallel run fails.
- **No matching devices**: Exits with an error if no configured iPhone is connected (unless `ALL_PHYSICAL_IOS=1` and something is connected).

## Changing the default phones for the repo

Edit `DEFAULT_TARGET_IPHONE_NAMES` in `scripts/run_physical_ios.sh` (comma-separated names), or export `TARGET_IPHONE_NAMES` when you run.

## Examples

```bash
./scripts/run_physical_ios.sh list
./scripts/run_physical_ios.sh xcode-list

# Only first default iPhone (still uses default name order)
LIMIT=1 ./scripts/run_physical_ios.sh

# Custom set of names
TARGET_IPHONE_NAMES="Art_iPhone17" ./scripts/run_physical_ios.sh

# All physical iOS devices Flutter sees (e.g. extra iPad)
ALL_PHYSICAL_IOS=1 ./scripts/run_physical_ios.sh

# Defines apply to both the one-time `flutter build ios` (if 2+ devices) and each `flutter run`
./scripts/run_physical_ios.sh --dart-define=MY_FLAG=true
```
