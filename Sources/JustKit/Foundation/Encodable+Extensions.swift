import Foundation

public extension Encodable {
    func toJson(at url: URL) throws {
        let data = try JSONEncoder().encode(self)

        try data.write(to: url, options: .atomic)
    }
}
