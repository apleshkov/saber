//
//  FunctionAnnotationParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

class MethodAnnotationParser {

    static func parse(_ rawString: String) -> MethodAnnotation? {
        if rawString == "inject" {
            return MethodAnnotation.inject
        }
        if rawString == "provider" {
            return MethodAnnotation.provider
        }
        if rawString == "didInject" {
            return MethodAnnotation.didInject
        }
        return nil
    }
}
