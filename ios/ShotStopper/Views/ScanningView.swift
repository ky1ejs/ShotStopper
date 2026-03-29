import SwiftUI

struct ScanningView: View {
    @Environment(DeviceViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "wave.3.right")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                Text("ShotStopper")
                    .font(.largeTitle.bold())

                switch viewModel.connectionState {
                case .bluetoothOff:
                    Label("Bluetooth is turned off", systemImage: "bluetooth.slash")
                        .foregroundStyle(.red)
                    Text("Turn on Bluetooth in Settings to connect to your ShotStopper.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                case .unauthorized:
                    Label("Bluetooth access not authorized", systemImage: "lock.shield")
                        .foregroundStyle(.orange)
                    Text("Allow Bluetooth access in Settings to use ShotStopper.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                case .scanning:
                    ProgressView("Scanning for devices...")

                case .connecting:
                    ProgressView("Connecting...")

                default:
                    Button {
                        viewModel.startScanning()
                    } label: {
                        Label("Scan for Devices", systemImage: "magnifyingglass")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                if !viewModel.discoveredDevices.isEmpty {
                    List(viewModel.discoveredDevices) { device in
                        Button {
                            viewModel.connect(to: device)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(device.name)
                                        .font(.headline)
                                    Text(device.id.uuidString.prefix(8) + "...")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(device.rssi) dBm")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
