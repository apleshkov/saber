//
//  Injections.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

struct MemberInjection: Equatable {

    var name: String

    var typeResolver: TypeResolver<TypeUsage>

    var isLazy: Bool

    init(name: String, typeResolver: TypeResolver<TypeUsage>, isLazy: Bool = false) {
        self.name = name
        self.typeResolver = typeResolver
        self.isLazy = isLazy
    }
}

struct InstanceMethodInjection: Equatable {

    var methodName: String

    var args: [FunctionInvocationArgument]
}
