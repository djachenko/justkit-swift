# JustKit

A personal Swift utility belt — the code that used to live as copy-paste across my
apps and got rewritten from scratch in every new one. Published because depending
on it is easier than copying it, not because the world was waiting for another
extensions package.

Three separate products, so nothing pulls in more than it needs:

| Product | Depends on | What's inside |
|---|---|---|
| `JustKit` | — | Foundation, CoreGraphics and `UserDefaults` conveniences |
| `JustKitDI` | Swinject, SwinjectAutoregistration | what Swinject's autoregistration doesn't cover |
| `ParaMap` | Swinject | resolving a service with runtime values |

## Requirements

iOS 18 / macOS 14, Swift 6 toolchain.

## Installation

```swift
// Package.swift
.package(url: "https://github.com/djachenko/justkit-swift.git", from: "0.1.0")
```

Then depend on the products you actually use:

```swift
.target(name: "MyApp", dependencies: [
    .product(name: "JustKit", package: "justkit-swift"),
    .product(name: "JustKitDI", package: "justkit-swift"),
])
```

## JustKit

Sorting and picking by a key instead of by a closure pair:

```swift
words.min(by: \.count)
words.max(by: \.count)
words.sorted(by: \.count, reverse: true)
```

Clamping, for both closed and half-open ranges:

```swift
value.clamped(to: 0...10)
index.clamped(to: 0..<items.count)   // never returns count
```

JSON without the decoder boilerplate:

```swift
let config = try Config.fromJson(name: "config")      // from the bundle
let backup = try Config.fromJson(at: fileURL)
try config.toJson(at: fileURL)
```

`@Preference` — `UserDefaults` as a property wrapper, with `RawRepresentable`
and optional support:

```swift
@Preference(key: "tankSize", initialValue: 5) var tankSize: Int
@Preference(key: "theme", initialValue: Theme.system) var theme: Theme
@Preference(key: "remoteURL") var remoteURL: String?
```

The optional form has no `initialValue` — that's what makes it optional. Passing
`nil` as an initial value is not expressible, by design. It covers the types
`UserDefaults` stores natively: `Bool?`, `Int?`, `Double?`, `String?`, `Data?`.

Plus `CGPoint.distance`, `CGRect.center`, `String.removing(suffix:)`,
`TimeInterval.minutes(_:)`.

## JustKitDI

`autoregister` without listing the argument types — parameter packs read them off
the initializer:

```swift
container.autoregister(PhotosetService.init)
container.autoregister(FeedViewModel.init)
```

Registration under a typed key rather than a string name. The key lives in
`ServiceKey.option`, so it takes part in the key's hash and equality alongside
the service type:

```swift
container.autoregister(Logger.self, key: LogCategory.feed, initializer: LoggerImpl.init)

let logger: Logger = resolver ~> LogCategory.feed
```

The key is anything conforming to Swinject's `ServiceKeyOption`, which an enum
of your own picks up in a few lines:

```swift
extension LogCategory: ServiceKeyOption {
    public var description: String { rawValue }

    public func isEqualTo(_ another: ServiceKeyOption) -> Bool {
        another as? Self == self
    }
}
```

`@MainActor` initializers, which the plain factories cannot take:

```swift
container.autoregisterOnMain(FeedViewModel.init)
container.registerOnMain(ModelContext.self) { _ in modelContainer.mainContext }
```

Swinject's factories are nonisolated, and `MainActor.assumeIsolated` is no help:
it hands the value back across an isolation boundary and therefore requires
`Sendable`, which view models and `ModelContext` are not, by design. So the
isolation is erased from the closure instead, under a `precondition` that the
resolve really happens on the main thread. Resolve such services from the main
thread — from a SwiftUI `body` or an app entry point, which is where they are
needed anyway.

## ParaMap

Swinject resolves arguments by type and wants them declared in the registration,
which couples every registration in the graph to the arguments its dependencies
happen to need. `ParaMap` takes the other route: the values go into a short-lived
child container, so anything resolved through it sees them as ordinary
dependencies.

```swift
let viewModel: DetailViewModel = resolver ~> (DetailViewModel.self, with: photosetID)
let runner: SessionRunner = resolver ~> (SessionRunner.self, with: session, logCategory)
```

Up to five values, keyed by their static types. The child container lives exactly
as long as the resolve call, so nothing leaks into the parent graph.

## Known rough edges

- **`autoregister` crashes the compiler** when one of the initializer's parameters
  is a closure — `swift-frontend` traps in SIL while emitting a reabstraction
  thunk, with no diagnostic. Register such types explicitly with
  `container.register` until this is resolved.
- **`autoregisterOnMain` erases isolation unsafely.** The `precondition` turns a
  wrong-thread resolve into a loud trap rather than a race, but it is a
  precondition, not a proof.
- `JustKitDI` has no test coverage yet.

## License

MIT
