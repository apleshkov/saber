//
//  TypeAnnotationParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

private enum Prefix {
    static let bound = "bindTo"
    static let scope = "scope"
}

class TypeAnnotationParser {

    static func parse(_ rawString: String) -> TypeAnnotation? {
        let rawString = rawString.trimmingCharacters(in: .whitespaces)
        guard rawString.count > 0 else {
            return nil
        }
        if rawString.hasPrefix(Prefix.scope),
            let scope = AnnotationParserHelper.argument(from: rawString, prefix: Prefix.scope) {
            return TypeAnnotation.scope(scope)
        }
        if rawString.hasPrefix(Prefix.bound),
            let content = AnnotationParserHelper.argument(from: rawString, prefix: Prefix.bound),
            let type = TypeUsageParser.parse(content) {
            return TypeAnnotation.bound(to: type)
        }
        if rawString == "cached" {
            return TypeAnnotation.cached
        }
        if rawString == "injectOnly" {
            return TypeAnnotation.injectOnly
        }
        return nil
    }
}
