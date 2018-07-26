//
//  MethodAnnotation.swift
//  Saber
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation

enum MethodAnnotation: Equatable {
    case inject
    case provider
    case didInject
}

extension MethodAnnotation: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .inject:
            return "@inject"
        case .didInject:
            return "@didInject"
        case .provider:
            return "@provider"
        }
    }
}
