//
//  Generator+Tests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 29/05/2018.
//

import Foundation
@testable import Saber

extension Container {

    init(name: String, dependencies: [TypeUsage] = [], isThreadSafe: Bool = false, imports: [String] = []) {
        self.init(name: name, protocolName: "\(name)Protocol", dependencies: dependencies, isThreadSafe: isThreadSafe, imports: imports)
    }
}

extension ContainerDataFactory {
    
    convenience init() {
        self.init(config: SaberConfiguration.test)
    }
}

extension Renderer {
    
    convenience init(data: ContainerData) {
        self.init(data: data, config: SaberConfiguration.test)
    }
}

// MARK: Sorting

extension TypeResolver {
    
    func test_sortingKey(modular: Bool) -> String {
        switch self {
        case .container:
            return "saber_tests_container"
        case .explicit(let some):
            return some.fullName(modular: modular)
        case .provided(let usage, _):
            return usage.fullName(modular: modular)
        case .bound(let usage, _):
            return usage.fullName(modular: modular)
        case .derived(let from, let resolver):
            return "\(from.fullName(modular: modular)).\(resolver.test_sortingKey(modular: modular))"
        case .external(let usage):
            return usage.fullName(modular: modular)
        }
    }
}

extension Array where Element == Service {
    
    func test_sorted() -> [Element] {
        let modular = true
        return sorted { (a, b) in
            return a.typeResolver.test_sortingKey(modular: modular) < b.typeResolver.test_sortingKey(modular: modular)
        }
    }
}

extension Array where Element == Container {
    
    func test_sorted() -> [Element] {
        return sorted { $0.name < $1.name }
    }
}
