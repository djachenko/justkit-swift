import Swinject
import Testing
@testable import JustKitDI

private final class Leaf {
    let id: String

    init() {
        self.id = "leaf"
    }
}

private final class Branch {
    let leaf: Leaf

    init(leaf: Leaf) {
        self.leaf = leaf
    }
}

private final class Trunk {
    let branch: Branch
    let leaf: Leaf

    init(branch: Branch, leaf: Leaf) {
        self.branch = branch
        self.leaf = leaf
    }
}

private protocol Greeter {
    var greeting: String { get }
}

private final class GreeterImpl: Greeter {
    let greeting = "hello"

    init() {}
}

@Test func autoregisterTakesArgumentsOffTheInitializer() {
    let container = Container()
    container.autoregister(Leaf.init)
    container.autoregister(Branch.init)
    container.autoregister(Trunk.init)

    let trunk = container.resolve(Trunk.self)

    #expect(trunk != nil)
    #expect(trunk?.branch.leaf.id == "leaf")
}

@Test func autoregisterHandlesAnEmptyParameterPack() {
    let container = Container()
    container.autoregister(GreeterImpl.init)

    #expect(container.resolve(GreeterImpl.self)?.greeting == "hello")
}

@Test func autoregisterReturnsAnEntryThatAcceptsScopeAndImplements() {
    let container = Container()
    container.autoregister(Leaf.init)
        .inObjectScope(.container)

    let first = container.resolve(Leaf.self)
    let second = container.resolve(Leaf.self)

    #expect(first === second)
}
