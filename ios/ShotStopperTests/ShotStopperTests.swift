import Testing
@testable import ShotStopper

@Test func deviceSettingsDefaults() async throws {
    let settings = DeviceSettings()
    #expect(settings.goalWeight == 36)
    #expect(settings.enabled == false)
    #expect(settings.minShotDuration == 5)
    #expect(settings.maxShotDuration == 60)
    #expect(settings.dripDelay == 3)
}
