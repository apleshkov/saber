//
//  SaberTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 30/04/2018.
//

import XCTest
@testable import Saber

class BasicContainerTests: XCTestCase {

    func testInitArguments() {
        var container = Container(name: "Test")
        container.externals.append(ContainerExternal(type: TypeUsage(name: "Env")))
        container.externals.append(ContainerExternal(type: TypeUsage(name: "User").set(isOptional: true)))
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.initializer.args.map { "\($0.name): \($0.typeName)" },
            ["env: Env", "user: User?"]
        )
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public let env: Env"],
                ["public let user: User?"]
            ]
        )
        XCTAssertEqual(
            data.initializer.storedProperties,
            [
                "self.env = env",
                "self.user = user"
            ]
        )
    }
    
    func testName() {
        let container = Container(name: "Test")
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(data.name, "Test")
    }

    func testInheritance() {
        let container = Container(name: "Test", protocolName: "TestContaining")
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(data.inheritedFrom, ["TestContaining"])
    }
    
    func testThreadSafe() {
        let container = Container(name: "Test", isThreadSafe: true)
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(data.storedProperties, [["private let lock = NSRecursiveLock()"]])
    }
    
    func testImports() {
        let container = Container(name: "Test", imports: ["UIKit"])
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(data.imports, ["Foundation", "UIKit"])
    }
}
