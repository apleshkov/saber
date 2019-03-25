//
//  ContainerAnnotationParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

private enum Prefix {
    static let name = "container"
    static let scope = "scope"
    static let dependsOn = "dependsOn"
    static let externals = "externals"
    static let imports = "imports"
}

class ContainerAnnotationParser {

    static func parse(_ rawString: String) -> ContainerAnnotation? {
        let rawString = rawString.trimmingCharacters(in: .whitespaces)
        guard rawString.count > 0 else {
            return nil
        }
        if rawString.hasPrefix(Prefix.name),
            let name = AnnotationParserHelper.argument(from: rawString, prefix: Prefix.name) {
            return ContainerAnnotation.name(name)
        }
        if rawString.hasPrefix(Prefix.scope),
            let scope = AnnotationParserHelper.argument(from: rawString, prefix: Prefix.scope) {
            return ContainerAnnotation.scope(scope)
        }
        if rawString.hasPrefix(Prefix.dependsOn),
            let args = AnnotationParserHelper.arguments(from: rawString, prefix: Prefix.dependsOn) {
            let types = args.compactMap { TypeUsageParser.parse($0) }
            return ContainerAnnotation.dependencies(types)
        }
        if rawString.hasPrefix(Prefix.externals),
            let args = AnnotationParserHelper.arguments(from: rawString, prefix: Prefix.externals) {
            let externals = args.compactMap { ContainerExternalParser.parse($0) }
            return ContainerAnnotation.externals(externals)
        }
        if rawString.hasPrefix(Prefix.imports),
            let args = AnnotationParserHelper.arguments(from: rawString, prefix: Prefix.imports) {
            return ContainerAnnotation.imports(args)
        }
        if rawString == "threadSafe" {
            return ContainerAnnotation.threadSafe
        }
        return nil
    }
}
