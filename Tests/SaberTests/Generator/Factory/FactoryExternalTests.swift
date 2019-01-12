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
            type: TypeUsage(name: "NetworkManager")
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
            // @saber.externals(NetworkManager?)
            protocol AppConfig {}

            // @saber.scope(Singleton)
            class ListAPI {
                init(networkManager: NetworkManager?) {}
            }
            """
            ).parse(to: parsedFactory)
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        let external = ContainerExternal(
            type: TypeUsage(name: "NetworkManager", isOptional: true)
        )
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
            type: TypeUsage(name: "Foo.NetworkManager")
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
            ContainerExternal(type: TypeUsage(name: "Foo")),
            ContainerExternal(type: TypeUsage(name: "Bar"))
        ]
        let repo = try! TypeRepository(parsedData: parsedFactory.make())
        let containers = try! ContainerFactory(repo: repo).make()
        XCTAssertEqual(containers.map { $0.externals }, [externals])
    }
}
