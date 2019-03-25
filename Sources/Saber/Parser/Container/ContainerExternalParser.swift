//
//  ContainerExternalParser.swift
//  Saber
//
//  Created by Andrew Pleshkov on 25/03/2019.
//

import Foundation

private enum Prefix {
    static let weak = "weak "
    static let unowned = "unowned "
}

class ContainerExternalParser {
    
    static func parse(_ rawString: String) -> ParsedContainerExternal? {
        let (rawString, refType) = parseRefType(rawString)
        guard let type = TypeUsageParser.parse(rawString) else {
            return nil
        }
        return ParsedContainerExternal(type: type, refType: refType)
    }
    
    private static func parseRefType(_ rawString: String) -> (rawString: String, refType: ReferenceType) {
        if rawString.starts(with: Prefix.weak) {
            return (
                String(rawString.dropFirst(Prefix.weak.count)),
                .weak
            )
        }
        if rawString.hasPrefix(Prefix.unowned) {
            return (
                String(rawString.dropFirst(Prefix.unowned.count)),
                .unowned
            )
        }
        return (rawString, .strong)
    }
}
