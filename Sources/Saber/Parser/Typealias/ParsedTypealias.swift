//
//  ParsedTypealias.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

struct ParsedTypealias: Equatable {

    var name: String

    var target: Target

    var moduleName: String? = nil

    var annotations: [TypeAnnotation] = []

    init(name: String, target: Target, annotations: [TypeAnnotation] = []) {
        self.name = name
        self.target = target
        self.annotations = annotations
    }
    
    enum Target: Equatable {
        case type(ParsedTypeUsage)
        case raw(String)
    }
}
