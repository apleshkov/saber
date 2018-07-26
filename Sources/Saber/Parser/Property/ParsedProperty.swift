//
//  ParsedProperty.swift
//  Saber
//
//  Created by andrey.pleshkov on 23/05/2018.
//

import Foundation

struct ParsedProperty: Equatable {

    var name: String

    var type: ParsedTypeUsage

    var annotations: [PropertyAnnotation] = []

    var isLazy: Bool

    init(name: String,
         type: ParsedTypeUsage,
         annotations: [PropertyAnnotation] = [],
         isLazy: Bool = false) {
        self.name = name
        self.type = type
        self.annotations = annotations
        self.isLazy = isLazy
    }
}

extension ParsedProperty: CustomStringConvertible {
    
    var description: String {
        var result = "\(name): \(type.fullName)"
        if isLazy {
            result = "lazy " + result
        }
        if annotations.count > 0 {
            result += " -- "
            result += annotations
                .map { $0.description }
                .joined(separator: ", ")
        }
        return result
    }
}
