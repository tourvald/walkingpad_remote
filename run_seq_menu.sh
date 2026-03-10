#!/usr/bin/env bash
set -euo pipefail

NAME="${1:-KS-F0}"
CHAR="${2:-0000fe02-0000-1000-8000-00805f9b34fb}"

echo "Sequence menu for ${NAME}"
echo "1: start + speed"
echo "2: mode manual + start"
echo "3: mode manual only"
echo "4: full sequence"
echo "s: set speed (km/h)"
echo "r: ramp speed (km/h, step 0.5)"
echo "0: stop"
echo "q: quit"

to_hex_byte() {
  printf "%02X" "$1"
}

send_speed() {
  local speed_tenths="$1"
  local crc=$(( (0xA2 + 0x01 + speed_tenths) % 256 ))
  local payload="F7 A2 01 $(to_hex_byte "${speed_tenths}") $(to_hex_byte "${crc}") FD"
  python3 scan_ble.py seq --name "${NAME}" --char "${CHAR}" "${payload}"
}

while true; do
  read -r -n1 -s -p "> " key
  echo
  case "$key" in
    1|2|3|4)
      bash run_seq_num.sh "$key" "$NAME" "$CHAR"
      ;;
    s|S)
      read -r -p "Speed (km/h, step 0.5): " spd
      if [[ -z "${spd}" ]]; then
        echo "No speed entered."
        continue
      fi
      speed_tenths=$(python3 - <<PY
v=float("${spd}")
print(int(round(v*10)))
PY
)
      send_speed "${speed_tenths}"
      ;;
    r|R)
      read -r -p "Start speed (km/h, step 0.5): " s_start
      read -r -p "Target speed (km/h, step 0.5): " s_target
      read -r -p "Delay seconds (default 1): " s_delay
      s_delay="${s_delay:-1}"
      mapfile -t speeds < <(python3 - <<PY
import time
def seq(a,b,step=0.5):
    if a <= b:
        x=a
        while x <= b+1e-9:
            yield x
            x+=step
    else:
        x=a
        while x >= b-1e-9:
            yield x
            x-=step
start=float("${s_start}")
target=float("${s_target}")
delay=float("${s_delay}")
for v in seq(start,target):
    print(int(round(v*10)))
    time.sleep(delay)
PY
)
      for v in "${speeds[@]}"; do
        printf "Speed -> %.1f\n" "$(awk -v v="$v" 'BEGIN{print v/10}')"
        send_speed "${v}"
      done
      ;;
    0)
      send_speed 0
      ;;
    q|Q)
      exit 0
      ;;
    *)
      echo "Unknown key: $key (use 1-4 or q)"
      ;;
  esac
done
