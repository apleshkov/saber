//
//  PropertyParserTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 23/05/2018.
//

import XCTest
@testable import Saber
import SourceKittenFramework

class PropertyParserTests: XCTestCase {

    func testLet() {
        XCTAssertEqual(
            parse(contents:
                """
                struct Foo {
                let bar: Bar
                }
                """
                ),
            [ParsedProperty(name: "bar", type: ParsedTypeUsage(name: "Bar"))]
        )
    }

    func testVar() {
        XCTAssertEqual(
            parse(contents:
                """
                struct Foo {
                var bar: Bar
                }
                """
                ),
            [ParsedProperty(name: "bar", type: ParsedTypeUsage(name: "Bar"))]
        )
    }

    func testStatic() {
        XCTAssertEqual(
            parse(contents:
                """
                class Foo {
                static let bar: Bar
                class let baz: Baz
                }
                """
            ),
            []
        )
    }

    func testAnnotations() {
        XCTAssertEqual(
            parse(contents:
                """
                struct Foo {
                // @saber.inject
                var bar: Bar
                }
                """
            ),
            [
                ParsedProperty(
                    name: "bar",
                    type: ParsedTypeUsage(name: "Bar"),
                    annotations: [.inject]
                )
            ]
        )
    }

    func testLazy() {
        XCTAssertEqual(
            parse(contents:
                """
                struct Foo {
                // @saber.inject
                var makeBar: (() -> Bar)!
                }
                """
            ),
            [
                ParsedProperty(
                    name: "makeBar",
                    type: ParsedTypeUsage(name: "Bar"),
                    annotations: [.inject],
                    isLazy: true
                )
            ]
        )
    }
}

private func parse(contents: String) -> [ParsedProperty] {
    let rawData = RawData(contents: contents)
    let structure = try! Structure(file: File(contents: contents))
    let substructure = structure.dictionary.swiftSubstructures![0]
    let type = TypeParser.parse(substructure, rawData: rawData)
    return type!.properties
}
