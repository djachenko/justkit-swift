import Foundation

public extension Decodable {
    static func fromJson(name: String, bundle: Bundle = .main) throws -> Self {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }

        return try fromJson(at: url)
    }

    static func fromJson(at url: URL) throws -> Self {
        let data = try Data(contentsOf: url)

        return try JSONDecoder().decode(Self.self, from: data)
    }
}
