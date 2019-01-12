//
//  FactoryExtensionTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 29/06/2018.
//

import XCTest
@testable import Saber

class FactoryExtensionTests: XCTestCase {

    func testInit() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(Bar)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo {
                init() {}
            }

            extension Foo {

                // @saber.inject
                init(bar: Bar) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.first?.services,
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Foo",
                            initializer: .some(
                                args: [
                                    FunctionInvocationArgument(
                                        name: "bar",
                                        typeResolver: .external(
                                            TypeUsage(name: "Bar")
                                        )
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

    func testInjectors() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(Bar, Baz)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo {}

            extension Foo {

                // @saber.inject
                var bar: Bar {
                    set {}
                    get {}
                }

                // @saber.inject
                func set(baz: Baz) {}

                // @saber.didInject
                func postInject() {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.first?.services,
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Foo",
                            memberInjections: [
                                MemberInjection(
                                    name: "bar",
                                    typeResolver: .external(
                                        TypeUsage(name: "Bar")
                                    )
                                )
                            ],
                            methodInjections: [
                                InstanceMethodInjection(
                                    methodName: "set",
                                    args: [
                                        FunctionInvocationArgument(
                                            name: "baz",
                                            typeResolver: .external(
                                                TypeUsage(name: "Baz")
                                            )
                                        )
                                    ]
                                )
                            ],
                            didInjectHandlerName: "postInject"
                        )
                    ),
                    storage: .none
                )
            ]
        )
    }

    func testUnknown() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            extension Foo {

                // @saber.inject
                var bar: Bar {
                    set {}
                    get {}
                }

                // @saber.inject
                func set(baz: Baz) {}

                // @saber.didInject
                func postInject() {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.first?.services,
            []
        )
    }
}
