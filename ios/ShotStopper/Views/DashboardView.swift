import SwiftUI

struct DashboardView: View {
    @Environment(DeviceViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Goal weight
                VStack(spacing: 8) {
                    Text("Goal Weight")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.settings.goalWeight)g")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                    Stepper(
                        "Goal Weight",
                        value: Binding(
                            get: { Int(viewModel.settings.goalWeight) },
                            set: { viewModel.updateGoalWeight(UInt8(clamping: $0)) }
                        ),
                        in: 1...99
                    )
                    .labelsHidden()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("ShotStopper")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
