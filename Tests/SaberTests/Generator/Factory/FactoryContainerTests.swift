//
//  FactoryContainerTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 15/06/2018.
//

import XCTest
@testable import Saber

class FactoryContainerTests: XCTestCase {
    
    func testSimple() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
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
                Container(
                    name: "App",
                    protocolName: "AppConfig"
                )
            ]
        )
    }
    
    func testDependencyAndExternalOrder() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(FooContainer)
            // @saber.scope(Foo)
            protocol FooContaining {}

            // @saber.container(BarContainer)
            // @saber.scope(Bar)
            protocol BarContaining {}

            // @saber.container(QuuxContainer)
            // @saber.scope(Quux)
            // @saber.dependsOn(FooContainer, BarContainer)
            // @saber.externals(FooExternal, BarExternal)
            protocol QuuxContaining {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let quuxContainer = try! ContainerFactory(repo: repo).make().test_sorted()[2]
        XCTAssertEqual(
            quuxContainer,
            Container(
                name: "QuuxContainer",
                protocolName: "QuuxContaining",
                dependencies: [
                    TypeUsage(name: "FooContainer"),
                    TypeUsage(name: "BarContainer")
                ],
                externals: [
                    ContainerExternal(type: TypeUsage(name: "FooExternal")),
                    ContainerExternal(type: TypeUsage(name: "BarExternal"))
                ]
            )
        )
    }
    
    func testImportsAndThreadSafe() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.imports(UIKit, SomeModule)
            // @saber.threadSafe
            protocol AppConfig {}
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
                    isThreadSafe: true,
                    imports: ["UIKit", "SomeModule"]
                )
            ]
        )
    }
    
    func testCyclicDependencies() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            struct Foo {
                init(bar: Bar) {}
            }

            // @saber.scope(Singleton)
            struct Bar {
                init(foo: Foo) {}
            }

            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        XCTAssertThrowsError(try ContainerFactory(repo: repo).make())
    }
    
    func testContainerAsDependency() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            struct Foo {
                // @saber.inject
                unowned var appContainer: App
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
                                    name: "Foo",
                                    memberInjections: [
                                        MemberInjection(name: "appContainer", typeResolver: .container)
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
    
    func testContainerAsDerivedDependency() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.container(Session)
            // @saber.scope(Session)
            // @saber.dependsOn(App)
            protocol SessionConfig {}

            // @saber.scope(Session)
            struct Foo {
                // @saber.inject
                unowned var appContainer: App
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(
            containers.test_sorted(),
            [
                Container(
                    name: "App",
                    protocolName: "AppConfig"
                ),
                Container(
                    name: "Session",
                    protocolName: "SessionConfig",
                    dependencies: [TypeUsage(name: "App")],
                    services: [
                        Service(
                            typeResolver: .explicit(
                                TypeDeclaration(
                                    name: "Foo",
                                    memberInjections: [
                                        MemberInjection(
                                            name: "appContainer",
                                            typeResolver: .derived(
                                                from: TypeUsage(name: "App"),
                                                typeResolver: .container
                                            )
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
}
