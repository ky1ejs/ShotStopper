@preconcurrency import CoreBluetooth
import SwiftUI

@MainActor
@Observable
final class DeviceViewModel {
    private let bleManager = BLEManager()

    var connectionState: ConnectionState = .disconnected
    var discoveredDevices: [DiscoveredDevice] = []
    var settings = DeviceSettings()
    var firmwareVersion: UInt8 = 0
    var scaleStatus: ScaleStatus = .disconnected
    var isBrewing: Bool = false
    var wifiSSID: String = ""
    var wifiIP: String = ""

    init() {
        bleManager.onStateChange = { [weak self] in
            self?.syncState()
        }
        bleManager.onConnectionChange = { [weak self] connected in
            self?.connectionState = connected ? .connected : .disconnected
            if !connected {
                self?.settings = DeviceSettings()
                self?.firmwareVersion = 0
                self?.scaleStatus = .disconnected
                self?.isBrewing = false
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

    // MARK: - Settings Updates

    func updateGoalWeight(_ weight: UInt8) {
        let previous = settings.goalWeight
        settings.goalWeight = weight
        bleManager.writeValue(DeviceSettings.encodeUInt8(weight), for: ShotStopperBLE.Characteristic.goalWeight)
        // Rollback would require didWriteValueFor delegate callback - keeping simple for bootstrap
        _ = previous
    }

    func updateEnabled(_ enabled: Bool) {
        settings.enabled = enabled
        bleManager.writeValue(DeviceSettings.encodeBool(enabled), for: ShotStopperBLE.Characteristic.enabled)
    }

    func updateAutoTare(_ value: Bool) {
        settings.autoTare = value
        bleManager.writeValue(DeviceSettings.encodeBool(value), for: ShotStopperBLE.Characteristic.autoTare)
    }

    func updateMomentary(_ value: Bool) {
        settings.momentary = value
        bleManager.writeValue(DeviceSettings.encodeBool(value), for: ShotStopperBLE.Characteristic.momentary)
    }

    func updateReedSwitch(_ value: Bool) {
        settings.reedSwitch = value
        bleManager.writeValue(DeviceSettings.encodeBool(value), for: ShotStopperBLE.Characteristic.reedSwitch)
    }

    func updateMinShotDuration(_ value: UInt8) {
        settings.minShotDuration = value
        bleManager.writeValue(DeviceSettings.encodeUInt8(value), for: ShotStopperBLE.Characteristic.minShotDuration)
    }

    func updateMaxShotDuration(_ value: UInt8) {
        settings.maxShotDuration = value
        bleManager.writeValue(DeviceSettings.encodeUInt8(value), for: ShotStopperBLE.Characteristic.maxShotDuration)
    }

    func updateDripDelay(_ value: UInt8) {
        settings.dripDelay = value
        bleManager.writeValue(DeviceSettings.encodeUInt8(value), for: ShotStopperBLE.Characteristic.dripDelay)
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
        switch uuid {
        case ShotStopperBLE.Characteristic.enabled:
            settings.enabled = DeviceSettings.decodeBool(from: data)
        case ShotStopperBLE.Characteristic.goalWeight:
            settings.goalWeight = DeviceSettings.decodeUInt8(from: data)
        case ShotStopperBLE.Characteristic.reedSwitch:
            settings.reedSwitch = DeviceSettings.decodeBool(from: data)
        case ShotStopperBLE.Characteristic.momentary:
            settings.momentary = DeviceSettings.decodeBool(from: data)
        case ShotStopperBLE.Characteristic.autoTare:
            settings.autoTare = DeviceSettings.decodeBool(from: data)
        case ShotStopperBLE.Characteristic.minShotDuration:
            settings.minShotDuration = DeviceSettings.decodeUInt8(from: data)
        case ShotStopperBLE.Characteristic.maxShotDuration:
            settings.maxShotDuration = DeviceSettings.decodeUInt8(from: data)
        case ShotStopperBLE.Characteristic.dripDelay:
            settings.dripDelay = DeviceSettings.decodeUInt8(from: data)
        case ShotStopperBLE.Characteristic.firmwareVersion:
            firmwareVersion = DeviceSettings.decodeUInt8(from: data)
        case ShotStopperBLE.Characteristic.scaleStatus:
            scaleStatus = ScaleStatus(rawValue: DeviceSettings.decodeUInt8(from: data)) ?? .disconnected
        case ShotStopperBLE.Characteristic.shotStatus:
            isBrewing = DeviceSettings.decodeBool(from: data)
        case ShotStopperBLE.Characteristic.wifiSSID:
            wifiSSID = DeviceSettings.decodeString(from: data)
        case ShotStopperBLE.Characteristic.wifiIP:
            wifiIP = DeviceSettings.decodeString(from: data)
        default:
            break
        }
    }
}
