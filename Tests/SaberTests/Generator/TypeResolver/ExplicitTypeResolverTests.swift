//
//  ExplicitTypeResolverTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 11/05/2018.
//

import XCTest
@testable import Saber

class ExplicitTypeResolverTests: XCTestCase {

    func testValue() {
        let decl = TypeDeclaration(name: "FooBar")
        let resolver = TypeResolver.explicit(decl)
        let service = Service(typeResolver: resolver, storage: .none)
        let container = Container(name: "Test").add(service: service)
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            []
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var fooBar: FooBar {",
                    "    let fooBar = self.makeFooBar()",
                    "    return fooBar",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeFooBar() -> FooBar {",
                    "    return FooBar()",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.injectors,
            []
        )
    }
    
    func testValueWithMemberInjections() {
        var decl = TypeDeclaration(name: "FooBar")
        decl.memberInjections = [MemberInjection(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))]
        let resolver = TypeResolver.explicit(decl)
        let service = Service(typeResolver: resolver, storage: .none)
        let container = Container(name: "Test").add(service: service)
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            []
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var fooBar: FooBar {",
                    "    var fooBar = self.makeFooBar()",
                    "    self.injectTo(fooBar: &fooBar)",
                    "    return fooBar",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeFooBar() -> FooBar {",
                    "    return FooBar()",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.injectors,
            [
                [
                    "private func injectTo(fooBar: inout FooBar) {",
                    "    fooBar.quux = self.quux",
                    "}"
                ]
            ]
        )
    }
    
    func testNoInitializer() {
        var decl = TypeDeclaration(name: "FooBar").set(initializer: .none)
        decl.memberInjections = [MemberInjection(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))]
        let resolver = TypeResolver.explicit(decl)
        let service = Service(typeResolver: resolver, storage: .none)
        let container = Container(name: "Test").add(service: service)
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            []
        )
        XCTAssertEqual(
            data.getters,
            []
        )
        XCTAssertEqual(
            data.makers,
            []
        )
        XCTAssertEqual(
            data.injectors,
            [
                [
                    "public func injectTo(fooBar: inout FooBar) {",
                    "    fooBar.quux = self.quux",
                    "}"
                ]
            ]
        )
    }
}
