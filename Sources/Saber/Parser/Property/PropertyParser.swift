//
//  VariableParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 23/05/2018.
//

import Foundation
import SourceKittenFramework

class PropertyParser {

    static func parse(_ structure: [String : SourceKitRepresentable],
                      rawData: RawData) -> ParsedProperty? {
        guard let kind = structure.swiftDeclKind,
            let name = structure.swiftName,
            let typeName = structure.swiftTypeName else {
            return nil
        }
        switch kind {
        case .varInstance:
            guard let parsed = parseType(typeName) else {
                return nil
            }
            let annotations = rawData
                .annotations(for: structure)
                .compactMap { PropertyAnnotationParser.parse($0) }
            return ParsedProperty(
                name: name,
                type: parsed.type,
                accessLevel: structure.swiftAccessLevel,
                annotations: annotations,
                isLazy: parsed.isLazy
            )
        default:
            return nil
        }
    }
    
    private static func parseType(_ rawString: String) -> (type: ParsedTypeUsage, isLazy: Bool)? {
        if let type = TypeUsageParser.parse(rawString) {
            return (type, false)
        }
        if let lambda = LambdaParser.parse(rawString), let returnType = lambda.returnType {
            return (returnType, true)
        }
        return nil
    }
}
