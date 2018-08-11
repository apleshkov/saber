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
                      rawData: RawData,
                      config: SaberConfiguration) -> ParsedProperty? {
        guard let kind = structure.swiftDeclKind,
            let name = structure.swiftName,
            let typeName = structure.swiftTypeName else {
            return nil
        }
        switch kind {
        case .varInstance:
            guard let parsed = parseType(typeName, config: config) else {
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
    
    private static func parseType(_ rawString: String,
                                  config: SaberConfiguration) -> (type: ParsedTypeUsage, isLazy: Bool)? {
        if let type = TypeUsageParser.parse(rawString) {
            guard type.name == config.lazyTypealias, let genericType = type.generics.first else {
                return (type, false)
            }
            return (genericType, true)
        }
        if let lambda = LambdaParser.parse(rawString), let returnType = lambda.returnType {
            return (returnType, true)
        }
        return nil
    }
}
