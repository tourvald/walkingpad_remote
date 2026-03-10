# walkingpad_remote

WalkingPad control project with an iOS/watchOS app, HR-driven treadmill control, and a small set of Python BLE utilities for local diagnostics.

## Repository layout

- `ios/WalkingPadRemote`: main iOS/watchOS app
- `tools`: local tooling, including the MCP Xcode server and helper scripts
- `scan_ble.py`, `run_live_stats.py`, `run_workout.py`: BLE debugging utilities for treadmill protocols

## Public repo notes

- The local `ph4-walkingpad` clone is intentionally not included in this repository because it is an upstream reference repo with its own git history.

### Run core logic tests

```bash
cd ios/WalkingPadRemote/WalkingPadRemote
swift test
```

See [ios/README.md](ios/README.md) for iOS target details.
