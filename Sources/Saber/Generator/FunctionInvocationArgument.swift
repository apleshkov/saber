//
//  FunctionInvocationArgument.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

struct FunctionInvocationArgument: Equatable {

    var name: String?

    var typeResolver: TypeResolver<TypeUsage>

    var isLazy: Bool

    init(name: String?, typeResolver: TypeResolver<TypeUsage>, isLazy: Bool = false) {
        self.name = name
        self.typeResolver = typeResolver
        self.isLazy = isLazy
    }
}

extension FunctionInvocationArgument: CustomStringConvertible {
    
    var description: String {
        var desc = name ?? "_"
        if isLazy {
            desc = "lazy " + desc
        }
        desc += ": " + typeResolver.description
        return desc
    }
}
