@testable import ParaMap
import Swinject
import Testing

private final class Dependency {
    let id: String

    init(id: String) {
        self.id = id
    }
}

private final class Service {
    let dependency: Dependency
    let title: String

    init(dependency: Dependency, title: String) {
        self.dependency = dependency
        self.title = title
    }
}

@Test func passedValueReachesTheResolvedService() {
    let container = Container()
    container.register(Dependency.self) { _ in Dependency(id: "shared") }
    container.register(Service.self) { r in
        Service(dependency: r.resolve(Dependency.self)!, title: r.resolve(String.self)!)
    }

    let service: Service = container ~> (Service.self, with: "passed")

    #expect(service.title == "passed")
    #expect(service.dependency.id == "shared")
}

@Test func passedValuesDoNotLeakIntoTheParentContainer() {
    let container = Container()
    container.register(Service.self) { r in
        Service(dependency: Dependency(id: "x"), title: r.resolve(String.self)!)
    }

    _ = container ~> (Service.self, with: "passed")

    #expect(container.resolve(String.self) == nil)
}

@Test func severalValuesAreKeyedByTheirTypes() {
    let container = Container()
    container.register(Service.self) { r in
        Service(dependency: r.resolve(Dependency.self)!, title: r.resolve(String.self)!)
    }

    let service: Service = container ~> (Service.self, with: "passed", Dependency(id: "passed too"))

    #expect(service.title == "passed")
    #expect(service.dependency.id == "passed too")
}

@Test func resolveReturnsNilWhenTheServiceIsNotRegistered() {
    let container = Container()

    #expect(container.resolve(Service.self, params: ParaMap("passed")) == nil)
}

private final class Wide {
    let values: [String]

    init(a: String, b: Int, c: Double, d: Bool, e: Dependency) {
        values = ["\(a)", "\(b)", "\(c)", "\(d)", e.id]
    }
}

private final class ResolverHolder {
    let resolvedTitle: String

    init(resolver: Resolver) {
        resolvedTitle = resolver.resolve(String.self) ?? "missing"
    }
}

@Test func lastValueOfATypeWins() {
    let container = Container()
    container.register(Service.self) { r in
        Service(dependency: Dependency(id: "x"), title: r.resolve(String.self)!)
    }

    var params = ParaMap("first")
    params.set("second")

    #expect(container.resolve(Service.self, params: params)?.title == "second")
}

@Test func fiveValuesAreSupported() {
    let container = Container()
    container.register(Wide.self) { r in
        Wide(
            a: r.resolve(String.self)!,
            b: r.resolve(Int.self)!,
            c: r.resolve(Double.self)!,
            d: r.resolve(Bool.self)!,
            e: r.resolve(Dependency.self)!
        )
    }

    let wide: Wide = container ~> (Wide.self, with: "a", 1, 2.5, true, Dependency(id: "dep"))

    #expect(wide.values == ["a", "1", "2.5", "true", "dep"])
}

@Test func resolverInsideTheGraphIsTheChildContainer() {
    let container = Container()
    container.register(ResolverHolder.self) { r in
        ResolverHolder(resolver: r.resolve(Resolver.self)!)
    }

    // Родительский резолвер значения не видит, поэтому "passed" здесь доказывает,
    // что зависимости достаётся именно дочерний контейнер.
    let holder: ResolverHolder = container ~> (ResolverHolder.self, with: "passed")

    #expect(holder.resolvedTitle == "passed")
}

@Test func anEmptyParaMapIsHarmless() {
    let container = Container()
    container.register(Dependency.self) { _ in Dependency(id: "shared") }

    #expect(container.resolve(Dependency.self, params: ParaMap())?.id == "shared")
}
