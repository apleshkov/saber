//
//  DataFactoryGetterTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 18/05/2018.
//

import XCTest
@testable import Saber

class DataFactoryGetterTests: XCTestCase {
    
    func testValueWithoutMemberInjections() {
        let decl = TypeDeclaration(name: "Foo")
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    let foo = self.makeFoo()",
                "    return foo",
                "}"
            ]
        )
    }

    func testReferenceWithoutMemberInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.isReference = true
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    let foo = self.makeFoo()",
                "    return foo",
                "}"
            ]
        )
    }

    func testValueInjections1() {
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    var foo = self.makeFoo()",
                "    self.injectTo(foo: &foo)",
                "    return foo",
                "}"
            ]
        )
    }
    
    func testValueInjections2() {
        var decl = TypeDeclaration(name: "Foo")
        decl.methodInjections = [
            InstanceMethodInjection(
                methodName: "set",
                args: [
                    FunctionInvocationArgument(name: nil, typeResolver: .explicit(TypeUsage(name: "Bar")))
                ]
            )
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    var foo = self.makeFoo()",
                "    self.injectTo(foo: &foo)",
                "    return foo",
                "}"
            ]
        )
    }

    func testReferenceInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.isReference = true
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    let foo = self.makeFoo()",
                "    self.injectTo(foo: foo)",
                "    return foo",
                "}"
            ]
        )
    }

    func testOptionalValueInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.isOptional = true
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo? {",
                "    var foo = self.makeFoo()",
                "    if var foo = foo { self.injectTo(foo: &foo) }",
                "    return foo",
                "}"
            ]
        )
    }

    func testOptionalReferenceInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.isReference = true
        decl.isOptional = true
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open")
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo? {",
                "    let foo = self.makeFoo()",
                "    if let foo = foo { self.injectTo(foo: foo) }",
                "    return foo",
                "}"
            ]
        )
    }

    func testCachedValueInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open", cached: ("cachedFoo", false))
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    if let cached = self.cachedFoo { return cached }",
                "    var foo = self.makeFoo()",
                "    self.injectTo(foo: &foo)",
                "    self.cachedFoo = foo",
                "    return foo",
                "}"
            ]
        )
    }

    func testCachedReferenceInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.isReference = true
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open", cached: ("cachedFoo", false))
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    if let cached = self.cachedFoo { return cached }",
                "    let foo = self.makeFoo()",
                "    self.injectTo(foo: foo)",
                "    self.cachedFoo = foo",
                "    return foo",
                "}"
            ]
        )
    }

    func testThreadSafeCachedValueInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open", cached: ("cachedFoo", true))
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    self.lock.lock()",
                "    defer { self.lock.unlock() }",
                "    if let cached = self.cachedFoo { return cached }",
                "    var foo = self.makeFoo()",
                "    self.injectTo(foo: &foo)",
                "    self.cachedFoo = foo",
                "    return foo",
                "}"
            ]
        )
    }

    func testThreadSafeCachedReferenceInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.isReference = true
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let getter = ContainerDataFactory().getter(of: decl, accessLevel: "open", cached: ("cachedFoo", true))
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    self.lock.lock()",
                "    defer { self.lock.unlock() }",
                "    if let cached = self.cachedFoo { return cached }",
                "    let foo = self.makeFoo()",
                "    self.injectTo(foo: foo)",
                "    self.cachedFoo = foo",
                "    return foo",
                "}"
            ]
        )
    }
    
    func testCachedOptionalTypeUsage() {
        let usage = TypeUsage(name: "Foo").set(isOptional: true)
        let getter = ContainerDataFactory().getter(of: usage, accessLevel: "open", cached: ("cachedFoo", false))
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo? {",
                "    if let cached = self.cachedFoo { return cached }",
                "    let foo = self.makeFoo()",
                "    self.cachedFoo = foo",
                "    return foo",
                "}"
            ]
        )
    }
    
    func testThreadSafeCachedTypeUsage() {
        let usage = TypeUsage(name: "Foo")
        let getter = ContainerDataFactory().getter(of: usage, accessLevel: "open", cached: ("cachedFoo", true))
        XCTAssertEqual(
            getter,
            [
                "open var foo: Foo {",
                "    self.lock.lock()",
                "    defer { self.lock.unlock() }",
                "    if let cached = self.cachedFoo { return cached }",
                "    let foo = self.makeFoo()",
                "    self.cachedFoo = foo",
                "    return foo",
                "}"
            ]
        )
    }
}
