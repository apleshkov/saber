//
//  RendererModuleTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 06/07/2018.
//

import XCTest
@testable import Saber

class RendererModuleTests: XCTestCase {
    
    func testModules() {
        let factory = ParsedDataFactory()
        try! FileParser(contents:
            """
            // @saber.container(AppContainer)
            // @saber.scope(Singleton)
            protocol AppContaining {}

            // @saber.container(SessionContainer)
            // @saber.scope(Session)
            // @saber.dependsOn(AppContainer)
            // @saber.externals(User)
            protocol SessionContaining {}

            // @saber.scope(Session)
            // @saber.cached
            class NetworkManager {
                // @saber.inject
                var user: User

                init(storage: Storage) {}
            }

            // @saber.scope(Session)
            class StorageProvider {
                // @saber.provider
                func provide(friends: FriendCollection) -> Storage {}
            }

            // @saber.scope(Session)
            // @saber.bindTo(FriendCollection)
            class FriendList {}
            """, moduleName: "Module"
            ).parse(to: factory)
        let repo = try! TypeRepository(parsedData: factory.make())
        let containers = try! ContainerFactory(repo: repo).make().test_sorted()
        var sessContainer = containers.test_sorted()[1]
        sessContainer.services = sessContainer.services.test_sorted()
        let data = ContainerDataFactory().make(from: sessContainer)
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation

            public class SessionContainer: SessionContaining {

                public unowned let appContainer: Module.AppContainer

                public let user: User

                private var cached_networkManager: Module.NetworkManager?

                public init(appContainer: Module.AppContainer, user: User) {
                    self.appContainer = appContainer
                    self.user = user
                }

                public var friendCollection: FriendCollection {
                    return self.friendList
                }

                public var friendList: Module.FriendList {
                    let friendList = self.makeFriendList()
                    return friendList
                }

                public var networkManager: Module.NetworkManager {
                    if let cached = self.cached_networkManager { return cached }
                    let networkManager = self.makeNetworkManager()
                    self.injectTo(networkManager: networkManager)
                    self.cached_networkManager = networkManager
                    return networkManager
                }

                public var storageProvider: Module.StorageProvider {
                    let storageProvider = self.makeStorageProvider()
                    return storageProvider
                }

                public var storage: Storage {
                    let storage = self.makeStorage()
                    return storage
                }

                private func makeFriendList() -> Module.FriendList {
                    return Module.FriendList()
                }

                private func makeNetworkManager() -> Module.NetworkManager {
                    return Module.NetworkManager(storage: self.storage)
                }

                private func makeStorageProvider() -> Module.StorageProvider {
                    return Module.StorageProvider()
                }

                private func makeStorage() -> Storage {
                    let provider = self.storageProvider
                    return provider.provide()
                }

                private func injectTo(networkManager: Module.NetworkManager) {
                    networkManager.user = self.user
                }

            }
            """
        )
    }
}
