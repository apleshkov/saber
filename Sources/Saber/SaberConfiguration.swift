import Foundation
import Yams

public struct SaberConfiguration: Equatable {

    public var accessLevel = "internal"
    
    public var indent = "    "
    
    public init() {}
}

extension SaberConfiguration {

    public static let `default` = SaberConfiguration()
}

extension SaberConfiguration: Decodable {

    private enum CodingKeys: String, CodingKey {
        case accessLevel
        case indentation
    }

    private enum IndentationKeys: String, CodingKey {
        case type
        case size
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let accessLevel = try? values.decode(String.self, forKey: .accessLevel) {
            self.accessLevel = accessLevel
        }
        if let indentation = try? values.nestedContainer(keyedBy: IndentationKeys.self, forKey: .indentation) {
            let rawType = try indentation.decode(String.self, forKey: .type)
            guard let type = IdentationType(rawValue: rawType) else {
                throw Throwable.message("Invalid identation type: '\(rawType)'")
            }
            let char = type.char
            let size = try indentation.decode(Int.self, forKey: .size)
            self.indent = (0..<size).map { _ in char }.joined()
        }
    }

    private enum IdentationType: String {
        case space
        case tab

        var char: String {
            switch self {
            case .space:
                return " "
            case .tab:
                return "\t"
            }
        }
    }
}
