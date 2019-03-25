//
//  ParsedContainerExternal.swift
//  Saber
//
//  Created by Andrew Pleshkov on 25/03/2019.
//

import Foundation

struct ParsedContainerExternal: Equatable {
    
    var type: ParsedTypeUsage
    
    var refType: ReferenceType
    
    init(type: ParsedTypeUsage, refType: ReferenceType) {
        self.type = type
        self.refType = refType
    }
}

extension ParsedContainerExternal {
    
    var fullName: String {
        switch refType {
        case .strong:
            return type.fullName
        case .weak,
             .unowned:
            return "\(refType) \(type.fullName)"
        }
    }
}
