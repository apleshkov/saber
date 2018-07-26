//
//  TypeAnnotation.swift
//  Saber
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation

enum TypeAnnotation: Equatable {
    case bound(to: ParsedTypeUsage)
    case cached
    case injectOnly
    case scope(String)
}

extension TypeAnnotation: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .bound(let to):
            return "@bindTo('\(to.fullName)')"
        case .cached:
            return "@cached"
        case .injectOnly:
            return "@injectOnly"
        case .scope(let scope):
            return "@scope(\(scope))"
        }
    }
}
