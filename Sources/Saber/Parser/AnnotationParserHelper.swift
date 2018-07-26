//
//  AnnotationParserHelper.swift
//  Saber
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import Foundation

enum AnnotationParserHelper {

    static func argument(from rawString: String, prefix: String) -> String? {
        guard rawString.hasPrefix(prefix) else {
            return nil
        }
        let arg = rawString
            .dropFirst(prefix.count + 1)
            .dropLast()
            .trimmingCharacters(in: .whitespaces)
        guard arg.count > 0 else {
            return nil
        }
        return arg
    }

    static func arguments(from rawString: String, prefix: String) -> [String]? {
        let arg = argument(from: rawString, prefix: prefix) ?? ""
        return arg
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.count > 0 }
    }
}
