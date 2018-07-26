//
//  FactoryInjectionHandlerTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 29/06/2018.
//

import XCTest
@testable import Saber

class FactoryInjectionHandlerTests: XCTestCase {
    
    func testSimple() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            class Foo {
                // @saber.didInject
                func postInject() {}
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
                                    isReference: true,
                                    didInjectHandlerName: "postInject"
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
