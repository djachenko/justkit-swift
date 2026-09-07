import Swinject
import Testing
@testable import JustKitDI

private enum Category: String, ServiceKeyOption {
    case feed
    case detail

    var description: String {
        rawValue
    }

    func isEqualTo(_ another: ServiceKeyOption) -> Bool {
        another as? Self == self
    }
}

private protocol Logger {
    var category: String { get }
}

private final class LoggerImpl: Logger {
    let category: String

    init(category: String) {
        self.category = category
    }
}

private final class FeedLogger: Logger {
    let category = "feed"

    init() {}
}

private final class DetailLogger: Logger {
    let category = "detail"

    init() {}
}

@Test func sameTypeUnderDifferentKeysResolvesIndependently() {
    let container = Container()
    container.autoregister(Logger.self, key: Category.feed, initializer: FeedLogger.init)
    container.autoregister(Logger.self, key: Category.detail, initializer: DetailLogger.init)

    let feed: Logger = container ~> Category.feed
    let detail: Logger = container ~> Category.detail

    #expect(feed.category == "feed")
    #expect(detail.category == "detail")
}

@Test func keyedRegistrationDoesNotAnswerAPlainResolve() {
    let container = Container()
    container.autoregister(Logger.self, key: Category.feed, initializer: FeedLogger.init)

    // Ключ участвует в хэше и равенстве ServiceKey наравне с типом, поэтому
    // резолв без ключа регистрацию не видит.
    #expect(container.resolve(Logger.self) == nil)
}

@Test func keyedAndPlainRegistrationsOfOneTypeCoexist() {
    let container = Container()
    container.autoregister(Logger.self, key: Category.feed, initializer: FeedLogger.init)
    container.autoregister(DetailLogger.init)
        .implements(Logger.self)

    let keyed: Logger = container ~> Category.feed

    #expect(keyed.category == "feed")
    #expect(container.resolve(Logger.self)?.category == "detail")
}

@Test func keyedEntryAcceptsObjectScope() {
    let container = Container()
    container.autoregister(Logger.self, key: Category.feed, initializer: FeedLogger.init)
        .inObjectScope(.container)

    let first: Logger = container ~> Category.feed
    let second: Logger = container ~> Category.feed

    #expect(first as AnyObject === second as AnyObject)
}
