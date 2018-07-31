//
//  FactoryExternalTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 15/06/2018.
//

import XCTest
@testable import Saber

class FactoryExternalTests: XCTestCase {
    
    func testSimple() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(AppExternals)
            protocol AppConfig {}

            class AppExternals {

                static let ignoredProperty: Ignored // static
                static func ignoredFunc() -> Ignored {} // static

                private var ignoredPrivateProperty: Ignored
                private func ignoredPrivateMethod() -> Ignored {}

                fileprivate var ignoredFileprivateProperty: Ignored
                fileprivate func ignoredFileprivateMethod() -> Ignored {}

                func foo() {} // no return type

                let logger: FileLogger
                func networkManager() -> NetworkManager {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let external = ContainerExternal(
            type: TypeUsage(name: "AppExternals"),
            kinds: [
                .method(name: "networkManager", args: []),
                .property(name: "logger")
            ]
        )
        XCTAssertEqual(
            containers,
            [
                Container(
                    name: "App",
                    protocolName: "AppConfig",
                    externals: [external]
                )
            ]
        )
    }
    
    func testUsage() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(AppExternals)
            protocol AppConfig {}

            class AppExternals {
                func networkManager(userStorage: UserStorage) -> NetworkManager {}
            }

            // @saber.scope(Singleton)
            class ListAPI {
                init(networkManager: NetworkManager) {}
            }

            // @saber.scope(Singleton)
            class UserStorage {}
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let external = ContainerExternal(
            type: TypeUsage(name: "AppExternals"),
            kinds: [
                .method(
                    name: "networkManager",
                    args: [
                        FunctionInvocationArgument(
                            name: "userStorage",
                            typeResolver: .explicit(TypeUsage(name: "UserStorage"))
                        )
                    ]
                )
            ]
        )
        let listAPI: TypeDeclaration = {
            var listAPI = TypeDeclaration(name: "ListAPI")
            listAPI.isReference = true
            listAPI.initializer = .some(
                args: [
                    FunctionInvocationArgument(
                        name: "networkManager",
                        typeResolver: .external(
                            from: TypeUsage(name: "AppExternals"),
                            kind: .method(
                                name: "networkManager",
                                args: [
                                    FunctionInvocationArgument(
                                        name: "userStorage",
                                        typeResolver: .explicit(TypeUsage(name: "UserStorage"))
                                    )
                                ]
                            )
                        )
                    )
                ]
            )
            return listAPI
        }()
        XCTAssertEqual(containers.map { $0.externals }, [[external]])
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(listAPI),
                        storage: .none
                    ),
                    Service(
                        typeResolver: .explicit(TypeDeclaration(name: "UserStorage", isReference: true)),
                        storage: .none
                    )
                ]
            ]
        )
    }
}
