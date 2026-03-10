import argparse
import asyncio
import sys
from typing import Optional

from bleak import BleakClient

import scan_ble


def _format_status(parsed: dict) -> str:
    if parsed.get("type") != "cur_status":
        return ""
    return (
        f"speed={parsed['speed']:.1f} km/h  "
        f"dist={parsed['dist']:.2f} km  "
        f"time={parsed['time']} s  "
        f"steps={parsed['steps']}  "
        f"state={parsed['belt_state']}  "
        f"mode={parsed['manual_mode']}"
    )


async def run(address: Optional[str], name: Optional[str]) -> None:
    resolved = await scan_ble._resolve_address(address, name)
    print("Using address:", resolved)

    last_line = ""

    def on_notify(sender: int, data: bytearray) -> None:
        nonlocal last_line
        parsed = scan_ble._parse_status(bytes(data))
        if not parsed:
            return
        line = _format_status(parsed)
        if line:
            last_line = line
            sys.stdout.write("\r" + line.ljust(120))
            sys.stdout.flush()

    async with BleakClient(resolved) as client:
        print("Connected:", client.is_connected)
        await client.start_notify(scan_ble.CHAR_NOTIFY_FE01, on_notify)
        try:
            while True:
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            pass
        finally:
            await client.stop_notify(scan_ble.CHAR_NOTIFY_FE01)
            if last_line:
                sys.stdout.write("\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Live KS-F0 stats in one line")
    parser.add_argument("--name", type=str, default="KS-F0")
    parser.add_argument("--address", type=str, default=None)
    args = parser.parse_args()

    try:
        asyncio.run(run(args.address, args.name))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
