//
//  FactoryGenericTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 22/06/2018.
//

import XCTest
@testable import Saber

class FactoryGenericTests: XCTestCase {
    
    func testAliasedGeneric() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            typealias FooInt = Foo<Int>?

            // @saber.scope(Singleton)
            struct Bar {
                // @saber.inject
                var foo: FooInt
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers,
            [
                Container(
                    name: "App",
                    protocolName: "AppConfig",
                    services: [
                        Service(
                            typeResolver: .explicit(
                                TypeDeclaration(
                                    name: "Bar",
                                    memberInjections: [
                                        MemberInjection(
                                            name: "foo",
                                            typeResolver: .explicit(TypeUsage(name: "FooInt", isOptional: true))
                                        )
                                    ]
                                )
                            ),
                            storage: .none
                        )
                    ]
                )
            ]
        )
    }
    
    func testKnownGeneric() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo<T> {}

            // @saber.scope(Singleton)
            struct Bar {
                // @saber.inject
                var foo: Foo<Int>
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        XCTAssertThrowsError(try ContainerFactory(repo: repo).make())
    }
    
    func testGenericArgs() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo<T> {
                init(value: T) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        XCTAssertThrowsError(try ContainerFactory(repo: repo).make())
    }
    
    func testGenericProvider() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            class FooIntProvider {
                // @saber.provider
                func provide() -> Foo<Int> {}
            }

            // @saber.scope(Singleton)
            class FooFloatProvider {
                // @saber.provider
                func provide() -> Foo<Float> {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let fooIntProviderDecl = TypeDeclaration(name: "FooIntProvider", isReference: true)
        let fooFloatProviderDecl = TypeDeclaration(name: "FooFloatProvider", isReference: true)
        XCTAssertEqual(
            containers,
            [
                Container(
                    name: "App",
                    protocolName: "AppConfig",
                    services: [
                        Service(
                            typeResolver: .explicit(fooFloatProviderDecl),
                            storage: .none
                        ),
                        Service(
                            typeResolver: .explicit(fooIntProviderDecl),
                            storage: .none
                        ),
                        Service(
                            typeResolver: .provided(
                                TypeUsage(name: "Foo", generics: [TypeUsage(name: "Int")]),
                                by: TypeProvider(decl: fooIntProviderDecl, methodName: "provide")
                            ),
                            storage: .none
                        ),
                        Service(
                            typeResolver: .provided(
                                TypeUsage(name: "Foo", generics: [TypeUsage(name: "Float")]),
                                by: TypeProvider(decl: fooFloatProviderDecl, methodName: "provide")
                            ),
                            storage: .none
                        )
                    ]
                )
            ]
        )
    }

    func testGenericExternals() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(AppExternals)
            protocol AppConfig {}

            class AppExternals {
                var foo1: Foo<Int>
                var foo2: Foo<Float>
            }

            // @saber.scope(Singleton)
            class Bar {
                // @saber.inject
                var foo1: Foo<Int>
                // @saber.inject
                var foo2: Foo<Float>
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let barDecl = TypeDeclaration(
            name: "Bar",
            isReference: true,
            memberInjections: [
                MemberInjection(
                    name: "foo1",
                    typeResolver: .external(
                        from: TypeUsage(name: "AppExternals"),
                        kind: .property(name: "foo1")
                    )
                ),
                MemberInjection(
                    name: "foo2",
                    typeResolver: .external(
                        from: TypeUsage(name: "AppExternals"),
                        kind: .property(name: "foo2")
                    )
                )
            ]
        )
        XCTAssertEqual(
            containers.first?.services,
            [
                Service(
                    typeResolver: .explicit(barDecl),
                    storage: .none
                )
            ]
        )
    }
}
