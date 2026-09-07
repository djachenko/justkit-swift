import Testing
@testable import JustKit

@Test func clampedKeepsValueInsideRange() {
    #expect(5.clamped(to: 0...10) == 5)
    #expect((-1).clamped(to: 0...10) == 0)
    #expect(11.clamped(to: 0...10) == 10)
}

@Test func clampedToHalfOpenRangeExcludesUpperBound() {
    #expect(11.clamped(to: 0..<10) == 9)
    #expect(3.clamped(to: 0..<0) == 0)
}

@Test func minMaxByKey() {
    let words = ["bb", "a", "ccc"]

    #expect(words.min(by: \.count) == "a")
    #expect(words.max(by: \.count) == "ccc")
    #expect(words.sorted(by: \.count) == ["a", "bb", "ccc"])
    #expect(words.sorted(by: \.count, reverse: true) == ["ccc", "bb", "a"])
}

@Test func removingSuffix() {
    #expect("file.json".removing(suffix: ".json") == "file")
    #expect("file.json".removing(suffix: ".txt") == "file.json")
}
