//
//  FileParser+Tests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 29/05/2018.
//

import Foundation
@testable import Saber
import SourceKittenFramework

extension FileParser {
    
    convenience init(contents: String, moduleName: String? = nil) throws {
        let file = File(contents: contents)
        try self.init(
            file: file,
            config: SaberConfiguration.test,
            moduleName: moduleName
        )
    }
}
