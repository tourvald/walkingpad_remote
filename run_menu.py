import argparse
import asyncio
import math
from typing import Optional

from bleak import BleakClient

import scan_ble


def _build_cmd(cmd: int, val: int) -> bytearray:
    payload = bytearray([0xF7, 0xA2, cmd, val, 0xFF, 0xFD])
    return scan_ble._fix_crc(payload)


def _speed_to_tenths(speed_kmh: float) -> int:
    return int(round(speed_kmh * 10))


async def _send_payloads(
    client: BleakClient,
    payloads: list[bytearray],
    delay_s: float,
) -> None:
    for payload in payloads:
        await client.write_gatt_char(scan_ble.CHAR_WRITE_FE02, payload, response=False)
        print(f"[WRITE] {scan_ble.CHAR_WRITE_FE02} <= {scan_ble._hex(payload)}")
        await asyncio.sleep(delay_s)


async def _ramp_speed(client: BleakClient, start_kmh: float, target_kmh: float, delay_s: float) -> None:

    step = 0.5
    direction = 1 if target_kmh >= start_kmh else -1
    steps = int(math.floor(abs(target_kmh - start_kmh) / step))

    for i in range(steps + 1):
        speed = start_kmh + direction * step * i
        speed_tenths = _speed_to_tenths(speed)
        payload = _build_cmd(0x01, speed_tenths)
        await client.write_gatt_char(scan_ble.CHAR_WRITE_FE02, payload, response=False)
        print(f"Speed -> {speed:.1f} km/h")
        await asyncio.sleep(delay_s)


def _print_menu() -> None:
    print("1: start + speed")
    print("2: mode manual + start")
    print("3: mode manual only")
    print("4: full sequence")
    print("s: set speed (km/h)")
    print("r: ramp speed (km/h, step 0.5)")
    print("0: stop")
    print("q: quit")


def main() -> None:
    parser = argparse.ArgumentParser(description="Interactive menu for KS-F0")
    parser.add_argument("--name", type=str, default="KS-F0")
    parser.add_argument("--address", type=str, default=None)
    parser.add_argument("--notify", action="store_true")
    parser.add_argument("--delay", type=float, default=0.8)
    args = parser.parse_args()

    address = args.address
    name = args.name
    notify = args.notify
    delay_s = args.delay
    current_speed = 1.0

    print(f"Sequence menu for {name}")
    _print_menu()

    async def session():
        resolved = await scan_ble._resolve_address(address, name)
        print("Using address:", resolved)

        def on_notify(sender: int, data: bytearray) -> None:
            parsed = scan_ble._parse_status(bytes(data))
            if parsed:
                print(f"[NOTIFY] {parsed}")
            else:
                print(f"[NOTIFY] sender={sender} data={scan_ble._hex(bytes(data))}")

        async with BleakClient(resolved) as client:
            print("Connected:", client.is_connected)
            if notify:
                await client.start_notify(scan_ble.CHAR_NOTIFY_FE01, on_notify)

            while True:
                key = await asyncio.to_thread(input, "> ")
                key = key.strip()
                nonlocal current_speed
                if key == "1":
                    payloads = [_build_cmd(0x04, 0x01), _build_cmd(0x01, _speed_to_tenths(current_speed))]
                    await _send_payloads(client, payloads, delay_s)
                elif key == "2":
                    payloads = [_build_cmd(0x02, 0x01), _build_cmd(0x04, 0x01)]
                    await _send_payloads(client, payloads, delay_s)
                elif key == "3":
                    payloads = [_build_cmd(0x02, 0x01)]
                    await _send_payloads(client, payloads, delay_s)
                elif key == "4":
                    payloads = [
                        _build_cmd(0x03, 0x07),
                        _build_cmd(0x02, 0x01),
                        _build_cmd(0x04, 0x01),
                        _build_cmd(0x01, _speed_to_tenths(current_speed)),
                    ]
                    await _send_payloads(client, payloads, delay_s)
                elif key.lower() == "s":
                    spd = await asyncio.to_thread(input, "Speed (km/h, step 0.5): ")
                    spd = spd.strip()
                    if not spd:
                        print("No speed entered.")
                        continue
                    current_speed = float(spd)
                    payloads = [_build_cmd(0x01, _speed_to_tenths(current_speed))]
                    await _send_payloads(client, payloads, delay_s)
                elif key.lower() == "r":
                    s_start = await asyncio.to_thread(input, "Start speed (km/h, step 0.5): ")
                    s_target = await asyncio.to_thread(input, "Target speed (km/h, step 0.5): ")
                    s_delay = await asyncio.to_thread(input, "Delay seconds (default 1): ")
                    s_delay = s_delay.strip() or "1"
                    await _ramp_speed(client, float(s_start), float(s_target), float(s_delay))
                elif key == "0":
                    payloads = [_build_cmd(0x01, 0x00)]
                    await _send_payloads(client, payloads, delay_s)
                elif key.lower() == "q":
                    return
                else:
                    print("Unknown key. Use 1-4, s, r, 0, q.")

    asyncio.run(session())


if __name__ == "__main__":
    main()
