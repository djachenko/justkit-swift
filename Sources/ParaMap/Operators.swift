import Swinject

/// Resolves a service with runtime values, e.g. `resolver ~> (DetailViewModel.self, with: id)`.
///
/// Traps when the service cannot be resolved: a missing registration is a wiring mistake,
/// not a runtime condition to recover from.
public func ~> <T, A>(resolver: Resolver, pair: (T.Type, with: A)) -> T {
    resolved(pair.0, from: resolver, params: ParaMap(pair.1))
}

public func ~> <T, A, B>(resolver: Resolver, pair: (T.Type, with: A, B)) -> T {
    resolved(pair.0, from: resolver, params: ParaMap(pair.1, pair.2))
}

// Кортеж здесь — форма вызова, а не структура данных: (Тип, with: значения).
// swiftlint:disable:next large_tuple
public func ~> <T, A, B, C>(resolver: Resolver, pair: (T.Type, with: A, B, C)) -> T {
    resolved(pair.0, from: resolver, params: ParaMap(pair.1, pair.2, pair.3))
}

// swiftlint:disable:next large_tuple
public func ~> <T, A, B, C, D>(resolver: Resolver, pair: (T.Type, with: A, B, C, D)) -> T {
    resolved(pair.0, from: resolver, params: ParaMap(pair.1, pair.2, pair.3, pair.4))
}

// swiftlint:disable:next large_tuple
public func ~> <T, A, B, C, D, E>(resolver: Resolver, pair: (T.Type, with: A, B, C, D, E)) -> T {
    resolved(pair.0, from: resolver, params: ParaMap(pair.1, pair.2, pair.3, pair.4, pair.5))
}

private func resolved<T>(_ type: T.Type, from resolver: Resolver, params: ParaMap) -> T {
    guard let value = resolver.resolve(type, params: params) else {
        fatalError("Swinject: failed to resolve \(T.self)")
    }

    return value
}
