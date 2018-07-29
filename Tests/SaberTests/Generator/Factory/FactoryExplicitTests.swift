//
//  FactoryExplicitTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 15/06/2018.
//

import XCTest
@testable import Saber

class FactoryExplicitTests: XCTestCase {
    
    func testCached() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            // @saber.cached
            struct Foo {}

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers,
            [
                Container(name: "App", protocolName: "AppConfig")
                    .add(service: Service(
                        typeResolver: .explicit(TypeDeclaration(name: "Foo")),
                        storage: .cached
                    ))
            ]
        )
    }
    
    func testInjectOnly() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            // @saber.injectOnly
            class Foo {}

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers,
            [
                Container(name: "App", protocolName: "AppConfig")
                    .add(service: Service(
                        typeResolver: .explicit(
                            TypeDeclaration(name: "Foo")
                                .set(isReference: true)
                                .set(initializer: .none)
                        ),
                        storage: .none
                    ))
            ]
        )
    }
    
    func testOptional() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            struct Foo {
                init?()
            }

            // @saber.scope(Singleton)
            struct Bar {
                init() {}
                // @saber.inject
                init?() {}
            }

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(name: "Bar")
                                .set(isOptional: true)
                        ),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(name: "Foo")
                                .set(isOptional: true)
                        ),
                        storage: .none
                    )
                ]
            ]
        )
    }
    
    func testInjections() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            struct Bar {}

            // @saber.scope(Singleton)
            struct Quux {}

            // @saber.scope(Singleton)
            struct Baz {}

            // @saber.scope(Singleton)
            struct Foo {
                
                // @saber.inject
                var bar: Bar

                init(baz: Baz) {}

                // @saber.inject
                func set(quux: Quux) {}
            }

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let foo: TypeDeclaration = {
            var foo = TypeDeclaration(name: "Foo")
            foo.initializer = .some(
                args: [FunctionInvocationArgument(name: "baz", typeResolver: .explicit(TypeUsage(name: "Baz")))]
            )
            foo.memberInjections = [MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))]
            foo.methodInjections = [
                InstanceMethodInjection(
                    methodName: "set",
                    args: [
                        FunctionInvocationArgument(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))
                    ]
                )
            ]
            return foo
        }()
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(name: "Bar")
                        ),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(name: "Baz")
                        ),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(foo),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(name: "Quux")
                        ),
                        storage: .none
                    )
                ]
            ]
        )
    }
    
    func testNested() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            class Clazz {
                // @saber.scope(Singleton)
                struct Foo {}
            }

            extension Clazz {
                // @saber.scope(Singleton)
                // @saber.cached
                class Bar {}
            }

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(TypeDeclaration(name: "Clazz.Bar", isReference: true)),
                        storage: .cached
                    ),
                    Service(
                        typeResolver: .explicit(TypeDeclaration(name: "Clazz.Foo")),
                        storage: .none
                    )
                ]
            ]
        )
    }
}
