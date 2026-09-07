import Swinject
import Testing
@testable import ParaMap

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
