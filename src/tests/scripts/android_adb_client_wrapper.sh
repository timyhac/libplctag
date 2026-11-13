#!/usr/bin/env bash
# --client-wrapper for run_simulator_tests_parallel.py: runs each test *client* on an Android
# device/emulator via adb. Servers (ab_server, modbus_server) stay on the host.
#
# Usage (from the runner): android_adb_client_wrapper.sh <host-path-to-client> [args...]
#
#  * The client, and any argument that is a file in the host test directory, are mapped onto
#    $DEVICE_DIR, where the Android build of the same binaries has been pushed.
#  * Other arguments pass through unchanged. The device's 127.0.0.1:<port> is tunnelled to the
#    host with `adb reverse`, so gateway strings, Omron "path=18,127.0.0.1" routes and the
#    library's compiled-in default port all work as on the host.
#  * Tests that start ab_server themselves (it appears as an argument) run it on the device,
#    so no reverse tunnel is set up for them.
#  * TMPDIR is set because older Android versions have no /tmp.
#  * adb shell (protocol v2) returns the client's exit code.
set -uo pipefail

ADB="${ADB:-adb}"
DEVICE_DIR="${DEVICE_DIR:-/data/local/tmp/plctag}"
DEFAULT_LIB_PORT=44818

host_exe="$1"; shift
host_dir="$(cd "$(dirname "$host_exe")" && pwd)"
dev_exe="$DEVICE_DIR/$(basename "${host_exe%.exe}")"

server_on_device=0
quoted=()
for a in "$@"; do
  if [[ -f "$a" && "$(cd "$(dirname "$a")" && pwd)" == "$host_dir" ]]; then
    a="$DEVICE_DIR/$(basename "${a%.exe}")"
    [[ "$a" == */ab_server || "$a" == */modbus_server* ]] && server_on_device=1
  fi
  quoted+=("$(printf '%q' "$a")")
done

if [[ $server_on_device -eq 0 ]]; then
  ports="$(printf '%s\n' "$@" | grep -oE '127\.0\.0\.1:[0-9]+' | cut -d: -f2 | sort -u)"
  for p in $ports $DEFAULT_LIB_PORT; do
    "$ADB" reverse "tcp:$p" "tcp:$p" >/dev/null
  done
fi

exec "$ADB" shell "cd $DEVICE_DIR && TMPDIR=$DEVICE_DIR LD_LIBRARY_PATH=$DEVICE_DIR $dev_exe ${quoted[*]}"
