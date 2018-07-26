//
//  ContainerData.swift
//  Saber
//
//  Created by Andrew Pleshkov on 01/05/2018.
//

import Foundation

public struct ContainerData {
    
    var name: String

    var initializer: Initializer

    var inheritedFrom: [String] = []

    var storedProperties: [[String]] = []
    
    var getters: [[String]] = []

    var makers: [[String]] = []

    var injectors: [[String]] = []
    
    var imports: [String] = []
    
    init(name: String, initializer: Initializer) {
        self.name = name
        self.initializer = initializer
    }
}

extension ContainerData {

    struct Initializer {
        
        var args: [(name: String, typeName: String)] = []
        var creations: [String] = []
        var storedProperties: [String] = []
        
        init() {}
    }
}
