import Swinject

public extension Resolver {
    /// Resolves `type` in a child container holding the values of `params`.
    ///
    /// - Precondition: the receiver is a `Container` — a child container cannot be made
    ///   from an arbitrary `Resolver`.
    func resolve<T>(_ type: T.Type, params: ParaMap) -> T? {
        guard let container = self as? Container else {
            fatalError("Resolver is not a Container — cannot create child for ParaMap")
        }

        let child = Container(parent: container)
        child.register(Resolver.self) { _ in child }
        params.apply(to: child)

        return child.resolve(type)
    }
}
