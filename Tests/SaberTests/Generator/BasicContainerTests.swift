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
        container.externals = [
            ContainerExternal(type: TypeUsage(name: "Env"), refType: .strong),
            ContainerExternal(
                type: TypeUsage(name: "User").set(isOptional: true),
                refType: .strong
            ),
            ContainerExternal(
                type: TypeUsage(name: "Storage", isUnwrapped: true),
                refType: .strong
            )
        ]
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.initializer.args.map { "\($0.name): \($0.typeName)" },
            ["env: Env", "user: User?", "storage: Storage!"]
        )
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public let env: Env"],
                ["public let user: User?"],
                ["public let storage: Storage!"]
            ]
        )
        XCTAssertEqual(
            data.initializer.storedProperties,
            [
                "self.env = env",
                "self.user = user",
                "self.storage = storage"
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
    
    func testStrongExternals() {
        var container = Container(name: "Test")
        container.externals = [
            ContainerExternal(
                type: TypeUsage(name: "Foo"),
                refType: .strong
            ),
            ContainerExternal(
                type: TypeUsage(name: "Bar", isOptional: true),
                refType: .strong
            ),
            ContainerExternal(
                type: TypeUsage(name: "Baz", isUnwrapped: true),
                refType: .strong
            )
        ]
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public let foo: Foo"],
                ["public let bar: Bar?"],
                ["public let baz: Baz!"]
            ]
        )
    }
    
    func testWeakExternals() {
        var container = Container(name: "Test")
        container.externals = [
            ContainerExternal(
                type: TypeUsage(name: "Foo"),
                refType: .weak
            ),
            ContainerExternal(
                type: TypeUsage(name: "Bar", isOptional: true),
                refType: .weak
            ),
            ContainerExternal(
                type: TypeUsage(name: "Baz", isUnwrapped: true),
                refType: .weak
            )
        ]
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public weak var foo: Foo"],
                ["public weak var bar: Bar?"],
                ["public weak var baz: Baz!"]
            ]
        )
    }
    
    func testUnownedExternals() {
        var container = Container(name: "Test")
        container.externals = [
            ContainerExternal(
                type: TypeUsage(name: "Foo"),
                refType: .unowned
            ),
            ContainerExternal(
                type: TypeUsage(name: "Bar", isOptional: true),
                refType: .unowned
            ),
            ContainerExternal(
                type: TypeUsage(name: "Baz", isUnwrapped: true),
                refType: .unowned
            )
        ]
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public unowned let foo: Foo"],
                ["public unowned let bar: Bar?"],
                ["public unowned let baz: Baz!"]
            ]
        )
    }
}
