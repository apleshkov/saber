//
//  RendererExternalTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 25/03/2019.
//

import XCTest
@testable import Saber

class RendererExternalTests {
    
    func testExternals() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(AppContainer)
            // @saber.scope(Singleton)
            // @saber.externals(Foo, weak Bar?, unowned Baz)
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

                public let foo: Foo

                public weak var bar: Bar?

                public unowned let baz: Baz

                public init(foo: Foo, Bar?, Baz) {
                    self.foo = foo
                    self.bar = bar
                    self.baz = baz
                }

            }
            """
        )
    }
}
