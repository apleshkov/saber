//
//  PropertyAnnotationParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

class PropertyAnnotationParser {

    static func parse(_ rawString: String) -> PropertyAnnotation? {
        if rawString == "inject" {
            return PropertyAnnotation.inject
        }
        return nil
    }
}
