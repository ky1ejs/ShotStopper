import Foundation

enum ConnectionState: Sendable {
    case disconnected
    case scanning
    case connecting
    case connected
    case bluetoothOff
    case unauthorized
}

enum ScaleStatus: UInt8, Sendable, CustomStringConvertible {
    case disconnected = 0
    case searching = 1
    case connected = 2

    var description: String {
        switch self {
        case .disconnected: "Disconnected"
        case .searching: "Searching"
        case .connected: "Connected"
        }
    }
}

struct DiscoveredDevice: Identifiable, Sendable {
    let id: UUID
    let name: String
    let rssi: Int
}
