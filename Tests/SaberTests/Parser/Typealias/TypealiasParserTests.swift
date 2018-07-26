//
//  TypealiasParserTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 30/05/2018.
//

import XCTest
@testable import Saber
import SourceKittenFramework

class TypealiasParserTests: XCTestCase {
    
    func testSimple() {
        XCTAssertEqual(
            parse(contents: "typealias Foo = Bar"),
            [ParsedTypealias(name: "Foo", target: .type(ParsedTypeUsage(name: "Bar")))]
        )
    }

    func testGeneric() {
        XCTAssertEqual(
            parse(contents: "typealias Foo = Bar<Int>"),
            [
                ParsedTypealias(
                    name: "Foo",
                    target: .type(
                        ParsedTypeUsage(name: "Bar")
                            .add(generic: ParsedTypeUsage(name: "Int"))
                    )
                )
            ]
        )
    }
    
    func testLambda() {
        XCTAssertEqual(
            parse(contents: "typealias Foo = () -> ()"),
            [
                ParsedTypealias(
                    name: "Foo",
                    target: .raw("() -> ()")
                )
            ]
        )
    }
    
    func testTuple() {
        XCTAssertEqual(
            parse(contents: "typealias Foo = (x: Int)"),
            [
                ParsedTypealias(
                    name: "Foo",
                    target: .raw("(x: Int)")
                )
            ]
        )
    }

    func testAnnotations() {
        XCTAssertEqual(
            parse(contents:
                """
                // @saber.cached
                typealias Foo = (x: Int)

                // @saber.scope(Singleton)
                typealias Bar = Quux
                """
            ),
            [
                ParsedTypealias(
                    name: "Foo",
                    target: .raw("(x: Int)"),
                    annotations: [.cached]
                ),
                ParsedTypealias(
                    name: "Bar",
                    target: .type(ParsedTypeUsage(name: "Quux")),
                    annotations: [.scope("Singleton")]
                )
            ]
        )
    }
}

private func parse(contents: String) -> [ParsedTypealias] {
    let rawData = RawData(contents: contents)
    let structure = try! Structure(file: File(contents: contents)).dictionary
    return structure.swiftSubstructures!.compactMap {
        return TypealiasParser.parse($0, rawData: rawData)
    }
}
