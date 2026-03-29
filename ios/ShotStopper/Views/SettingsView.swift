import SwiftUI

struct SettingsView: View {
    @Environment(DeviceViewModel.self) private var viewModel

    var body: some View {
        Form {
            Section("Brew Settings") {
                Toggle("Auto Tare", isOn: Binding(
                    get: { viewModel.settings.autoTare },
                    set: { viewModel.updateAutoTare($0) }
                ))
                Toggle("Momentary Switch", isOn: Binding(
                    get: { viewModel.settings.momentary },
                    set: { viewModel.updateMomentary($0) }
                ))
                Toggle("Reed Switch", isOn: Binding(
                    get: { viewModel.settings.reedSwitch },
                    set: { viewModel.updateReedSwitch($0) }
                ))
            }

            Section("Timing") {
                Stepper(
                    "Min Shot Duration: \(viewModel.settings.minShotDuration)s",
                    value: Binding(
                        get: { Int(viewModel.settings.minShotDuration) },
                        set: { viewModel.updateMinShotDuration(UInt8(clamping: $0)) }
                    ),
                    in: 1...15
                )
                Stepper(
                    "Max Shot Duration: \(viewModel.settings.maxShotDuration)s",
                    value: Binding(
                        get: { Int(viewModel.settings.maxShotDuration) },
                        set: { viewModel.updateMaxShotDuration(UInt8(clamping: $0)) }
                    ),
                    in: 30...120
                )
                Stepper(
                    "Drip Delay: \(viewModel.settings.dripDelay)s",
                    value: Binding(
                        get: { Int(viewModel.settings.dripDelay) },
                        set: { viewModel.updateDripDelay(UInt8(clamping: $0)) }
                    ),
                    in: 1...10
                )
            }

            Section("Device Info") {
                LabeledContent("Firmware Version", value: "v\(viewModel.firmwareVersion)")
                LabeledContent("Scale Status", value: viewModel.scaleStatus.description)
                if !viewModel.wifiSSID.isEmpty {
                    LabeledContent("WiFi Network", value: viewModel.wifiSSID)
                }
                if !viewModel.wifiIP.isEmpty {
                    LabeledContent("WiFi IP", value: viewModel.wifiIP)
                }
            }

            Section {
                Button("Disconnect", role: .destructive) {
                    viewModel.disconnect()
                }
            }
        }
        .navigationTitle("Settings")
    }
}
