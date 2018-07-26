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
            // @saber.externals(AppExternals)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo {
                init() {}
            }

            struct AppExternals {
                let bar: Bar
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
                                            from: TypeUsage(name: "AppExternals"),
                                            kind: .property(name: "bar")
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
            // @saber.externals(AppExternals)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo {}

            struct AppExternals {
                let bar: Bar
                let baz: Baz
            }

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
                                        from: TypeUsage(name: "AppExternals"),
                                        kind: .property(name: "bar")
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
                                                from: TypeUsage(name: "AppExternals"),
                                                kind: .property(name: "baz")
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
