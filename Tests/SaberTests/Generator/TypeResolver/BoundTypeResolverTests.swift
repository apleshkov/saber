//
//  BoundTypeResolverTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 11/05/2018.
//

import XCTest
@testable import Saber

class BoundTypeResolverTests: XCTestCase {

    func testOptional() {
        let binderDecl = TypeDeclaration(name: "Foo").set(isOptional: true)
        let resolver = TypeResolver.bound(
            TypeUsage(name: "FooProtocol").set(isOptional: true),
            to: binderDecl
        )
        let service = Service(typeResolver: resolver, storage: .none)
        let container = Container(name: "Test")
            .add(service: service)
            .add(service: Service(typeResolver: .explicit(binderDecl), storage: .none))
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            []
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var fooProtocol: FooProtocol? {",
                    "    return self.foo",
                    "}"
                ],
                [
                    "public var foo: Foo? {",
                    "    let foo = self.makeFoo()",
                    "    return foo",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeFoo() -> Foo? {",
                    "    return Foo()",
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
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [MemberInjection(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))]
        let resolver = TypeResolver.bound(
            TypeUsage(name: "FooProtocol"),
            to: decl
        )
        let service = Service(typeResolver: resolver, storage: .none)
        let container = Container(name: "Test")
            .add(service: service)
            .add(service: Service(typeResolver: .explicit(decl), storage: .none))
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            []
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var fooProtocol: FooProtocol {",
                    "    return self.foo",
                    "}"
                ],
                [
                    "public var foo: Foo {",
                    "    var foo = self.makeFoo()",
                    "    self.injectTo(foo: &foo)",
                    "    return foo",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeFoo() -> Foo {",
                    "    return Foo()",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.injectors,
            [
                [
                    "private func injectTo(foo: inout Foo) {",
                    "    foo.quux = self.quux",
                    "}"
                ]
            ]
        )
    }
}
