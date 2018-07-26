//
//  TypeProvider.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

struct TypeProvider: Equatable {

    var decl: TypeDeclaration

    var methodName: String

    var args: [FunctionInvocationArgument] = []

    init(decl: TypeDeclaration, methodName: String, args: [FunctionInvocationArgument] = []) {
        self.decl = decl
        self.methodName = methodName
    }
}
