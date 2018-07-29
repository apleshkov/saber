//
//  FactoryBoundTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 16/06/2018.
//

import XCTest
@testable import Saber

class FactoryBoundTests: XCTestCase {
    
    func testSimple() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            // @saber.cached
            // @saber.bindTo(Logging)
            class FileLogger {}

            // @saber.scope(Singleton)
            // @saber.cached
            class NetworkManager {
                // @saber.inject
                var logger: Logging?
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let fileLogger = TypeDeclaration(name: "FileLogger", isReference: true)
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(fileLogger),
                        storage: .cached
                    ),
                    Service(
                        typeResolver: .bound(
                            TypeUsage(name: "Logging"),
                            to: fileLogger
                        ),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(
                                name: "NetworkManager",
                                isReference: true,
                                memberInjections: [
                                    MemberInjection(
                                        name: "logger",
                                        typeResolver: .bound(
                                            TypeUsage(name: "Logging"),
                                            to: TypeUsage(name: "FileLogger")
                                        )
                                    )
                                ]
                            )
                        ),
                        storage: .cached
                    )
                ]
            ]
        )
    }
}
