//
//  Dictionary+Structure.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation
import SourceKittenFramework

extension Dictionary where Key == String, Value == SourceKitRepresentable {

    subscript(key: SwiftDocKey) -> SourceKitRepresentable? {
        return self[key.rawValue]
    }

    var swiftDeclKind: SwiftDeclarationKind? {
        return (self[SwiftDocKey.kind] as? String).flatMap { SwiftDeclarationKind(rawValue: $0) }
    }

    var swiftName: String? {
        return self[SwiftDocKey.name] as? String
    }

    var swiftTypeName: String? {
        return self[SwiftDocKey.typeName] as? String
    }

    var swiftSubstructures: [[String: SourceKitRepresentable]]? {
        return self[SwiftDocKey.substructure] as? [[String: SourceKitRepresentable]]
    }

    var swiftInherited: [[String: SourceKitRepresentable]]? {
        return self[SwiftDocKey.inheritedtypes] as? [[String: SourceKitRepresentable]]
    }

    var swiftAccessLevel: String? {
        guard let raw = self["key.accessibility"] as? String else {
            return nil
        }
        let prefix = "source.lang.swift.accessibility."
        return raw.replacingOccurrences(of: prefix, with: "")
    }
}
