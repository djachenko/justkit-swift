import Swinject

/// A bag of runtime values to resolve a service with.
///
/// Swinject resolves arguments by *type*, and a registration has to declare them up front:
/// `container.register(Foo.self) { r, id: UUID in ... }`. That couples every registration
/// in the graph to the arguments its dependencies happen to need.
///
/// `ParaMap` takes the other route — the values are registered into a short-lived child
/// container, so anything resolved through it sees them as ordinary dependencies:
///
/// ```swift
/// let viewModel: DetailViewModel = resolver ~> (DetailViewModel.self, with: photosetID)
/// ```
///
/// The child container lives exactly as long as the resolve call, so the values never
/// leak into the parent graph.
public struct ParaMap {
    private var registrators: [(Container) -> Void] = []

    /// Creates a map holding `values`, each keyed by its own static type.
    public init<each A>(_ values: repeat each A) {
        repeat set(each values)
    }

    /// Adds `value`, keyed by its static type. An existing value of that type is replaced.
    public mutating func set<T>(_ value: T) {
        registrators.append { container in
            container.register(T.self) { _ in value }
        }
    }

    /// Registers every held value into `container`.
    public func apply(to container: Container) {
        registrators.forEach { $0(container) }
    }
}
