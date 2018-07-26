//
//  SomeType.swift
//  Saber
//
//  Created by Andrew Pleshkov on 10/06/2018.
//

import Foundation

protocol SomeType {
    
    var name: String { get }
    
    func fullName(modular: Bool) -> String
    
    var isOptional: Bool { set get }
}
