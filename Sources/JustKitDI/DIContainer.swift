import SwiftUI
import Swinject

private struct DIContainerKey: EnvironmentKey {
    // Container синхронизирован внутри себя, а defaultValue — заглушка,
    // которую перекрывает .environment(\.diContainer, ...) на старте приложения.
    nonisolated(unsafe) static let defaultValue: Resolver = Container()
}

public extension EnvironmentValues {
    var diContainer: Resolver {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}
