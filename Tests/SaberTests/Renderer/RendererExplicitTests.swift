//
//  RendererExplicitTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 26/03/2019.
//

import XCTest
@testable import Saber

class RendererExplicitTests: XCTestCase {
    
    func testOptional() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.scope(Singleton)
            // @saber.cached
            class Foo {
                init?() {}
            }

            // @saber.container(AppContainer)
            // @saber.scope(Singleton)
            protocol AppContaining {}
            """
            ).parse(to: factory)
        let repo = try! TypeRepository(parsedData: factory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let appContainer = containers[0]
        let data = ContainerDataFactory().make(from: appContainer)
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation

            public class AppContainer: AppContaining {

                private var cached_foo: Foo?

                public init() {
                }

                public var foo: Foo? {
                    if let cached = self.cached_foo { return cached }
                    let foo = self.makeFoo()
                    self.cached_foo = foo
                    return foo
                }

                private func makeFoo() -> Foo? {
                    return Foo()
                }

            }
            """
        )
    }
}
