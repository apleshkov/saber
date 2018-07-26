//
//  Generator+Tests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation
@testable import Saber

private let testConfig: SaberConfiguration = {
    var config = SaberConfiguration.default
    config.accessLevel = "public"
    return config
}()

extension Container {

    init(name: String, dependencies: [TypeUsage] = [], isThreadSafe: Bool = false, imports: [String] = []) {
        self.init(name: name, protocolName: "\(name)Protocol", dependencies: dependencies, isThreadSafe: isThreadSafe, imports: imports)
    }
}

extension ContainerDataFactory {
    
    convenience init() {
        self.init(config: testConfig)
    }
}

extension Renderer {
    
    convenience init(data: ContainerData) {
        self.init(data: data, config: testConfig)
    }
}
