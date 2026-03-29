import SwiftUI

@main
struct ShotStopperApp: App {
    @State private var viewModel = DeviceViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
