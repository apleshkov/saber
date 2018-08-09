//
//  MethodParser.swift
//  Saber
//
//  Created by Andrew Pleshkov on 22/05/2018.
//

import Foundation
import SourceKittenFramework

class MethodParser {
    
    static func parse(_ structure: [String : SourceKitRepresentable],
                      rawData: RawData,
                      config: SaberConfiguration) -> ParsedMethod? {
        guard let kind = structure.swiftDeclKind,
            let rawName = structure.swiftName else {
            return nil
        }
        switch kind {
        case .functionMethodInstance, .functionMethodStatic, .functionMethodClass:
            let name: String
            if let index = rawName.index(of: "(") {
                name = String(rawName[..<index])
            } else {
                name = rawName
            }
            let args = parseArgs(structure, config: config)
            let returnType = parseType(structure, config: config)?.type
            let isStatic = (kind == .functionMethodStatic || kind == .functionMethodClass)
            var isFailableInitializer = false
            if name == "init" {
                let flag = StringExtractor
                    .name
                    .extract(from: structure, contents: rawData.contents)?
                    .starts(with: "init?")
                isFailableInitializer = (flag == true)
            }
            return ParsedMethod(
                name: name,
                args: args,
                returnType: returnType,
                isStatic: isStatic,
                accessLevel: structure.swiftAccessLevel,
                annotations: rawData
                    .annotations(for: structure)
                    .compactMap { MethodAnnotationParser.parse($0) },
                isFailableInitializer: isFailableInitializer
            )
        default:
            return nil
        }
    }
    
    static func parseArgs(_ structure: [String : SourceKitRepresentable],
                          config: SaberConfiguration) -> [ParsedArgument] {
        return (structure.swiftSubstructures ?? []).compactMap { (structure) in
            guard let kind = structure.swiftDeclKind else {
                return nil
            }
            switch kind {
            case .varParameter:
                let name: String?
                if let nameLength = structure[SwiftDocKey.nameLength] as? Int64, nameLength > 0 {
                    name = structure.swiftName
                } else {
                    name = nil
                }
                guard let parsed = parseType(structure, config: config) else {
                    return nil
                }
                return ParsedArgument(name: name, type: parsed.type, isLazy: parsed.isLazy)
            default:
                return nil
            }
        }
    }
    
    static func parseType(_ structure: [String : SourceKitRepresentable],
                          config: SaberConfiguration) -> (type: ParsedTypeUsage, isLazy: Bool)? {
        guard let rawType = structure.swiftTypeName else {
            return nil
        }
        if let type = TypeUsageParser.parse(rawType) {
            guard type.name == config.lazyTypealias, let genericType = type.generics.first else {
                return (type, false)
            }
            return (genericType, true)
        }
        if let lambda = LambdaParser.parse(rawType), let returnType = lambda.returnType {
            return (returnType, true)
        }
        return nil
    }
}
