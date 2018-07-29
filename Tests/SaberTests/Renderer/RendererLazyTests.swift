//
//  RendererLazyTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 27/07/2018.
//

import XCTest
@testable import Saber

class RendererLazyTests: XCTestCase {
    
    func testLazy() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(AppContainer)
            // @saber.scope(Singleton)
            protocol AppContaining {}

            // @saber.scope(Singleton)
            class Foo {}

            // @saber.scope(Singleton)
            class Bar {
                // @saber.inject
                var makeFoo: (() -> Foo)!

                // @saber.inject
                func set(fooFactory: () -> Foo) {}

                init(foo: () -> Foo) {}
            }
            """
            ).parse(to: factory)
        let repo = try! TypeRepository(parsedData: factory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        var appContainer = containers[0]
        appContainer.services = appContainer.services.test_sorted()
        let data = ContainerDataFactory().make(from: appContainer)
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation

            public class AppContainer: AppContaining {

                public init() {
                }

                public var bar: Bar {
                    let bar = self.makeBar()
                    self.injectTo(bar: bar)
                    return bar
                }

                public var foo: Foo {
                    let foo = self.makeFoo()
                    return foo
                }

                private func makeBar() -> Bar {
                    return Bar(foo: { [unowned self] in return self.foo })
                }

                private func makeFoo() -> Foo {
                    return Foo()
                }

                private func injectTo(bar: Bar) {
                    bar.makeFoo = { [unowned self] in return self.foo }
                    bar.set(fooFactory: { [unowned self] in return self.foo })
                }

            }
            """
        )
    }
}
