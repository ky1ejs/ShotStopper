# ShotStopper

An iOS companion app for [Tate Mazer's shotStopper](https://tatemazer.com/store/p/shotstopper-v2) — an ESP32-based device that connects to Bluetooth scales and stops espresso brewing when a target weight is reached.

## Why?

The original shotStopper iOS app was removed from the App Store. It's still available on [Google Play](https://play.google.com/store/apps/details?id=com.icapurro.shotStopperCompanion&hl=en_US) for Android, but there's no way to configure the device from an iPhone. This project fixes that.

## What it does

The app connects to your shotStopper over Bluetooth Low Energy and lets you set the **goal weight** — the target weight at which the device stops your espresso shot.

The shotStopper firmware currently exposes a single BLE characteristic for configuration:

| Service | Characteristic | Description |
|---------|---------------|-------------|
| `0x0FFE` | `0xFF11` | Goal weight in grams (1–99g, persisted to EEPROM) |

## Screenshots

_Coming soon_

## Getting started

### Prerequisites

- Xcode 16+
- [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- A physical iPhone (BLE doesn't work in the simulator)
- A [shotStopper](https://tatemazer.com/store/p/shotstopper-v2) device

### Build & run

```bash
cd ios
xcodegen generate
open ShotStopper.xcodeproj
```

Select your iPhone as the run destination and hit Run.

## Tech stack

- Swift 6
- SwiftUI
- CoreBluetooth
- xcodegen for project generation

## Project structure

```
ios/
  project.yml                         # xcodegen config
  ShotStopper/
    App/                              # App entry point and root view
    BLE/                              # CoreBluetooth manager and UUID constants
    Models/                           # Device settings and connection state
    ViewModels/                       # Observable view model bridging BLE to UI
    Views/                            # SwiftUI views (scanning, dashboard, settings)
    Resources/                        # Asset catalog
```

## Related projects

- [AcaiaArduinoBLE](https://github.com/tatemazer/AcaiaArduinoBLE) — shotStopper firmware source
- [shotStopperCompanionApp](https://github.com/icapurro/shotStopperCompanionApp) — React Native companion app (Android)

## License

MIT
