//
//  ParsedTypeUsage.swift
//  Saber
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import Foundation

struct ParsedTypeUsage: Equatable {

    var name: String

    var isOptional: Bool

    var isUnwrapped: Bool
    
    var generics: [ParsedTypeUsage] = []

    init(name: String, isOptional: Bool = false, isUnwrapped: Bool = false, isReference: Bool = false) {
        self.name = name
        self.isOptional = isOptional
        self.isUnwrapped = isUnwrapped
    }

    func add(generic: ParsedTypeUsage) -> ParsedTypeUsage {
        var result = self
        result.generics.append(generic)
        return result
    }
}

extension ParsedTypeUsage {
    
    var genericName: String {
        if generics.count > 0 {
            let list = generics
                .map { $0.fullName }
                .joined(separator: ", ")
            return "\(name)<\(list)>"
        }
        return name
    }
    
    var fullName: String {
        var fullName = genericName
        if isOptional {
            fullName += "?"
        } else if isUnwrapped {
            fullName += "!"
        }
        return fullName
    }
}
