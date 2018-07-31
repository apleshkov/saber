//
//  ParsedMethod.swift
//  Saber
//
//  Created by andrey.pleshkov on 23/05/2018.
//

import Foundation

struct ParsedMethod: Equatable {

    var name: String

    var args: [ParsedArgument]

    var returnType: ParsedTypeUsage?

    var isStatic: Bool

    var accessLevel: String?

    var annotations: [MethodAnnotation]

    var isFailableInitializer: Bool

    init(name: String,
         args: [ParsedArgument] = [],
         returnType: ParsedTypeUsage? = nil,
         isStatic: Bool = false,
         accessLevel: String? = "internal",
         annotations: [MethodAnnotation] = [],
         isFailableInitializer: Bool = false) {
        self.name = name
        self.args = args
        self.returnType = returnType
        self.isStatic = isStatic
        self.accessLevel = accessLevel
        self.annotations = annotations
        self.isFailableInitializer = isFailableInitializer
    }
}

extension ParsedMethod {

    var isInitializer: Bool {
        return name == "init"
    }
}

extension ParsedMethod: CustomStringConvertible {
    
    var description: String {
        var result = name
        if isStatic {
            result = "static " + result
        }
        if isFailableInitializer {
            result += "?"
        }
        result += "("
        result += args.map { $0.description }.joined(separator: ", ")
        result += ")"
        if let returnType = returnType {
            result += " -> \(returnType.fullName)"
        }
        if annotations.count > 0 {
            result += " -- annotations: \(annotations)"
        }
        return result
    }
}
