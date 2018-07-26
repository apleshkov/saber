//
//  PropertyAnnotation.swift
//  Saber
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation

enum PropertyAnnotation: Equatable {
    case inject
}

extension PropertyAnnotation: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .inject:
            return "@inject"
        }
    }
}
