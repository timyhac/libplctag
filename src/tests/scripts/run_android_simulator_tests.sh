#!/usr/bin/env bash
# Runs the simulator test suite with every client on the attached Android device/emulator
# and every server on the host. See android_adb_client_wrapper.sh.
#
# Usage: run_android_simulator_tests.sh <android-bin-dir> <host-bin-dir> <log-dir> [runner args...]
set -euo pipefail
android_bin="$(cd "$1" && pwd)"
host_bin="$(cd "$2" && pwd)"
logs="$3"; shift 3
here="$(cd "$(dirname "$0")" && pwd)"
export DEVICE_DIR=/data/local/tmp/plctag

echo "Device: API $(adb shell getprop ro.build.version.sdk | tr -d '\r'), ABI $(adb shell getprop ro.product.cpu.abi | tr -d '\r')"
adb shell rm -rf "$DEVICE_DIR"
adb push "$android_bin" "$DEVICE_DIR" >/dev/null
adb shell "chmod 755 $DEVICE_DIR/*"

mkdir -p "$logs"
python3 "$here/run_simulator_tests_parallel.py" "$host_bin" "$logs" \
  --client-wrapper "bash $here/android_adb_client_wrapper.sh" \
  "$@"
