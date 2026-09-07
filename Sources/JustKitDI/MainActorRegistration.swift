import Foundation
import Swinject

public extension Container {
    /// Registers a service whose initializer is `@MainActor`-isolated.
    ///
    /// The whole point of the isolation erasure below: Swinject factories are nonisolated,
    /// and `MainActor.assumeIsolated` cannot bridge the gap — it hands the value back across
    /// the isolation boundary and so requires `Sendable`, which view models, `ModelContext`
    /// and most other UI-facing types are not, by design.
    ///
    /// - Precondition: resolved from the main thread.
    @discardableResult
    func autoregisterOnMain<S, each A>(
        _ initializer: @escaping @MainActor (repeat each A) -> S
    ) -> ServiceEntry<S> {
        register(S.self) { resolver in
            // The resolver is not Sendable and the closure below is @MainActor, so the
            // capture would otherwise read as sending a value across an isolation boundary.
            nonisolated(unsafe) let resolver = resolver

            return assumingMainActor {
                initializer(repeat resolved((each A).self, from: resolver))
            }
        }
    }

    /// Registers a service built by a `@MainActor`-isolated factory — for values that are
    /// reached rather than constructed, such as `ModelContainer.mainContext`.
    ///
    /// - Precondition: resolved from the main thread.
    @discardableResult
    func registerOnMain<S>(
        _ type: S.Type,
        factory: @escaping @MainActor (Resolver) -> S
    ) -> ServiceEntry<S> {
        register(type) { resolver in
            nonisolated(unsafe) let resolver = resolver

            return assumingMainActor {
                factory(resolver)
            }
        }
    }
}

private func assumingMainActor<T>(_ body: @MainActor () -> T) -> T {
    precondition(
        Thread.isMainThread,
        "A @MainActor service was resolved off the main thread — resolve it from the main thread instead."
    )

    return withoutActuallyEscaping(body) { body in
        unsafeBitCast(body, to: (() -> T).self)()
    }
}
