import Foundation

enum ConnectionState: Sendable {
    case disconnected
    case scanning
    case connecting
    case connected
    case bluetoothOff
    case unauthorized
}

struct DiscoveredDevice: Identifiable, Sendable {
    let id: UUID
    let name: String
    let rssi: Int
}
