import SwiftUI

struct ContentView: View {
    @Environment(DeviceViewModel.self) private var viewModel

    var body: some View {
        switch viewModel.connectionState {
        case .connected:
            DashboardView()
        default:
            ScanningView()
        }
    }
}
