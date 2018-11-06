//
//  SaberConfigurationTests.swift
//  SaberCLITests
//
//  Created by Andrew Pleshkov on 06/11/2018.
//

import XCTest
@testable import Saber
@testable import SaberCLI

class SaberConfigurationTests: XCTestCase {

    func testRootElements() {
        let yaml = """
            accessLevel: public
            lazyTypealias: LazyInjection
            """
        let config: SaberConfiguration = try! ConfigDecoder(raw: yaml).decode(baseURL: nil)
        XCTAssertEqual(config.accessLevel, "public")
        XCTAssertEqual(config.lazyTypealias, "LazyInjection")
    }
    
    func testSpaceIdentation() {
        let yaml = """
            indentation:
                type: space
                size: 2
            """
        let config: SaberConfiguration = try! ConfigDecoder(raw: yaml).decode(baseURL: nil)
        XCTAssertEqual(config.indent, "  ")
    }
    
    func testTabIdentation() {
        let yaml = """
            indentation:
                type: tab
                size: 2
            """
        let config: SaberConfiguration = try! ConfigDecoder(raw: yaml).decode(baseURL: nil)
        XCTAssertEqual(config.indent, "\t\t")
    }
}
