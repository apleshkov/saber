//
//  ContainerExternal.swift
//  Saber
//
//  Created by Andrew Pleshkov on 25/03/2019.
//

import Foundation

struct ContainerExternal: Equatable {
    
    var type: TypeUsage
    
    var refType: ReferenceType
    
    init(type: TypeUsage, refType: ReferenceType) {
        self.type = type
        self.refType = refType
    }
}
