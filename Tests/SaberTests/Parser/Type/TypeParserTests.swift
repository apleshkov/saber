//
//  ParserTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 08/05/2018.
//

import XCTest
@testable import Saber
import SourceKittenFramework

class TypeParserTests: XCTestCase {

    func testSimpleDecl() {
        XCTAssertEqual(
            parse(contents: "class Foo {}"),
            [ParsedType(name: "Foo", isReference: true)]
        )
        XCTAssertEqual(
            parse(contents: "struct Foo {}"),
            [ParsedType(name: "Foo")]
        )
    }

    func testGenericDecl() {
        XCTAssertEqual(
            parse(contents: "struct Foo<T> {}"),
            [ParsedType(name: "Foo")]
        )
    }
    
    func testTypeAnnotations() {
        XCTAssertEqual(
            parse(contents:
                """
                struct Foo {}
                // текст на русском
                // @saber.cached
                // @saber.bindTo(Baz)
                // comment
                struct Bar {}
                """
            ),
            [
                ParsedType(name: "Foo"),
                ParsedType(name: "Bar")
                    .add(annotation: .cached)
                    .add(annotation: .bound(to: ParsedTypeUsage(name: "Baz")))
            ]
        )
    }

    func testNested() {
        XCTAssertEqual(
            parse(contents:
                """
                class Foo {
                    struct Bar {}
                    extension Baz {}
                    typealias Quux = Int
                }
                """
                ).map { $0.nested },
            [
                [
                    .type(ParsedType(name: "Bar")),
                    .extension(ParsedExtension(typeName: "Baz")),
                    .typealias(
                        ParsedTypealias(
                            name: "Quux",
                            target: .type(ParsedTypeUsage(name: "Int"))
                        )
                    )
                ]
            ]
        )
    }
}

private func parse(contents: String) -> [ParsedType] {
    let structure = try! Structure(file: File(contents: contents))
    let rawData = RawData(contents: contents)
    return structure.dictionary.swiftSubstructures!.compactMap {
        return TypeParser.parse($0, rawData: rawData, config: SaberConfiguration.test)
    }
}
