//
//  ParsedData+Tests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 09/06/2018.
//

import Foundation
@testable import Saber

extension ParsedData {

    func type(name: String) -> ParsedType? {
        for entry in types {
            if entry.name == name {
                return entry
            }
        }
        return nil
    }

    func ext(typeName: String) -> ParsedExtension? {
        for entry in extensions {
            if entry.typeName == typeName {
                return entry
            }
        }
        return nil
    }

    func alias(name: String) -> ParsedTypealias? {
        for entry in aliases {
            if entry.name == name {
                return entry
            }
        }
        return nil
    }
}
