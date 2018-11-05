//
//  SaberTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 03/07/2018.
//

import XCTest
@testable import Saber
import Yams

class SaberTests: XCTestCase {

    func testConfigAccessLevel() {
        var config = SaberConfiguration.default
        config.accessLevel = "public"
        XCTAssertEqual(
            decode(
                """
                accessLevel: public
                """
            ),
            config
        )
    }

    func testConfigSpaceIdentation() {
        var config = SaberConfiguration.default
        config.indent = "  "
        XCTAssertEqual(
            decode(
                """
                indentation:
                    type: space
                    size: 2
                """
            ),
            config
        )
    }

    func testConfigTabIdentation() {
        var config = SaberConfiguration.default
        config.indent = "\t"
        XCTAssertEqual(
            decode(
                """
                indentation:
                    type: tab
                    size: 1
                """
            ),
            config
        )
    }
    
    func testLock() {
        let lock = NSRecursiveLock()
        XCTAssertNotNil(lock)
    }
}

private func decode(_ contents: String) -> SaberConfiguration {
    let decoder = YAMLDecoder()
    return try! decoder.decode(SaberConfiguration.self, from: contents)
}
