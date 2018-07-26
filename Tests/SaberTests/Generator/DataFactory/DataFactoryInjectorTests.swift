//
//  DataFactoryCreationTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 17/05/2018.
//

import XCTest
@testable import Saber

class DataFactoryInjectorTests: XCTestCase {
    
    func testNoInjections() {
        let decl = TypeDeclaration(name: "Foo")
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(injector, nil)
    }
    
    func testValueInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.bar = self.bar",
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
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.bar = self.bar",
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
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: Foo) {",
                "    foo.bar = self.bar",
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
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: Foo) {",
                "    foo.bar = self.bar",
                "}"
            ]
        )
    }

    func testMethodInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.methodInjections = [
            InstanceMethodInjection(methodName: "set", args: [
                FunctionInvocationArgument(name: "baz", typeResolver: .explicit(TypeUsage(name: "Baz")))
                ]),
            InstanceMethodInjection(methodName: "set", args: [
                FunctionInvocationArgument(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))
                ])
        ]
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.set(baz: self.baz)",
                "    foo.set(quux: self.quux)",
                "}"
            ]
        )
    }
    
    func testMemberAndMethodInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        decl.methodInjections = [
            InstanceMethodInjection(methodName: "set", args: [
                FunctionInvocationArgument(name: nil, typeResolver: .explicit(TypeUsage(name: "Baz"))),
                FunctionInvocationArgument(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))
                ])
        ]
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.bar = self.bar",
                "    foo.set(self.baz, quux: self.quux)",
                "}"
            ]
        )
    }

    func testDidInjectHandler() {
        var decl = TypeDeclaration(name: "Foo")
        decl.didInjectHandlerName = "postInit"
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")))
        ]
        decl.methodInjections = [
            InstanceMethodInjection(methodName: "set", args: [
                FunctionInvocationArgument(name: nil, typeResolver: .explicit(TypeUsage(name: "Baz"))),
                FunctionInvocationArgument(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))
                ])
        ]
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.bar = self.bar",
                "    foo.set(self.baz, quux: self.quux)",
                "    foo.postInit()",
                "}"
            ]
        )
    }

    func testLazyInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.memberInjections = [
            MemberInjection(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")), isLazy: true)
        ]
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.bar = { [unowned self] in return self.bar }",
                "}"
            ]
        )
    }

    func testLazyMethodInjections() {
        var decl = TypeDeclaration(name: "Foo")
        decl.methodInjections = [
            InstanceMethodInjection(methodName: "set", args: [
                FunctionInvocationArgument(name: "bar", typeResolver: .explicit(TypeUsage(name: "Bar")), isLazy: true)
                ])
        ]
        let injector = ContainerDataFactory().injector(for: decl, accessLevel: "open")
        XCTAssertEqual(
            injector,
            [
                "open func injectTo(foo: inout Foo) {",
                "    foo.set(bar: { [unowned self] in return self.bar })",
                "}"
            ]
        )
    }
}
