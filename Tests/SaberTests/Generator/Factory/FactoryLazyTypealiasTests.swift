//
//  FactoryLazyTypealiasTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 09/08/2018.
//

import XCTest
@testable import Saber

class FactoryLazyTypealiasTests: XCTestCase {
    
    func testInitializer() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Bar {}

            // @saber.scope(Singleton)
            class Foo {
                init(bar: LazyInjection<Bar>) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.first?.services.test_sorted(),
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(name: "Bar")
                    ),
                    storage: .none
                ),
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Foo",
                            isReference: true,
                            initializer: .some(
                                args: [
                                    FunctionInvocationArgument(
                                        name: "bar",
                                        typeResolver: .explicit(TypeUsage(name: "Bar")),
                                        isLazy: true
                                    )
                                ]
                            )
                        )
                    ),
                    storage: .none
                )
            ]
        )
    }

    func testPropertyInjections() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Bar {}

            // @saber.scope(Singleton)
            class Foo {
                // @saber.inject
                var bar: LazyInjection<Bar>!
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.first?.services.test_sorted(),
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(name: "Bar")
                    ),
                    storage: .none
                ),
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Foo",
                            isReference: true,
                            memberInjections: [
                                MemberInjection(
                                    name: "bar",
                                    typeResolver: .explicit(TypeUsage(name: "Bar")),
                                    isLazy: true
                                )
                            ]
                        )
                    ),
                    storage: .none
                )
            ]
        )
    }

    func testMethodInjections() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Bar {}

            // @saber.scope(Singleton)
            class Foo {
                // @saber.inject
                func set(bar: LazyInjection<Bar>) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.first?.services.test_sorted(),
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(name: "Bar")
                    ),
                    storage: .none
                ),
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Foo",
                            isReference: true,
                            methodInjections: [
                                InstanceMethodInjection(
                                    methodName: "set",
                                    args: [
                                        FunctionInvocationArgument(
                                            name: "bar",
                                            typeResolver: .explicit(TypeUsage(name: "Bar")),
                                            isLazy: true
                                        )
                                    ]
                                )
                            ]
                        )
                    ),
                    storage: .none
                )
            ]
        )
    }
}
