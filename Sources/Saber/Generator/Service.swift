//
//  Service.swift
//  Saber
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import Foundation

enum ServiceStorage: Equatable {
    case cached
    case none
}

struct Service: Equatable {

    var typeResolver: TypeResolver<TypeDeclaration>

    var storage: ServiceStorage
}
