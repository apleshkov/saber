//
//  DataFactoryMakerTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 18/05/2018.
//

import XCTest
@testable import Saber

class DataFactoryMakerTests: XCTestCase {

    func testNoInitializer() {
        let decl = TypeDeclaration(name: "Foo").set(initializer: .none)
        let maker = ContainerDataFactory().maker(for: decl)
        XCTAssertEqual(maker, nil)
    }
    
    func testOptionalAndNoArgs() {
        let decl = TypeDeclaration(name: "Foo").set(isOptional: true)
        let maker = ContainerDataFactory().maker(for: decl)
        XCTAssertEqual(
            maker,
            [
                "private func makeFoo() -> Foo? {",
                "    return Foo()",
                "}"
            ]
        )
    }

    func testAllNamedArgs() {
        var decl = TypeDeclaration(name: "Foo")
        decl.initializer = .some(args: [
            FunctionInvocationArgument(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar"))),
            FunctionInvocationArgument(name: "baz", typeResolver: .explicit(TypeUsage(name: "Baz")))
            ])
        let maker = ContainerDataFactory().maker(for: decl)
        XCTAssertEqual(
            maker,
            [
                "private func makeFoo() -> Foo {",
                "    return Foo(bar: self.bar, baz: self.baz)",
                "}"
            ]
        )
    }

    func testNotAllNamedArgs() {
        var decl = TypeDeclaration(name: "Foo")
        decl.initializer = .some(args: [
            FunctionInvocationArgument(name: nil, typeResolver: .explicit(TypeUsage(name: "Bar"))),
            FunctionInvocationArgument(name: "baz", typeResolver: .explicit(TypeUsage(name: "Baz")))
            ])
        let maker = ContainerDataFactory().maker(for: decl)
        XCTAssertEqual(
            maker,
            [
                "private func makeFoo() -> Foo {",
                "    return Foo(self.bar, baz: self.baz)",
                "}"
            ]
        )
    }
}
