#!/usr/bin/env bash
set -euo pipefail

ADDR_FLAG=()
if [[ $# -ge 1 && -n "${1:-}" ]]; then
  ADDR_FLAG+=("$1")
else
  ADDR_FLAG+=(--name "KS-F0")
fi

python3 scan_ble.py raw 0000fe02-0000-1000-8000-00805f9b34fb "F7 A2 03 07 AC FD" "${ADDR_FLAG[@]}"
sleep 1
python3 scan_ble.py raw 0000fe02-0000-1000-8000-00805f9b34fb "F7 A2 02 01 A5 FD" "${ADDR_FLAG[@]}"
sleep 1
python3 scan_ble.py raw 0000fe02-0000-1000-8000-00805f9b34fb "F7 A2 04 01 A7 FD" "${ADDR_FLAG[@]}"
sleep 1
python3 scan_ble.py raw 0000fe02-0000-1000-8000-00805f9b34fb "F7 A2 01 0A AD FD" "${ADDR_FLAG[@]}"
sleep 1
python3 scan_ble.py stats "${ADDR_FLAG[@]}" --duration 5
