import Foundation

struct DeviceSettings: Equatable, Sendable {
    var goalWeight: UInt8 = 36
    var enabled: Bool = false
    var autoTare: Bool = false
    var momentary: Bool = false
    var reedSwitch: Bool = false
    var minShotDuration: UInt8 = 5
    var maxShotDuration: UInt8 = 60
    var dripDelay: UInt8 = 3

    static func decodeBool(from data: Data) -> Bool {
        guard let first = data.first else { return false }
        return first == 1
    }

    static func decodeUInt8(from data: Data) -> UInt8 {
        data.first ?? 0
    }

    static func decodeString(from data: Data) -> String {
        String(data: data, encoding: .utf8) ?? ""
    }

    static func encodeBool(_ value: Bool) -> Data {
        Data([value ? 1 : 0])
    }

    static func encodeUInt8(_ value: UInt8) -> Data {
        Data([value])
    }

    static func encodeString(_ value: String) -> Data {
        Data(value.utf8)
    }
}
