//
//  ParsedExtension.swift
//  Saber
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import Foundation

struct ParsedExtension: Equatable {

    var typeName: String

    var moduleName: String? = nil

    var properties: [ParsedProperty] = []
    
    var methods: [ParsedMethod] = []
    
    var nested: [NestedParsedDecl] = []
    
    init(typeName: String) {
        self.typeName = typeName
    }
}

extension ParsedExtension {
    
    func fullName(modular: Bool) -> String {
        guard modular, let moduleName = self.moduleName else {
            return typeName
        }
        return "\(moduleName).\(typeName)"
    }
}

extension ParsedExtension: Loggable {
    
    func log(with logger: Logging, level: LogLevel) {
        logger.log(level, message: "Parsed extension '\(fullName(modular: true))':")
        properties.forEach {
            logger.log(level, message: "- \($0)")
        }
        methods.forEach {
            logger.log(level, message: "- \($0)")
        }
    }
}
