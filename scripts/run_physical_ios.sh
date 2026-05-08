#!/usr/bin/env bash
# Build and run the Flutter app on physical iOS devices (default: your Xcode-paired iPhones).
#
# Default device names match Window → Devices and Simulators in Xcode:
#   Art_iPhone15, Art_iPhone17  (override: TARGET_IPHONE_NAMES="NameA,NameB")
# Run on every physical iOS device Flutter sees: ALL_PHYSICAL_IOS=1 ./scripts/run_physical_ios.sh
#
# List only: ./scripts/run_physical_ios.sh list
# Xcode-style table: ./scripts/run_physical_ios.sh xcode-list
#
# Cap how many selected devices get a run (after name filter / ordering):
#   LIMIT=1 ./scripts/run_physical_ios.sh
#
# Extra flutter run args:
#   ./scripts/run_physical_ios.sh --release
#   ./scripts/run_physical_ios.sh --dart-define=FOO=bar
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# Comma-separated names as shown in Xcode / `flutter devices` (physical iPhones for this repo).
DEFAULT_TARGET_IPHONE_NAMES="Art_iPhone15,Art_iPhone17"

LIMIT_RAW="${LIMIT:-}"
LIMIT=""
if [[ -n "$LIMIT_RAW" ]]; then
  if [[ "$LIMIT_RAW" =~ ^[0-9]+$ ]] && [[ "$LIMIT_RAW" -gt 0 ]]; then
    LIMIT="$LIMIT_RAW"
  else
    echo "LIMIT must be a positive integer, got: $LIMIT_RAW" >&2
    exit 2
  fi
fi

# Run a single Xcode build before multiple parallel `flutter run`s (avoids "concurrent builds").
ios_prebuild_once() {
  local n="$1"
  shift
  local mode="--debug"
  local extras=()
  local a
  for a in "$@"; do
    case "$a" in
      --release) mode="--release" ;;
      --profile) mode="--profile" ;;
    esac
  done
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dart-define)
        if [[ $# -lt 2 ]]; then
          echo "Missing value for --dart-define" >&2
          exit 2
        fi
        extras+=(--dart-define "$2")
        shift 2
        ;;
      --dart-define=*)
        extras+=("$1")
        shift
        ;;
      *)
        shift
        ;;
    esac
  done
  echo "Pre-building iOS ($mode) once for $n devices to avoid concurrent Xcode builds..." >&2
  if ((${#extras[@]} > 0)); then
    flutter build ios "$mode" "${extras[@]}"
  else
    flutter build ios "$mode"
  fi
}

physical_ios_json() {
  flutter devices --machine | jq -c '
    [.[] | select(.targetPlatform == "ios" and .emulator == false)]
    | sort_by(.name)
  '
}

targets_jq_from_csv() {
  local csv="$1"
  printf '%s' "$csv" | jq -R '
    split(",")
    | map(gsub("^\\s+|\\s+$";""))
    | map(select(length > 0))
  '
}

# stdin: full JSON array of devices. Prints filtered array in TARGET_NAME order.
filter_devices_by_target_names() {
  local names_csv="$1"
  local targets_json
  targets_json="$(targets_jq_from_csv "$names_csv")"
  jq -c --argjson targets "$targets_json" '
    [ $targets[] as $n | ([ .[] | select(.name == $n) ] | .[0] | select(. != null)) ]
  '
}

cmd_list() {
  local names_csv all_json filtered
  names_csv="${TARGET_IPHONE_NAMES:-$DEFAULT_TARGET_IPHONE_NAMES}"
  echo "Default run targets (set TARGET_IPHONE_NAMES or ALL_PHYSICAL_IOS=1 to change):"
  echo "  $names_csv"
  echo
  echo "Physical iOS devices (Flutter):"
  all_json="$(physical_ios_json)"
  echo "$all_json" | jq -r '.[] | "  \(.name)\t\(.id)\t\(.sdk // "")"'
  count="$(echo "$all_json" | jq 'length')"
  echo "Total physical iOS: $count"
  echo
  echo "Resolved targets for a normal run (connected subset, in order):"
  filtered="$(echo "$all_json" | filter_devices_by_target_names "$names_csv")"
  echo "$filtered" | jq -r '.[] | "  \(.name)\t\(.id)"'
  echo "Would run on: $(echo "$filtered" | jq 'length') device(s)"
}

cmd_xcode_list() {
  echo "Devices (xcrun devicectl — same pool Xcode uses for pairing):"
  xcrun devicectl list devices
}

cmd_run() {
  local json count devices_json i name id logdir names_csv targets_json all_physical
  all_physical="${ALL_PHYSICAL_IOS:-}"
  json="$(physical_ios_json)"
  count="$(echo "$json" | jq 'length')"

  if [[ "$count" -eq 0 ]]; then
    echo "No physical iOS devices found." >&2
    echo "Connect an iPhone with a trusted cable, unlock it, and ensure Xcode sees it (Window → Devices and Simulators)." >&2
    exit 1
  fi

  if [[ "$all_physical" == "1" || "$all_physical" == "true" || "$all_physical" == "yes" ]]; then
    devices_json="$json"
  else
    names_csv="${TARGET_IPHONE_NAMES:-$DEFAULT_TARGET_IPHONE_NAMES}"
    targets_json="$(targets_jq_from_csv "$names_csv")"
    while IFS= read -r missing_name; do
      [[ -z "$missing_name" ]] && continue
      echo "Warning: target not connected or not in Flutter device list (skipped): $missing_name" >&2
    done < <(echo "$json" | jq -r --argjson targets "$targets_json" '
      [.[] | .name] as $found |
      $targets[] | select(($found | index(.)) == null)
    ')
    devices_json="$(echo "$json" | filter_devices_by_target_names "$names_csv")"
    count="$(echo "$devices_json" | jq 'length')"
    if [[ "$count" -eq 0 ]]; then
      echo "None of the configured iPhones are connected. Targets: $names_csv" >&2
      echo "Connect a device, run ./scripts/run_physical_ios.sh list, or set ALL_PHYSICAL_IOS=1 to use every physical iOS device." >&2
      exit 1
    fi
  fi

  if [[ -n "$LIMIT" ]]; then
    devices_json="$(echo "$devices_json" | jq -c --argjson lim "$LIMIT" '.[:$lim]')"
    count="$(echo "$devices_json" | jq 'length')"
    if [[ "$count" -eq 0 ]]; then
      echo "LIMIT=$LIMIT removed all devices after filtering." >&2
      exit 1
    fi
  fi

  echo "Running on $count physical iOS device(s):"
  echo "$devices_json" | jq -r '.[] | "  \(.name) (\(.id))"'

  if [[ "$count" -gt 1 ]]; then
    ios_prebuild_once "$count" "$@"
  fi

  logdir="${LOG_DIR:-}"
  if [[ -n "$logdir" ]]; then
    mkdir -p "$logdir"
  fi

  pids=()
  for ((i = 0; i < count; i++)); do
    name="$(echo "$devices_json" | jq -r --argjson idx "$i" '.[$idx].name')"
    id="$(echo "$devices_json" | jq -r --argjson idx "$i" '.[$idx].id')"
    safe_name="$(echo "$name" | tr ' /:' '___')"

    if [[ -n "$logdir" ]]; then
      logfile="$logdir/flutter-run-${safe_name}.log"
      echo "Logs: $logfile"
      flutter run -d "$id" "$@" >>"$logfile" 2>&1 &
    else
      echo "--- $name ($id) — output follows (interleaved if multiple) ---"
      flutter run -d "$id" "$@" &
    fi
    pids+=($!)
  done

  ec=0
  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      ec=1
    fi
  done
  exit "$ec"
}

case "${1:-}" in
  list|devices)
    cmd_list
    ;;
  xcode-list)
    cmd_xcode_list
    ;;
  -h|--help|help)
    sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
    ;;
  "")
    cmd_run
    ;;
  *)
    cmd_run "$@"
    ;;
esac
