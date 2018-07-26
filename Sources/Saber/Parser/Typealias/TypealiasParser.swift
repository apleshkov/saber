//
//  TypealiasParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation
import SourceKittenFramework

class TypealiasParser {

    static func parse(_ structure: [String : SourceKitRepresentable], rawData: RawData) -> ParsedTypealias? {
        guard let kind = structure.swiftDeclKind, let name = structure.swiftName else {
            return nil
        }
        switch kind {
        case .typealias:
            guard var rawString = StringExtractor.key.extract(from: structure, contents: rawData.contents) else {
                return nil
            }
            guard let assignIndex = rawString.index(of: "=") else {
                return nil
            }
            rawString = String(rawString[assignIndex...].dropFirst()).trimmingCharacters(in: .whitespaces)
            guard rawString.count > 0 else {
                return nil
            }
            let target: ParsedTypealias.Target
            if let type = TypeUsageParser.parse(rawString) {
                target = .type(type)
            } else {
                target = .raw(rawString)
            }
            var alias = ParsedTypealias(name: name, target: target)
            alias.annotations = rawData
                .annotations(for: structure)
                .compactMap { TypeAnnotationParser.parse($0) }
            return alias
        default:
            return nil
        }
    }
}
