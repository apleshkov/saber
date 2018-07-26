//
//  NestedParsedDecl.swift
//  Saber
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation

enum NestedParsedDecl: Equatable {

    case type(ParsedType)
    case `extension`(ParsedExtension)
    case `typealias`(ParsedTypealias)

    var name: String {
        switch self {
        case .type(let type): return type.name
        case .extension(let ext): return ext.typeName
        case .typealias(let alias): return alias.name
        }
    }
}
