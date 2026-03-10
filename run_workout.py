import argparse
import asyncio
from typing import Optional

from bleak import BleakClient

import scan_ble


def _build_cmd(cmd: int, val: int) -> bytearray:
    payload = bytearray([0xF7, 0xA2, cmd, val, 0xFF, 0xFD])
    return scan_ble._fix_crc(payload)


async def _send(client: BleakClient, cmd: bytearray, delay_s: float) -> None:
    await client.write_gatt_char(scan_ble.CHAR_WRITE_FE02, cmd, response=False)
    print(f"[WRITE] {scan_ble.CHAR_WRITE_FE02} <= {scan_ble._hex(cmd)}")
    await asyncio.sleep(delay_s)


async def run_workout(address: Optional[str], name: Optional[str], delay_s: float) -> None:
    resolved = await scan_ble._resolve_address(address, name)
    print("Using address:", resolved)

    async with BleakClient(resolved) as client:
        print("Connected:", client.is_connected)

        # Manual mode + start.
        await _send(client, _build_cmd(0x02, 0x01), delay_s)
        await _send(client, _build_cmd(0x04, 0x01), delay_s)

        plan = [
            (60, 50),   # 1 min @ 5.0 km/h
            (180, 70),  # 3 min @ 7.0 km/h
            (60, 40),   # 1 min @ 4.0 km/h
        ]

        for seconds, speed_tenths in plan:
            await _send(client, _build_cmd(0x01, speed_tenths), delay_s)
            print(f"Hold {seconds}s at {speed_tenths/10:.1f} km/h")
            await asyncio.sleep(seconds)

        # Stop at the end.
        await _send(client, _build_cmd(0x01, 0x00), delay_s)


def main() -> None:
    parser = argparse.ArgumentParser(description="Simple KS-F0 workout plan")
    parser.add_argument("--name", type=str, default="KS-F0")
    parser.add_argument("--address", type=str, default=None)
    parser.add_argument("--delay", type=float, default=1.2)
    args = parser.parse_args()

    asyncio.run(run_workout(args.address, args.name, args.delay))


if __name__ == "__main__":
    main()
