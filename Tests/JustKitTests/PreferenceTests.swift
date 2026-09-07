import Foundation
@testable import JustKit
import Testing

private enum Theme: String {
    case light
    case dark
}

private enum Level: Int {
    case low = 1
    case high = 2
}

private func makeDefaults(_ name: String = #function) -> UserDefaults {
    let defaults = UserDefaults(suiteName: "JustKitTests.\(name)")!
    defaults.removePersistentDomain(forName: "JustKitTests.\(name)")

    return defaults
}

@Test func initialValueIsReturnedUntilSomethingIsWritten() {
    let defaults = makeDefaults()

    @Preference(key: "tankSize", initialValue: 5, userDefaults: defaults) var tankSize: Int

    #expect(tankSize == 5)

    tankSize = 7

    #expect(tankSize == 7)
    #expect(defaults.integer(forKey: "tankSize") == 7)
}

@Test func valueSurvivesANewWrapperOverTheSameKey() {
    let defaults = makeDefaults()

    do {
        @Preference(key: "shared", initialValue: "a", userDefaults: defaults) var value: String
        value = "b"
    }

    @Preference(key: "shared", initialValue: "a", userDefaults: defaults) var value: String

    #expect(value == "b")
}

@Test func rawRepresentableStringRoundTrip() {
    let defaults = makeDefaults()

    @Preference(key: "theme", initialValue: Theme.light, userDefaults: defaults) var theme: Theme

    #expect(theme == .light)

    theme = .dark

    #expect(theme == .dark)
    // Хранится сырым значением, а не архивом — читаемо в plist и совместимо с чужим кодом.
    #expect(defaults.string(forKey: "theme") == "dark")
}

@Test func rawRepresentableIntRoundTrip() {
    let defaults = makeDefaults()

    @Preference(key: "level", initialValue: Level.low, userDefaults: defaults) var level: Level

    #expect(level == .low)

    level = .high

    #expect(level == .high)
    #expect(defaults.integer(forKey: "level") == 2)
}

@Test func unknownRawValueFallsBackToInitial() {
    let defaults = makeDefaults()
    defaults.set("teal", forKey: "theme")

    @Preference(key: "theme", initialValue: Theme.light, userDefaults: defaults) var theme: Theme

    #expect(theme == .light)
}

@Test func optionalStartsNil() {
    let defaults = makeDefaults()

    @Preference(key: "remoteURL", userDefaults: defaults) var remoteURL: String?

    #expect(remoteURL == nil)

    remoteURL = "https://example.com"

    #expect(remoteURL == "https://example.com")
}

@Test func optionalSetToNilRemovesTheKey() {
    let defaults = makeDefaults()

    @Preference(key: "remoteURL", userDefaults: defaults) var remoteURL: String?
    remoteURL = "https://example.com"

    remoteURL = nil

    #expect(remoteURL == nil)
    #expect(defaults.object(forKey: "remoteURL") == nil)
}

@Test func optionalBoolDistinguishesFalseFromUnset() {
    let defaults = makeDefaults()

    @Preference(key: "flag", userDefaults: defaults) var flag: Bool?

    #expect(flag == nil)

    flag = false

    // Ради этого опциональная форма и существует: defaults.bool(forKey:) вернул бы
    // false в обоих случаях.
    #expect(flag == false)
}

@Test func optionalDataRoundTrip() {
    let defaults = makeDefaults()
    let payload = Data([0x01, 0x02, 0x03])

    @Preference(key: "payload", userDefaults: defaults) var stored: Data?
    stored = payload

    #expect(stored == payload)
}
