//
//  TypeParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 21/05/2018.
//

import Foundation
import SourceKittenFramework

class TypeParser {

    static func parse(_ structure: [String : SourceKitRepresentable],
                      rawData: RawData) -> ParsedType? {
        guard let kind = structure.swiftDeclKind, let name = structure.swiftName else {
            return nil
        }
        switch kind {
        case .struct, .class:
            let isReference = (kind == .class)
            var type = ParsedType(name: name, isReference: isReference)
            structure.swiftSubstructures?.forEach {
                if let nestedType = TypeParser.parse($0, rawData: rawData) {
                    type.nested.append(.type(nestedType))
                }
                if let nestedExtension = ExtensionParser.parse($0, rawData: rawData) {
                    type.nested.append(.extension(nestedExtension))
                }
                if let nestedTypealias = TypealiasParser.parse($0, rawData: rawData) {
                    type.nested.append(.typealias(nestedTypealias))
                }
                if let method = MethodParser.parse($0, rawData: rawData) {
                    type.methods.append(method)
                }
                if let property = PropertyParser.parse($0, rawData: rawData) {
                    type.properties.append(property)
                }
            }
            type.annotations = rawData
                .annotations(for: structure)
                .compactMap { TypeAnnotationParser.parse($0) }
            return type
        default:
            return nil
        }
    }
}
