//
//  AnnParserTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 03/08/2018.
//

import XCTest
@testable import Saber

class AnnParserTests: XCTestCase {
    
    func testBasic() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            // @saber.cached
            class A {}
            """
            ).parse(to: factory)
        let data = factory.make()
        XCTAssertEqual(
            data.type(name: "A")?.annotations,
            [.scope("Singleton"), .cached]
        )
    }

    func testNewlines() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)

            // @saber.cached
            class A {}
            """
            ).parse(to: factory)
        let data = factory.make()
        XCTAssertEqual(
            data.type(name: "A")?.annotations,
            [.cached]
        )
    }

    func testMultilineComments() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            /* User comment */
            // @saber.scope(Singleton)
            //////
            // User comment
            ///
            // @saber.cached
            // User comment
            class A {}
            """
            ).parse(to: factory)
        let data = factory.make()
        XCTAssertEqual(
            data.type(name: "A")?.annotations,
            [.scope("Singleton"), .cached]
        )
    }
}
