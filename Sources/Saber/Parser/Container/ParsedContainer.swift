//
//  ParsedContainer.swift
//  Saber
//
//  Created by andrey.pleshkov on 25/05/2018.
//

import Foundation

struct ParsedContainer: Equatable {

    var name: String

    var moduleName: String? = nil
    
    var scopeName: String

    var protocolName: String

    var dependencies: [ParsedTypeUsage]

    var externals: [ParsedTypeUsage]
    
    var imports: [String]

    var isThreadSafe: Bool

    init(name: String,
         scopeName: String,
         protocolName: String,
         dependencies: [ParsedTypeUsage] = [],
         externals: [ParsedTypeUsage] = [],
         isThreadSafe: Bool = false,
         imports: [String] = []) {
        self.name = name
        self.scopeName = scopeName
        self.protocolName = protocolName
        self.dependencies = dependencies
        self.externals = externals
        self.isThreadSafe = isThreadSafe
        self.imports = imports
    }
}

extension ParsedContainer {
    
    func fullName(modular: Bool) -> String {
        guard modular, let moduleName = self.moduleName else {
            return name
        }
        return "\(moduleName).\(name)"
    }
}

extension ParsedContainer: Loggable {

    func log(with logger: Logging, level: LogLevel) {
        logger.log(level, message: "Parsed container '\(fullName(modular: true))':")
        logger.log(level, message: "- protocol: \(protocolName)")
        logger.log(level, message: "- scope: \(scopeName)")
        logger.log(level, message: "- dependencies: \(dependencies.map { $0.fullName })")
        logger.log(level, message: "- externals: \(externals.map { $0.fullName })")
        logger.log(level, message: "- imports: \(imports)")
        logger.log(level, message: "- thread-safe: \(isThreadSafe)")
    }
}
