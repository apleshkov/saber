//
//  RendererTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 28/06/2018.
//

import XCTest
@testable import Saber

class RendererTests: XCTestCase {
    
    func testEmptyInitializer() {
        let container = Container(name: "Foo")
        let data = ContainerDataFactory().make(from: container)
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation

            public class Foo: FooProtocol {

                public init() {
                }

            }
            """
        )
    }

    func testComplexInitializer() {
        var initializer = ContainerData.Initializer()
        initializer.args = [("bar", "Bar"), ("baz", "Baz")]
        initializer.creations = ["let quux = Quux()"]
        initializer.storedProperties = ["self.quux = quux"]
        let data = ContainerData(name: "Foo", initializer: initializer)
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            public class Foo {

                public init(bar: Bar, baz: Baz) {
                    let quux = Quux()
                    self.quux = quux
                }

            }
            """
        )
    }

    func testInheritanceAndImports() {
        var data = ContainerData(name: "Foo", initializer: ContainerData.Initializer())
        data.imports = ["Foundation", "UIKit"]
        data.inheritedFrom = ["Bar", "Baz"]
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation
            import UIKit

            public class Foo: Bar, Baz {

                public init() {
                }

            }
            """
        )
    }

    func testStoredProperties() {
        var data = ContainerData(name: "Foo", initializer: ContainerData.Initializer())
        data.storedProperties = [
            ["private let bar: Bar"],
            ["private let baz: Baz"]
        ]
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            public class Foo {

                private let bar: Bar

                private let baz: Baz

                public init() {
                }

            }
            """
        )
    }

    func testGettersMakersInjectors() {
        var data = ContainerData(name: "Foo", initializer: ContainerData.Initializer())
        data.getters = [
            [
                "var bar: Bar? {",
                "    return self.makeBar()",
                "}"
            ],
            [
                "var baz: Baz {",
                "    return self.makeBaz()",
                "}"
            ]
        ]
        data.makers = [
            [
                "func makeBar() -> Bar? {",
                "    return Bar()",
                "}"
            ],
            [
                "func makeBaz() -> Baz {",
                "    return Baz()",
                "}"
            ]
        ]
        data.injectors = [
            [
                "func injectTo(bar: Bar?) {",
                "    bar?.baz = self.baz",
                "}"
            ],
            [
                "func injectTo(baz: Baz) {",
                "    baz.set(bar: self.bar)",
                "}"
            ]
        ]
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            public class Foo {

                public init() {
                }

                var bar: Bar? {
                    return self.makeBar()
                }

                var baz: Baz {
                    return self.makeBaz()
                }

                func makeBar() -> Bar? {
                    return Bar()
                }

                func makeBaz() -> Baz {
                    return Baz()
                }

                func injectTo(bar: Bar?) {
                    bar?.baz = self.baz
                }

                func injectTo(baz: Baz) {
                    baz.set(bar: self.bar)
                }

            }
            """
        )
    }
    
    func testMultipleDependenciesAndExternals() {
        let factory = ParsedDataFactory()
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
            // @saber.externals(ExternalA, ExternalB)
            protocol QuuxContaining {}
            
            """
            ).parse(to: factory)
        let repo = try! TypeRepository(parsedData: factory.make())
        let containers = try! ContainerFactory(repo: repo).make().test_sorted()
        let quuxContainer = containers.test_sorted()[2]
        let data = ContainerDataFactory().make(from: quuxContainer)
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation

            public class QuuxContainer: QuuxContaining {

                public unowned let fooContainer: FooContainer

                public unowned let barContainer: BarContainer

                public let externalA: ExternalA

                public let externalB: ExternalB

                public init(fooContainer: FooContainer, barContainer: BarContainer, externalA: ExternalA, externalB: ExternalB) {
                    self.fooContainer = fooContainer
                    self.barContainer = barContainer
                    self.externalA = externalA
                    self.externalB = externalB
                }

            }
            """
        )
    }
}
