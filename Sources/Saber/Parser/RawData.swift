//
//  RawData.swift
//  Saber
//
//  Created by andrey.pleshkov on 24/05/2018.
//

import Foundation
import SourceKittenFramework

private struct ParsedLine: Equatable {
    enum Kind: Equatable {
        case annotation(text: String)
        case comment
        case other
    }
    
    var kind: Kind
}

class RawData {

    static let defaultPrefix = "@saber."
    
    let contents: String
    
    private let lines: [ParsedLine]

    init(contents: String, prefix: String = RawData.defaultPrefix) {
        self.contents = contents
        self.lines = parse(contents: contents, prefix: prefix)
    }

    func annotations(for structure: [String : SourceKitRepresentable]) -> [String] {
        guard let offset = structure[SwiftDocKey.offset] as? Int64,
            let cursor = contents.lineAndCharacter(forByteOffset: Int(offset)),
            cursor.line > 0 else {
            return []
        }
        var result: [String] = []
        for line in lines[0..<(cursor.line - 1)].reversed() {
            if case .other = line.kind {
                break
            }
            if case .annotation(let text) = line.kind {
                result.append(text)
            }
        }
        return result.reversed()
    }
}

private func parse(contents: String, prefix: String) -> [ParsedLine] {
    return contents.lines().map {
        let rawText = $0.content.trimmingCharacters(in: .whitespaces)
        let kind: ParsedLine.Kind
        let isComment = rawText.hasPrefix("//")
        if isComment {
            if let extractedText = extract(from: rawText, prefix: prefix) {
                kind = .annotation(text: extractedText)
            } else {
                kind = .comment
            }
        } else {
            kind = .other
        }
        return ParsedLine(kind: kind)
    }
}

private func extract(from rawText: String, prefix: String) -> String? {
    guard let prefixRange = rawText.range(of: prefix) else {
        return nil
    }
    let extracted = rawText[prefixRange.upperBound...]
    guard extracted.count > 0 else {
        return nil
    }
    return String(extracted)
}
