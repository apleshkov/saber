//
//  FileParserTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 29/05/2018.
//

import XCTest
@testable import Saber

class FileParserTests: XCTestCase {
    
    func testNestedDecls() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            extension Foo {
                typealias FooInt = Int

                extension Bar {
                    // @saber.inject
                    func set() {}
                }
            }
            extension Foo.Bar.Baz {
                // @saber.inject
                func set() {}

                typealias BazInt = Int
            }
            """
        ).parse(to: factory)
        try! FileParser(contents:
            """
            struct Foo {
                struct Bar {
                    // @saber.cached
                    struct Baz {}

                    typealias BarInt = Int
                }
            }
            """
        ).parse(to: factory)
        let data = factory.make()
        XCTAssertEqual(data.types.count, 3)
        XCTAssertEqual(
            data.type(name: "Foo")?.name,
            "Foo"
        )
        XCTAssertEqual(
            data.ext(typeName: "Foo.Bar")?.methods,
            [ParsedMethod(name: "set", annotations: [.inject])]
        )
        XCTAssertEqual(
            data.type(name: "Foo.Bar.Baz")?.annotations,
            [.cached]
        )
        XCTAssertEqual(
            data.ext(typeName: "Foo.Bar.Baz")?.methods,
            [ParsedMethod(name: "set", annotations: [.inject])]
        )
        XCTAssertEqual(
            data.alias(name: "Foo.FooInt")?.type,
            ParsedTypeUsage(name: "Int")
        )
        XCTAssertEqual(
            data.alias(name: "Foo.Bar.BarInt")?.type,
            ParsedTypeUsage(name: "Int")
        )
        XCTAssertEqual(
            data.alias(name: "Foo.Bar.Baz.BazInt")?.type,
            ParsedTypeUsage(name: "Int")
        )
    }

    func testModuleName() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            class Foo {}
            typealias Bar = Foo
            extension Foo {}
            """, moduleName: "A"
            ).parse(to: factory)
        let data = factory.make()
        XCTAssertEqual(
            data.type(name: "Foo")?.moduleName,
            "A"
        )
        XCTAssertEqual(
            data.alias(name: "Bar")?.moduleName,
            "A"
        )
        XCTAssertEqual(
            data.ext(typeName: "Foo")?.moduleName,
            "A"
        )
    }
    
    func testContainer() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(Foo)
            // @saber.scope(Singleton)
            protocol FooConfig {}
            """, moduleName: "A"
            ).parse(to: factory)
        let data = factory.make()
        XCTAssertEqual(
            data.containers["Foo"]?.scopeName,
            "Singleton"
        )
        XCTAssertEqual(
            data.containers["Foo"]?.moduleName,
            "A"
        )
    }
}
