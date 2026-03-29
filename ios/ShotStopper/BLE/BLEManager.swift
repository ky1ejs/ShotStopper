@preconcurrency import CoreBluetooth
import Foundation

@MainActor
final class BLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var characteristics: [CBUUID: CBCharacteristic] = [:]

    private(set) var centralState: CBManagerState = .unknown
    private(set) var discoveredPeripherals: [(peripheral: CBPeripheral, rssi: Int)] = []
    private(set) var connectedPeripheral: CBPeripheral?

    var isScanning: Bool { centralManager.isScanning }
    var isConnected: Bool { connectedPeripheral != nil }
    var onStateChange: (() -> Void)?
    var onCharacteristicUpdate: ((CBUUID, Data) -> Void)?
    var onConnectionChange: ((Bool) -> Void)?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - Scanning

    func startScanning() {
        guard centralState == .poweredOn else { return }
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(
            withServices: [ShotStopperBLE.serviceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    func stopScanning() {
        centralManager.stopScan()
    }

    // MARK: - Connection

    func connect(to peripheral: CBPeripheral) {
        stopScanning()
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - Read / Write

    func readValue(for uuid: CBUUID) {
        guard let peripheral = connectedPeripheral,
              let characteristic = characteristics[uuid] else { return }
        peripheral.readValue(for: characteristic)
    }

    func writeValue(_ data: Data, for uuid: CBUUID) {
        guard let peripheral = connectedPeripheral,
              let characteristic = characteristics[uuid] else {
            print("[BLE] Write failed: no peripheral or characteristic not found for \(uuid)")
            return
        }

        let type: CBCharacteristicWriteType
        if characteristic.properties.contains(.write) {
            type = .withResponse
        } else if characteristic.properties.contains(.writeWithoutResponse) {
            type = .withoutResponse
        } else {
            print("[BLE] Write failed: characteristic \(uuid) does not support writing (properties: \(characteristic.properties))")
            return
        }

        print("[BLE] Writing \(data.map { String(format: "%02x", $0) }.joined()) to \(uuid) (type: \(type == .withResponse ? "withResponse" : "withoutResponse"))")
        peripheral.writeValue(data, for: characteristic, type: type)
    }

    func peripheral(for device: DiscoveredDevice) -> CBPeripheral? {
        discoveredPeripherals.first { $0.peripheral.identifier == device.id }?.peripheral
    }

    // MARK: - CBCentralManagerDelegate

    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        MainActor.assumeIsolated {
            centralState = central.state
            onStateChange?()
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        MainActor.assumeIsolated {
            let exists = discoveredPeripherals.contains { $0.peripheral.identifier == peripheral.identifier }
            if !exists {
                discoveredPeripherals.append((peripheral: peripheral, rssi: RSSI.intValue))
                onStateChange?()
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        MainActor.assumeIsolated {
            connectedPeripheral = peripheral
            peripheral.discoverServices(nil)
            onConnectionChange?(true)
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        MainActor.assumeIsolated {
            connectedPeripheral = nil
            characteristics.removeAll()
            onConnectionChange?(false)
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        MainActor.assumeIsolated {
            connectedPeripheral = nil
            characteristics.removeAll()
            onConnectionChange?(false)
        }
    }

    // MARK: - CBPeripheralDelegate

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        MainActor.assumeIsolated {
            guard let services = peripheral.services else { return }
            for service in services {
                print("[BLE] Discovered service \(service.uuid)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: (any Error)?
    ) {
        MainActor.assumeIsolated {
            guard let chars = service.characteristics else { return }
            for characteristic in chars {
                characteristics[characteristic.uuid] = characteristic
                print("[BLE] Discovered characteristic \(characteristic.uuid) properties: \(characteristic.properties)")

                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }

                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
            }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        MainActor.assumeIsolated {
            if let error {
                print("[BLE] Read error for \(characteristic.uuid): \(error)")
                return
            }
            guard let data = characteristic.value else { return }
            print("[BLE] Read \(characteristic.uuid): \(data.map { String(format: "%02x", $0) }.joined())")
            onCharacteristicUpdate?(characteristic.uuid, data)
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        MainActor.assumeIsolated {
            if let error {
                print("[BLE] Write error for \(characteristic.uuid): \(error)")
                return
            }
            print("[BLE] Write confirmed for \(characteristic.uuid), re-reading...")
            peripheral.readValue(for: characteristic)
        }
    }
}
