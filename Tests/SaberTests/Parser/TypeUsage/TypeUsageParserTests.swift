//
//  TypeUsageParserTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import XCTest
@testable import Saber

class TypeUsageParserTests: XCTestCase {
    
    func testSimple() {
        XCTAssertEqual(
            TypeUsageParser.parse("Foo"),
            ParsedTypeUsage(name: "Foo")
        )
        XCTAssertEqual(
            TypeUsageParser.parse("(Foo)"),
            ParsedTypeUsage(name: "Foo")
        )
        XCTAssertEqual(
            TypeUsageParser.parse("( Foo  )"),
            ParsedTypeUsage(name: "Foo")
        )
        XCTAssertEqual(
            TypeUsageParser.parse("( (Foo )  )"),
            ParsedTypeUsage(name: "Foo")
        )
    }

    func testOptional() {
        XCTAssertEqual(
            TypeUsageParser.parse("Foo?"),
            ParsedTypeUsage(name: "Foo", isOptional: true)
        )
    }

    func testUnwrapped() {
        XCTAssertEqual(
            TypeUsageParser.parse("Foo!"),
            ParsedTypeUsage(name: "Foo", isUnwrapped: true)
        )
    }

    func testGenrics() {
        XCTAssertEqual(
            TypeUsageParser.parse("Foo<Bar, Baz?>"),
            ParsedTypeUsage(name: "Foo")
                .add(generic: ParsedTypeUsage(name: "Bar"))
                .add(generic: ParsedTypeUsage(name: "Baz", isOptional: true))
        )
    }

    func testNested() {
        XCTAssertEqual(
            TypeUsageParser.parse("Foo.Bar.Baz"),
            ParsedTypeUsage(name: "Foo.Bar.Baz")
        )
    }
}
