import SwiftUI

struct SettingsView: View {
    @Environment(DeviceViewModel.self) private var viewModel

    var body: some View {
        Form {
            Section {
                Button("Disconnect", role: .destructive) {
                    viewModel.disconnect()
                }
            }
        }
        .navigationTitle("Settings")
    }
}
