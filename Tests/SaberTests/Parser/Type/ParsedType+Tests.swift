//
//  ParsedType+Tests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 30/05/2018.
//

import Foundation
@testable import Saber

extension ParsedType {
    
    func add(method: ParsedMethod) -> ParsedType {
        var result = self
        result.methods.append(method)
        return result
    }
    
    func add(annotation: TypeAnnotation) -> ParsedType {
        var result = self
        result.annotations.append(annotation)
        return result
    }
}
