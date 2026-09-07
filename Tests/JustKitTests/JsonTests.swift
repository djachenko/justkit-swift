import Foundation
@testable import JustKit
import Testing

private struct Config: Codable, Equatable {
    let name: String
    let capacity: Int
}

@Test func jsonRoundTripThroughAFile() throws {
    let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
    defer { try? FileManager.default.removeItem(at: url) }

    let config = Config(name: "C-41", capacity: 10)
    try config.toJson(at: url)

    #expect(try Config.fromJson(at: url) == config)
}

@Test func missingBundleResourceThrows() {
    #expect(throws: URLError.self) {
        try Config.fromJson(name: "no-such-resource", bundle: .main)
    }
}

@Test func malformedJsonThrows() throws {
    let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
    defer { try? FileManager.default.removeItem(at: url) }

    try Data("{ not json".utf8).write(to: url)

    #expect(throws: (any Error).self) {
        try Config.fromJson(at: url)
    }
}

@Test func toJsonOverwritesAnExistingFile() throws {
    let url = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
    defer { try? FileManager.default.removeItem(at: url) }

    try Config(name: "old", capacity: 1).toJson(at: url)
    try Config(name: "new", capacity: 2).toJson(at: url)

    #expect(try Config.fromJson(at: url) == Config(name: "new", capacity: 2))
}
