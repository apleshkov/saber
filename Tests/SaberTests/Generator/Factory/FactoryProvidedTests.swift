//
//  FactoryProvidedTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 16/06/2018.
//

import XCTest
@testable import Saber

class FactoryProvidedTests: XCTestCase {
    
    func testBasic() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            // @saber.cached
            class LoggerProvider {
                // @saber.provider
                func provide() -> Logging {}
            }

            // @saber.scope(Singleton)
            // @saber.cached
            class NetworkManager {
                // @saber.inject
                var logger: Logging!
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let loggerProvider = TypeDeclaration(name: "LoggerProvider", isReference: true)
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(loggerProvider),
                        storage: .cached
                    ),
                    Service(
                        typeResolver: .provided(
                            TypeUsage(name: "Logging"),
                            by: TypeProvider(
                                decl: loggerProvider,
                                methodName: "provide"
                            )
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
                                        typeResolver: .provided(
                                            TypeUsage(name: "Logging"),
                                            by: TypeProvider(
                                                decl: loggerProvider,
                                                methodName: "provide"
                                            )
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
    
    func testNested() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            extension Logger {
                // @saber.scope(Singleton)
                // @saber.cached
                class Provider {
                    // @saber.provider
                    func provide() -> Logger.AbstractLogger {}
                }
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let loggerProvider = TypeDeclaration(name: "Logger.Provider", isReference: true)
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .provided(
                            TypeUsage(name: "Logger.AbstractLogger"),
                            by: TypeProvider(
                                decl: loggerProvider,
                                methodName: "provide"
                            )
                        ),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(loggerProvider),
                        storage: .cached
                    )
                ]
            ]
        )
    }
    
    func testKnownOptional() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            protocol AppConfig {}

            class FileLogger {}

            // @saber.scope(Singleton)
            // @saber.cached
            class LoggerProvider {
                // @saber.provider
                func provide() -> FileLogger? {}
            }

            // @saber.scope(Singleton)
            // @saber.cached
            class NetworkManager {
                // @saber.inject
                var logger: FileLogger?
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let loggerProvider = TypeDeclaration(name: "LoggerProvider", isReference: true)
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .provided(
                            TypeUsage(name: "FileLogger", isOptional: true),
                            by: TypeProvider(
                                decl: loggerProvider,
                                methodName: "provide"
                            )
                        ),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(loggerProvider),
                        storage: .cached
                    ),
                    Service(
                        typeResolver: .explicit(
                            TypeDeclaration(
                                name: "NetworkManager",
                                isReference: true,
                                memberInjections: [
                                    MemberInjection(
                                        name: "logger",
                                        typeResolver: .provided(
                                            TypeUsage(name: "FileLogger", isOptional: true),
                                            by: TypeProvider(
                                                decl: loggerProvider,
                                                methodName: "provide"
                                            )
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
