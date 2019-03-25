//
//  FactoryExternalTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 15/06/2018.
//

import XCTest
@testable import Saber

class FactoryExternalTests: XCTestCase {
    
    func testDeclared() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(NetworkManager)
            protocol AppConfig {}

            class NetworkManager {}

            // @saber.scope(Singleton)
            class ListAPI {
                init(networkManager: NetworkManager) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let external = ContainerExternal(
            type: TypeUsage(name: "NetworkManager"),
            refType: .strong
        )
        let listAPI: TypeDeclaration = {
            var listAPI = TypeDeclaration(name: "ListAPI")
            listAPI.isReference = true
            listAPI.initializer = .some(
                args: [
                    FunctionInvocationArgument(
                        name: "networkManager",
                        typeResolver: .external(
                            TypeUsage(name: "NetworkManager")
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
                    )
                ]
            ]
        )
    }
    
    func testOptional() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(NetworkManager?, Logger?)
            protocol AppConfig {}

            class Logger {}

            // @saber.scope(Singleton)
            class ListAPI {
                init(networkManager: NetworkManager?, logger: Logger?) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let externals = [
            ContainerExternal(
                type: TypeUsage(name: "NetworkManager", isOptional: true),
                refType: .strong
            ),
            ContainerExternal(
                type: TypeUsage(name: "Logger", isOptional: true),
                refType: .strong
            )
        ]
        let listAPI: TypeDeclaration = {
            var listAPI = TypeDeclaration(name: "ListAPI")
            listAPI.isReference = true
            listAPI.initializer = .some(
                args: [
                    FunctionInvocationArgument(
                        name: "networkManager",
                        typeResolver: .external(
                            TypeUsage(name: "NetworkManager", isOptional: true)
                        )
                    ),
                    FunctionInvocationArgument(
                        name: "logger",
                        typeResolver: .external(
                            TypeUsage(name: "Logger", isOptional: true)
                        )
                    )
                ]
            )
            return listAPI
        }()
        XCTAssertEqual(containers.map { $0.externals }, [externals])
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(listAPI),
                        storage: .none
                    )
                ]
            ]
        )
    }
    
    func testUnwrapped() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(NetworkManager!, Logger!)
            protocol AppConfig {}

            class Logger {}

            // @saber.scope(Singleton)
            class ListAPI {
                init(networkManager: NetworkManager!, logger: Logger!) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let externals = [
            ContainerExternal(
                type: TypeUsage(name: "NetworkManager", isUnwrapped: true),
                refType: .strong
            ),
            ContainerExternal(
                type: TypeUsage(name: "Logger", isUnwrapped: true),
                refType: .strong
            )
        ]
        let listAPI: TypeDeclaration = {
            var listAPI = TypeDeclaration(name: "ListAPI")
            listAPI.isReference = true
            listAPI.initializer = .some(
                args: [
                    FunctionInvocationArgument(
                        name: "networkManager",
                        typeResolver: .external(
                            TypeUsage(name: "NetworkManager", isUnwrapped: true)
                        )
                    ),
                    FunctionInvocationArgument(
                        name: "logger",
                        typeResolver: .external(
                            TypeUsage(name: "Logger", isUnwrapped: true)
                        )
                    )
                ]
            )
            return listAPI
        }()
        XCTAssertEqual(containers.map { $0.externals }, [externals])
        XCTAssertEqual(
            containers.map { $0.services.test_sorted() },
            [
                [
                    Service(
                        typeResolver: .explicit(listAPI),
                        storage: .none
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
            // @saber.externals(Foo.NetworkManager)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            class ListAPI {
                init(networkManager: Foo.NetworkManager) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let external = ContainerExternal(
            type: TypeUsage(name: "Foo.NetworkManager"),
            refType: .strong
        )
        let listAPI: TypeDeclaration = {
            var listAPI = TypeDeclaration(name: "ListAPI")
            listAPI.isReference = true
            listAPI.initializer = .some(
                args: [
                    FunctionInvocationArgument(
                        name: "networkManager",
                        typeResolver: .external(
                            TypeUsage(name: "Foo.NetworkManager")
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
                    )
                ]
            ]
        )
    }
    
    func testInitializer() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(Foo, Bar)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let externals = [
            ContainerExternal(type: TypeUsage(name: "Foo"), refType: .strong),
            ContainerExternal(type: TypeUsage(name: "Bar"), refType: .strong)
        ]
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(containers.map { $0.externals }, [externals])
    }
    
    func testWeak() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(weak Foo, weak Bar?, weak Baz!)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let externals = [
            ContainerExternal(type: TypeUsage(name: "Foo"), refType: .weak),
            ContainerExternal(type: TypeUsage(name: "Bar", isOptional: true), refType: .weak),
            ContainerExternal(type: TypeUsage(name: "Baz", isUnwrapped: true), refType: .weak)
        ]
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(containers.map { $0.externals }, [externals])
    }
    
    func testUnowned() {
        let parsedFactory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(App)
            // @saber.scope(Singleton)
            // @saber.externals(unowned Foo, unowned Bar?, unowned Baz!)
            protocol AppConfig {}
            """
            ).parse(to: parsedFactory)
        let externals = [
            ContainerExternal(type: TypeUsage(name: "Foo"), refType: .unowned),
            ContainerExternal(type: TypeUsage(name: "Bar", isOptional: true), refType: .unowned),
            ContainerExternal(type: TypeUsage(name: "Baz", isUnwrapped: true), refType: .unowned)
        ]
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(containers.map { $0.externals }, [externals])
    }
}
