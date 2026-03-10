#!/usr/bin/env bash
set -euo pipefail

NUM="${1:-}"
NAME="${2:-KS-F0}"
CHAR="${3:-0000fe02-0000-1000-8000-00805f9b34fb}"

if [[ -z "$NUM" ]]; then
  echo "Usage: bash run_seq_num.sh <1|2|3|4> [name] [char]"
  exit 1
fi

case "$NUM" in
  1)
    # start + speed
    PAYLOADS=("F7 A2 04 01 A7 FD" "F7 A2 01 0A AD FD")
    ;;
  2)
    # mode manual + start
    PAYLOADS=("F7 A2 02 01 A5 FD" "F7 A2 04 01 A7 FD")
    ;;
  3)
    # mode manual only
    PAYLOADS=("F7 A2 02 01 A5 FD")
    ;;
  4)
    # full sequence (baseline)
    PAYLOADS=("F7 A2 03 07 AC FD" "F7 A2 02 01 A5 FD" "F7 A2 04 01 A7 FD" "F7 A2 01 0A AD FD")
    ;;
  *)
    echo "Unknown sequence: $NUM (use 1,2,3,4)"
    exit 1
    ;;
esac

python3 scan_ble.py seq --name "${NAME}" --notify --char "${CHAR}" "${PAYLOADS[@]}"
