import CoreGraphics
import Foundation
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

@Test func distanceFromOrigin() {
    #expect(CGPoint(x: 3, y: 4).distance == 5)
    #expect(CGPoint.zero.distance == 0)
}

@Test func rectCenter() {
    #expect(CGRect(x: 0, y: 0, width: 10, height: 20).center == CGPoint(x: 5, y: 10))
    #expect(CGRect(x: 10, y: 10, width: 10, height: 10).center == CGPoint(x: 15, y: 15))
}

@Test func minutesAreSeconds() {
    #expect(TimeInterval.minutes(1) == 60)
    #expect(TimeInterval.minutes(0.5) == 30)
}

@Test func sortedIsStableOnEqualKeys() {
    let words = ["bb", "aa", "c"]

    #expect(words.sorted(by: \.count) == ["c", "bb", "aa"])
}

@Test func minMaxOfEmptyCollectionIsNil() {
    let empty: [String] = []

    #expect(empty.min(by: \.count) == nil)
    #expect(empty.max(by: \.count) == nil)
}
