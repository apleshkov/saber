//
//  TypeResolver.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

indirect enum TypeResolver<T>: Equatable where T: Equatable & SomeType {
    case container
    case explicit(T)
    case provided(TypeUsage, by: TypeProvider)
    case bound(TypeUsage, to: T)
    case derived(from: T, typeResolver: TypeResolver)
    case external(from: T, kind: ContainerExternal.Kind)
}

extension TypeResolver: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .container:
            return "container"
        case .explicit(let some):
            return "explicit '\(some.fullName(modular: true))'"
        case .provided(let some, let provider):
            let by = "\(provider.decl.fullName(modular: true)).\(provider.methodName)("
                + provider.args.map { $0.description }.joined(separator: ", ")
                + ")"
            return "'\(some.fullName(modular: true))' provided by \(by)"
        case .bound(let mimic, let some):
            return "'\(mimic.fullName(modular: true))' is bound to '\(some.fullName(modular: true))'"
        case .derived(let from, let typeResolver):
            return "derived from '\(from.fullName(modular: true))' as \(typeResolver)"
        case .external(let from, let kind):
            switch kind {
            case .property(let name):
                return "external \(from.fullName(modular: true)).\(name)"
            case .method(let name, let args):
                return "external \(from.fullName(modular: true)).\(name)("
                    + args.map { $0.description }.joined(separator: ", ")
                    + ")"
            }
        }
    }
}
