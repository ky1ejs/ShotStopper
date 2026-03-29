@preconcurrency import CoreBluetooth
import SwiftUI

@MainActor
@Observable
final class DeviceViewModel {
    private let bleManager = BLEManager()

    var connectionState: ConnectionState = .disconnected
    var discoveredDevices: [DiscoveredDevice] = []
    var settings = DeviceSettings()

    init() {
        bleManager.onStateChange = { [weak self] in
            self?.syncState()
        }
        bleManager.onConnectionChange = { [weak self] connected in
            self?.connectionState = connected ? .connected : .disconnected
            if !connected {
                self?.settings = DeviceSettings()
            }
        }
        bleManager.onCharacteristicUpdate = { [weak self] uuid, data in
            self?.handleCharacteristicUpdate(uuid: uuid, data: data)
        }
    }

    // MARK: - Scanning

    func startScanning() {
        bleManager.startScanning()
        connectionState = .scanning
    }

    func stopScanning() {
        bleManager.stopScanning()
        if connectionState == .scanning {
            connectionState = .disconnected
        }
    }

    // MARK: - Connection

    func connect(to device: DiscoveredDevice) {
        guard let peripheral = bleManager.peripheral(for: device) else { return }
        connectionState = .connecting
        bleManager.connect(to: peripheral)
    }

    func disconnect() {
        bleManager.disconnect()
    }

    // MARK: - Settings

    func updateGoalWeight(_ weight: UInt8) {
        settings.goalWeight = weight
        bleManager.writeValue(DeviceSettings.encodeUInt8(weight), for: ShotStopperBLE.Characteristic.goalWeight)
    }

    // MARK: - Private

    private func syncState() {
        switch bleManager.centralState {
        case .poweredOff:
            connectionState = .bluetoothOff
        case .unauthorized:
            connectionState = .unauthorized
        case .poweredOn:
            if connectionState == .bluetoothOff || connectionState == .unauthorized {
                connectionState = .disconnected
            }
        default:
            break
        }

        discoveredDevices = bleManager.discoveredPeripherals.map { entry in
            DiscoveredDevice(
                id: entry.peripheral.identifier,
                name: entry.peripheral.name ?? "ShotStopper",
                rssi: entry.rssi
            )
        }
    }

    private func handleCharacteristicUpdate(uuid: CBUUID, data: Data) {
        if uuid == ShotStopperBLE.Characteristic.goalWeight {
            settings.goalWeight = DeviceSettings.decodeUInt8(from: data)
        }
    }
}
