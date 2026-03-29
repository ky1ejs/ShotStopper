@preconcurrency import CoreBluetooth

enum ShotStopperBLE {
    static let serviceUUID = CBUUID(string: "00000000-0000-0000-0000-000000000FFE")

    enum Characteristic {
        static let enabled = CBUUID(string: "00000000-0000-0000-0000-00000000FF10")
        static let goalWeight = CBUUID(string: "00000000-0000-0000-0000-00000000FF11")
        static let reedSwitch = CBUUID(string: "00000000-0000-0000-0000-00000000FF12")
        static let momentary = CBUUID(string: "00000000-0000-0000-0000-00000000FF13")
        static let autoTare = CBUUID(string: "00000000-0000-0000-0000-00000000FF14")
        static let minShotDuration = CBUUID(string: "00000000-0000-0000-0000-00000000FF15")
        static let maxShotDuration = CBUUID(string: "00000000-0000-0000-0000-00000000FF16")
        static let dripDelay = CBUUID(string: "00000000-0000-0000-0000-00000000FF17")
        static let firmwareVersion = CBUUID(string: "00000000-0000-0000-0000-00000000FF18")
        static let scaleStatus = CBUUID(string: "00000000-0000-0000-0000-00000000FF19")
        static let shotStatus = CBUUID(string: "00000000-0000-0000-0000-00000000FF20")
        static let otaModeRequested = CBUUID(string: "00000000-0000-0000-0000-00000000FF21")
        static let wifiSSID = CBUUID(string: "00000000-0000-0000-0000-00000000FF22")
        static let wifiPassword = CBUUID(string: "00000000-0000-0000-0000-00000000FF23")
        static let wifiIP = CBUUID(string: "00000000-0000-0000-0000-00000000FF24")

        static let all: [CBUUID] = [
            enabled, goalWeight, reedSwitch, momentary, autoTare,
            minShotDuration, maxShotDuration, dripDelay, firmwareVersion,
            scaleStatus, shotStatus, otaModeRequested, wifiSSID, wifiIP
        ]

        static let notifiable: [CBUUID] = [scaleStatus, shotStatus]
    }
}
