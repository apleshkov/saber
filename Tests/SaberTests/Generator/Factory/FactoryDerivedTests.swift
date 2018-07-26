//
//  FactoryDerivedTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 19/06/2018.
//

import XCTest
@testable import Saber

class FactoryDerivedTests: XCTestCase {
    
    func testExplicit() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            struct Foo {}

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.container(User)
            // @saber.scope(User)
            // @saber.dependsOn(App)
            protocol UserConfig {}

            // @saber.scope(User)
            struct Bar {
                init(foo: Foo) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            container(named: "User", in: containers)?.services,
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Bar",
                            initializer: .some(
                                args: [
                                    FunctionInvocationArgument(
                                        name: "foo",
                                        typeResolver: .derived(
                                            from: TypeUsage(name: "App"),
                                            typeResolver: .explicit(TypeUsage(name: "Foo"))
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

    func testProvided() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            struct FooProvider {
                // @saber.provider
                func provide() -> Foo {}
            }

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.container(User)
            // @saber.scope(User)
            // @saber.dependsOn(App)
            protocol UserConfig {}

            // @saber.scope(User)
            struct Bar {
                init(foo: Foo) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            container(named: "User", in: containers)?.services,
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Bar",
                            initializer: .some(
                                args: [
                                    FunctionInvocationArgument(
                                        name: "foo",
                                        typeResolver: .derived(
                                            from: TypeUsage(name: "App"),
                                            typeResolver: .provided(
                                                TypeUsage(name: "Foo"),
                                                by: TypeProvider(
                                                    decl: TypeDeclaration(name: "FooProvider"),
                                                    methodName: "provide"
                                                )
                                            )
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

    func testBound() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            // @saber.bindTo(Foo)
            struct FooImpl {}

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.container(User)
            // @saber.scope(User)
            // @saber.dependsOn(App)
            protocol UserConfig {}

            // @saber.scope(User)
            struct Bar {
                init(foo: Foo) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            container(named: "User", in: containers)?.services,
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Bar",
                            initializer: .some(
                                args: [
                                    FunctionInvocationArgument(
                                        name: "foo",
                                        typeResolver: .derived(
                                            from: TypeUsage(name: "App"),
                                            typeResolver: .bound(
                                                TypeUsage(name: "Foo"),
                                                to: TypeUsage(name: "FooImpl")
                                            )
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

    func testExternal() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            struct AppExternal {
                var foo: Foo
            }

            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(AppExternal)
            protocol AppConfig {}

            // @saber.container(User)
            // @saber.scope(User)
            // @saber.dependsOn(App)
            protocol UserConfig {}

            // @saber.scope(User)
            struct Bar {
                init(foo: Foo) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            container(named: "User", in: containers)?.services,
            [
                Service(
                    typeResolver: .explicit(
                        TypeDeclaration(
                            name: "Bar",
                            initializer: .some(
                                args: [
                                    FunctionInvocationArgument(
                                        name: "foo",
                                        typeResolver: .derived(
                                            from: TypeUsage(name: "App"),
                                            typeResolver: .external(
                                                from: TypeUsage(name: "AppExternal"),
                                                kind: .property(name: "foo")
                                            )
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
}

private func container(named name: String, in containers: [Container]) -> Container? {
    for entry in containers {
        if entry.name == name {
            return entry
        }
    }
    return nil
}
