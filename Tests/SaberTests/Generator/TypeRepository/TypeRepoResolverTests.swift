//
//  TypeRepoResolverTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 04/06/2018.
//

import XCTest
@testable import Saber

class TypeRepoResolverTests: XCTestCase {
    
    func testContainer() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                // @saber.container(Session)
                // @saber.scope(Session)
                // @saber.dependsOn(App)
                protocol SessionConfig {}
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("App"), scopeName: "Singleton"),
            .container
        )
        XCTAssertEqual(
            repo.resolver(for: .name("App"), scopeName: "Session"),
            .derived(from: "Singleton", resolver: .container)
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Session"), scopeName: "App"),
            nil
        )
    }
    
    func testExplicit() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                // @saber.scope(Singleton)
                struct Foo {}
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("Foo"), scopeName: "Singleton"),
            .explicit
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Bar"), scopeName: "Singleton"),
            nil
        )
    }
    
    func testExternal() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                // @saber.externals(Foo, BarModule.Bar?, Quux<Int>!)
                protocol AppConfig {}
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("Foo"), scopeName: "Singleton"),            
            .external
        )
        XCTAssertEqual(
            repo.resolver(for: .name("BarModule.Bar"), scopeName: "Singleton"),
            .external
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Bar"), scopeName: "Singleton"),
            nil
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Quux<Int>"), scopeName: "Singleton"),
            .external
        )
    }
    
    func testProvided1() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                struct Foo {} // known type

                // @saber.scope(Singleton)
                class FooProvider {
                    // @saber.provider
                    func provide() -> Foo {}
                }

                // @saber.scope(Singleton)
                class BarProvider {
                    // @saber.provider
                    func provide() -> Bar {} // returns unknown type
                }
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("Foo"), scopeName: "Singleton"),
            .provider(.name("FooProvider"))
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Bar"), scopeName: "Singleton"),
            .provider(.name("BarProvider"))
        )
    }
    
    func testProvided2() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                // @saber.scope(Singleton)
                struct Foo {
                    // @saber.provider
                    static func provide() -> Foo {} // returns known type
                }

                // @saber.scope(Singleton)
                class BarFactory {
                    // @saber.provider
                    static func make() -> Bar {} // returns unknown type
                }
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("Foo"), scopeName: "Singleton"),
            .provider(.name("Foo"))
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Bar"), scopeName: "Singleton"),
            .provider(.name("BarFactory"))
        )
    }
    
    func testProvided3() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                protocol Foo {}

                // @saber.scope(Singleton)
                class FooProvider {
                    // @saber.provider
                    func provide() -> Foo {}
                }
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("Foo"), scopeName: "Singleton"),
            .provider(.name("FooProvider"))
        )
    }
    
    func testProvided4() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                // @saber.scope(Singleton)
                class FooProvider {
                    // @saber.provider
                    func provide() -> Foo<String> {}
                }
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("Foo<String>"), scopeName: "Singleton"),
            .provider(.name("FooProvider"))
        )
    }
    
    func testBound() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                protocol FooProtocol {}

                // @saber.scope(Singleton)
                // @saber.bindTo(FooProtocol)
                struct Foo {}

                // @saber.scope(Singleton)
                // @saber.bindTo(BarProtocol)
                struct Bar {}
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("FooProtocol"), scopeName: "Singleton"),
            .binder(.name("Foo"))
        )
        XCTAssertEqual(
            repo.resolver(for: .name("BarProtocol"), scopeName: "Singleton"),
            .binder(.name("Bar"))
        )
    }

    func testDerived() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                // @saber.externals(Baz)
                protocol AppConfig {}

                // @saber.scope(Singleton)
                // @saber.bindTo(FooProtocol)
                struct Foo {}

                // @saber.scope(Singleton)
                class BarProvider {
                    // @saber.provider
                    func provide() -> Bar {}
                }

                // @saber.scope(Singleton)
                class Quux {}

                // @saber.container(SessionContainer)
                // @saber.scope(Session)
                // @saber.dependsOn(App)
                protocol SessionConfig {}
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            repo.resolver(for: .name("FooProtocol"), scopeName: "Session"),
            .derived(
                from: "Singleton",
                resolver: .binder(.name("Foo"))
            )
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Bar"), scopeName: "Session"),
            .derived(
                from: "Singleton",
                resolver: .provider(.name("BarProvider"))
            )
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Baz"), scopeName: "Session"),
            .derived(
                from: "Singleton",
                resolver: .external
            )
        )
        XCTAssertEqual(
            repo.resolver(for: .name("Quux"), scopeName: "Session"),
            .derived(
                from: "Singleton",
                resolver: .explicit
            )
        )
    }
    
    func testAlias() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                // @saber.scope(Singleton)
                typealias Foo = Bar?
                """
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            try! repo.find(by: "Foo")?.parsed,
            .alias(
                ParsedTypealias(
                    name: "Foo",
                    target: .type(
                        ParsedTypeUsage(name: "Bar", isOptional: true)
                    ),
                    annotations: [.scope("Singleton")]
                )
            )
        )
    }
}
