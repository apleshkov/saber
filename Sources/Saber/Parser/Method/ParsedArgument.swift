//
//  ParsedFunctionArgument.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

struct ParsedArgument: Equatable {

    var name: String?

    var type: ParsedTypeUsage

    var isLazy: Bool

    init(name: String?, type: ParsedTypeUsage, isLazy: Bool = false) {
        self.name = name
        self.type = type
        self.isLazy = isLazy
    }
}

extension ParsedArgument: CustomStringConvertible {
    
    var description: String {
        var desc = name ?? "_"
        if isLazy {
            desc = "lazy " + desc
        }
        desc += ": " + type.fullName
        return desc
    }
}
