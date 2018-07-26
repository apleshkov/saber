//
//  TypeUsageParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import Foundation

class TypeUsageParser {

    private static func clear(_ rawString: String) -> String {
        var rawString = rawString.trimmingCharacters(in: .whitespaces)
        if rawString.hasPrefix("(") {
            rawString = String(rawString.dropFirst())
            rawString = clear(rawString)
        }
        if rawString.hasSuffix(")") {
            rawString = String(rawString.dropLast())
            rawString = clear(rawString)
        }
        return rawString
    }

    static func parse(_ rawString: String) -> ParsedTypeUsage? {
        if rawString.contains("->") || rawString.contains(":") {
            return nil
        }
        let rawString = clear(rawString)
        guard rawString.count > 0 else {
            return nil
        }
        if rawString == "()" {
            return nil
        }
        var isOptional = false
        var isUnwrapped = false
        var name = rawString
        if name.hasSuffix("?") {
            isOptional = true
            name = String(name.dropLast())
        } else if name.hasSuffix("!") {
            isUnwrapped = true
            name = String(name.dropLast())
        }
        var generics: [ParsedTypeUsage] = []
        if let startIndex = name.index(of: "<"), let endIndex = name.index(of: ">") {
            let range = startIndex...endIndex
            generics = name[range.lowerBound..<range.upperBound]
                .dropFirst()
                .split(separator: ",")
                .compactMap { self.parse(String($0)) }
            name.removeSubrange(range)
        }
        var type = ParsedTypeUsage(name: name)
        type.isOptional = isOptional
        type.isUnwrapped = isUnwrapped
        type.generics = generics
        return type
    }
}
