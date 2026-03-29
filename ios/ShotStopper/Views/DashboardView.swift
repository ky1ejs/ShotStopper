import SwiftUI

struct DashboardView: View {
    @Environment(DeviceViewModel.self) private var viewModel

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 32) {
                // Scale status
                HStack {
                    Circle()
                        .fill(scaleStatusColor)
                        .frame(width: 10, height: 10)
                    Text("Scale: \(viewModel.scaleStatus.description)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

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

                // Brewing indicator
                if viewModel.isBrewing {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Brewing...")
                            .font(.title3.bold())
                    }
                    .foregroundStyle(.green)
                }

                Spacer()

                // Enable toggle
                Button {
                    viewModel.updateEnabled(!viewModel.settings.enabled)
                } label: {
                    Text(viewModel.settings.enabled ? "Enabled" : "Disabled")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.settings.enabled ? .green : .gray)
                .controlSize(.large)
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

    private var scaleStatusColor: Color {
        switch viewModel.scaleStatus {
        case .disconnected: .red
        case .searching: .yellow
        case .connected: .green
        }
    }
}
