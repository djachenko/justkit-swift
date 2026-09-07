import Foundation

/// Property wrapper для хранения значений в `UserDefaults`.
///
/// > Warning: `initialValue` **не может быть `nil`**. Для опциональных значений
/// > используй инициализатор без `initialValue`, доступный для `Optional`-типов:
/// > ```swift
/// > @Preference(key: "someKey") var value: String?
/// > ```
@propertyWrapper public struct Preference<Value> {
    public var wrappedValue: Value {
        get { getBlock() }
        set { setBlock(newValue) }
    }

    private let getBlock: () -> Value
    private let setBlock: (Value) -> Void

    public init(key: String, initialValue: Value, userDefaults: UserDefaults = .standard) {
        getBlock = {
            userDefaults.object(forKey: key) as? Value ?? initialValue
        }
        setBlock = { newValue in
            userDefaults.set(newValue, forKey: key)
        }
    }
}

// MARK: - RawRepresentable

public extension Preference where Value: RawRepresentable, Value.RawValue == String {
    init(key: String, initialValue: Value, userDefaults: UserDefaults = .standard) {
        self.init(
            get: {
                guard let raw = userDefaults.string(forKey: key) else {
                    return initialValue
                }
                return Value(rawValue: raw) ?? initialValue
            },
            set: { newValue in
                userDefaults.set(newValue.rawValue, forKey: key)
            }
        )
    }
}

public extension Preference where Value: RawRepresentable, Value.RawValue == Int {
    init(key: String, initialValue: Value, userDefaults: UserDefaults = .standard) {
        self.init(
            get: {
                guard userDefaults.object(forKey: key) != nil else {
                    return initialValue
                }
                return Value(rawValue: userDefaults.integer(forKey: key)) ?? initialValue
            },
            set: { newValue in
                userDefaults.set(newValue.rawValue, forKey: key)
            }
        )
    }
}

// MARK: - Optional

public extension Preference where Value: ExpressibleByNilLiteral {
    init(key: String, userDefaults: UserDefaults = .standard) where Value == Bool? {
        self.init(optionalType: Bool.self, key: key, userDefaults: userDefaults)
    }

    init(key: String, userDefaults: UserDefaults = .standard) where Value == Int? {
        self.init(optionalType: Int.self, key: key, userDefaults: userDefaults)
    }

    init(key: String, userDefaults: UserDefaults = .standard) where Value == Double? {
        self.init(optionalType: Double.self, key: key, userDefaults: userDefaults)
    }

    init(key: String, userDefaults: UserDefaults = .standard) where Value == String? {
        self.init(optionalType: String.self, key: key, userDefaults: userDefaults)
    }

    init(key: String, userDefaults: UserDefaults = .standard) where Value == Data? {
        self.init(optionalType: Data.self, key: key, userDefaults: userDefaults)
    }

    private init<T>(optionalType: T.Type, key: String, userDefaults: UserDefaults) {
        self.init(
            get: {
                userDefaults.object(forKey: key) as? Value ?? nil
            },
            set: { newValue in
                if let newValue = newValue as? T? {
                    userDefaults.set(newValue, forKey: key)
                } else {
                    userDefaults.removeObject(forKey: key)
                }
            }
        )
    }
}

// MARK: - Private

private extension Preference {
    init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        getBlock = get
        setBlock = set
    }
}
