import Foundation

struct DeviceSettings: Equatable, Sendable {
    var goalWeight: UInt8 = 36

    static func decodeUInt8(from data: Data) -> UInt8 {
        data.first ?? 0
    }

    static func encodeUInt8(_ value: UInt8) -> Data {
        Data([value])
    }
}
