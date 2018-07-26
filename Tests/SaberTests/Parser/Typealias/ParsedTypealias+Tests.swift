//
//  ParsedTypealias+Tests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 30/05/2018.
//

import Foundation
@testable import Saber

extension ParsedTypealias {
    
    var type: ParsedTypeUsage? {
        switch target {
        case .type(let type):
            return type
        case .raw(_):
            return nil
        }
    }
}
