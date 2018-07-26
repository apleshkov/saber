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
            // @saber.externals(SessionParams)
            protocol SessionContaining {}

            struct SessionParams {
                var user: User
            }

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
        let containers = try! ContainerFactory(repo: repo).make()
        let data = ContainerDataFactory().make(from: containers[1])
        let out = Renderer(data: data).render()
        XCTAssertEqual(
            out,
            """
            import Foundation

            public class SessionContainer: SessionContaining {

                public unowned let appContainer: Module.AppContainer

                public let sessionParams: Module.SessionParams

                private var cached_networkManager: Module.NetworkManager?

                public init(appContainer: Module.AppContainer, sessionParams: Module.SessionParams) {
                    self.appContainer = appContainer
                    self.sessionParams = sessionParams
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

                public var friendList: Module.FriendList {
                    let friendList = self.makeFriendList()
                    return friendList
                }

                public var storage: Storage {
                    let storage = self.makeStorage()
                    return storage
                }

                public var friendCollection: FriendCollection {
                    return self.friendList
                }

                private func makeNetworkManager() -> Module.NetworkManager {
                    return Module.NetworkManager(storage: self.storage)
                }

                private func makeStorageProvider() -> Module.StorageProvider {
                    return Module.StorageProvider()
                }

                private func makeFriendList() -> Module.FriendList {
                    return Module.FriendList()
                }

                private func makeStorage() -> Storage {
                    let provider = self.storageProvider
                    return provider.provide()
                }

                private func injectTo(networkManager: Module.NetworkManager) {
                    networkManager.user = self.sessionParams.user
                }

            }
            """
        )
    }
}
