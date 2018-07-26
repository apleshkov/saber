//
//  ContainerAnnotation.swift
//  Saber
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation

enum ContainerAnnotation: Equatable {
    case name(String)
    case scope(String)
    case dependencies([ParsedTypeUsage])
    case externals([ParsedTypeUsage])
    case threadSafe
    case imports([String])
}
