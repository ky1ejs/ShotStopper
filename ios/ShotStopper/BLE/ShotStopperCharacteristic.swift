@preconcurrency import CoreBluetooth

enum ShotStopperBLE {
    static let serviceUUID = CBUUID(string: "00000000-0000-0000-0000-000000000FFE")

    enum Characteristic {
        /// Goal weight in grams (UInt8, read+write). The only BLE-configurable setting
        /// on the current shotStopper firmware.
        static let goalWeight = CBUUID(string: "00000000-0000-0000-0000-00000000FF11")
    }
}
