#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-KS-F0}"
CHAR="${2:-0000fe02-0000-1000-8000-00805f9b34fb}"

python3 scan_ble.py seq --name "${NAME}" --notify --char "${CHAR}" \
  "F7 A2 03 07 AC FD" \
  "F7 A2 02 01 A5 FD" \
  "F7 A2 04 01 A7 FD" \
  "F7 A2 01 0A AD FD"
