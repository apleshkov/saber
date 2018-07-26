//
//  TypeUsage.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

struct TypeUsage: SomeType, Equatable {

    var name: String

    var moduleName: String?
    
    var isOptional: Bool

    var generics: [TypeUsage]

    init(name: String,
         moduleName: String? = nil,
         isOptional: Bool = false,
         generics: [TypeUsage] = []) {
        self.name = name
        self.moduleName = moduleName
        self.isOptional = isOptional
        self.generics = generics
    }
    
    func fullName(modular: Bool) -> String {
        var fullName: String
        if modular, let moduleName = moduleName {
            fullName = "\(moduleName).\(name)"
        } else {
            fullName = name
        }
        if generics.count > 0 {
            let list = generics
                .map { $0.fullName(modular: modular) }
                .joined(separator: ", ")
            fullName += "<\(list)>"
        }
        if isOptional {
            fullName += "?"
        }
        return fullName
    }

    func set(isOptional: Bool) -> TypeUsage {
        var result = self
        result.isOptional = isOptional
        return result
    }
}
