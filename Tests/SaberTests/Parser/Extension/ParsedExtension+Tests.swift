//
//  ParsedExtension+Tests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 30/05/2018.
//

import Foundation
@testable import Saber

extension ParsedExtension {
    
    func add(property: ParsedProperty) -> ParsedExtension {
        var result = self
        result.properties.append(property)
        return result
    }
    
    func add(method: ParsedMethod) -> ParsedExtension {
        var result = self
        result.methods.append(method)
        return result
    }
}
