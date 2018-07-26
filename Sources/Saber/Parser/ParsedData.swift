//
//  ParsedData.swift
//  Saber
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation

struct ParsedData: Equatable {
    
    var containers: [String : ParsedContainer] = [:]
    
    var types: [ParsedType] = []

    var extensions: [ParsedExtension] = []

    var aliases: [ParsedTypealias] = []
}

// MARK: Factory

public class ParsedDataFactory {

    private var containers: [String : ParsedContainer] = [:]
    
    private var types: [ParsedType] = []

    private var aliases: [ParsedTypealias] = []

    private var extensions: [ParsedExtension] = []
    
    public init() {}

    func register(_ container: ParsedContainer) throws {
        let key = container.name
        guard containers[key] == nil else {
            throw Throwable.message("Container '\(container.name)' is already exist")
        }
        containers[key] = container
    }
    
    func register(_ type: ParsedType) {
        types.append(type)
    }

    func register(_ alias: ParsedTypealias) {
        aliases.append(alias)
    }

    func register(_ ext: ParsedExtension) {
        extensions.append(ext)
    }

    func make() -> ParsedData {
        return ParsedData(
            containers: containers,
            types: types,
            extensions: extensions,
            aliases: aliases
        )
    }
}
