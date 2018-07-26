//
//  ParsedType.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

struct ParsedType: Equatable {

    var name: String

    var moduleName: String? = nil

    var properties: [ParsedProperty] = []

    var methods: [ParsedMethod] = []
    
    var annotations: [TypeAnnotation] = []

    var isReference: Bool = false
    
    var nested: [NestedParsedDecl] = []

    init(name: String, isReference: Bool = false, nested: [NestedParsedDecl] = []) {
        self.name = name
        self.isReference = isReference
        self.nested = nested
    }
}

extension ParsedType {

    func fullName(modular: Bool) -> String {
        guard modular, let moduleName = self.moduleName else {
            return name
        }
        return "\(moduleName).\(name)"
    }
}

extension ParsedType: Loggable {
    
    func log(with logger: Logging, level: LogLevel) {
        let kind = isReference ? "reference" : "value"
        var message = "Parsed \(kind) '\(fullName(modular: true))':"
        if annotations.count > 0 {
            message += " -- "
            message += annotations
                .map { $0.description }
                .joined(separator: ", ")
        }
        logger.log(level, message: message)
        properties.forEach {
            logger.log(level, message: "- \($0)")
        }
        methods.forEach {
            logger.log(level, message: "- \($0)")
        }
    }
}
