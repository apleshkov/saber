//
//  ExtensionParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import Foundation
import SourceKittenFramework

class ExtensionParser {

    static func parse(_ structure: [String : SourceKitRepresentable],
                      rawData: RawData,
                      config: SaberConfiguration) -> ParsedExtension? {
        guard let kind = structure.swiftDeclKind, let name = structure.swiftName else {
            return nil
        }
        switch kind {
        case .extension:
            var ext = ParsedExtension(typeName: name)
            structure.swiftSubstructures?.forEach {
                if let nestedType = TypeParser.parse($0, rawData: rawData, config: config) {
                    ext.nested.append(.type(nestedType))
                }
                if let nestedExtension = ExtensionParser.parse($0, rawData: rawData, config: config) {
                    ext.nested.append(.extension(nestedExtension))
                }
                if let nestedTypealias = TypealiasParser.parse($0, rawData: rawData) {
                    ext.nested.append(.typealias(nestedTypealias))
                }
                if let method = MethodParser.parse($0, rawData: rawData, config: config) {
                    ext.methods.append(method)
                }
                if let property = PropertyParser.parse($0, rawData: rawData, config: config) {
                    ext.properties.append(property)
                }
            }
            return ext
        default:
            return nil
        }
    }
}
