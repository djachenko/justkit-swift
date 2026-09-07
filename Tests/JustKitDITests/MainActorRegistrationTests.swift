import Swinject
import Testing
@testable import JustKitDI

private final class Settings {
    let tankSize = 5

    init() {}
}

// Не Sendable и изолирован — ровно тот случай, ради которого нужен
// autoregisterOnMain: MainActor.assumeIsolated такое значение вернуть не может.
@MainActor
private final class ViewModel {
    var title = "untitled"

    let settings: Settings

    init(settings: Settings) {
        self.settings = settings
    }
}

@MainActor
private final class Store {
    var isOpen = false

    init() {}
}

@MainActor
@Test func mainActorInitializerIsAutoregistered() {
    let container = Container()
    container.autoregister(Settings.init)
    container.autoregisterOnMain(ViewModel.init)

    let viewModel = container.resolve(ViewModel.self)

    #expect(viewModel != nil)
    #expect(viewModel?.settings.tankSize == 5)
}

@MainActor
@Test func mainActorFactoryIsRegistered() {
    let container = Container()
    let store = Store()

    container.registerOnMain(Store.self) { _ in store }

    #expect(container.resolve(Store.self) === store)
}

@MainActor
@Test func mainActorEntryAcceptsObjectScope() {
    let container = Container()
    container.autoregister(Settings.init)
    container.autoregisterOnMain(ViewModel.init)
        .inObjectScope(.container)

    let first = container.resolve(ViewModel.self)
    first?.title = "changed"

    #expect(container.resolve(ViewModel.self)?.title == "changed")
}

@MainActor
@Test func resolverReachesTheFactory() {
    let container = Container()
    container.autoregister(Settings.init)
    container.registerOnMain(Store.self) { resolver in
        _ = resolver.resolve(Settings.self)

        return Store()
    }

    #expect(container.resolve(Store.self) != nil)
}
