//
//  ParsedDataTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 29/05/2018.
//

import XCTest
@testable import Saber

class ParsedDataTests: XCTestCase {

    func testContainerCollision() {
        let container = ParsedContainer(name: "Foo", scopeName: "FooScope", protocolName: "FooProtocol")
        let factory = ParsedDataFactory()
        XCTAssertNoThrow(try factory.register(container))
        XCTAssertThrowsError(try factory.register(container))
    }
}
