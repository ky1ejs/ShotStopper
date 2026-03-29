import Testing
@testable import ShotStopper

@Test func deviceSettingsDefaults() async throws {
    let settings = DeviceSettings()
    #expect(settings.goalWeight == 36)
}
