//
//  DataFactoryAccessorTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 17/05/2018.
//

import XCTest
@testable import Saber

class DataFactoryAccessorTests: XCTestCase {
    
    func testType() {
        let resolver = TypeResolver.explicit(TypeUsage(name: "FooBarQuux"))
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.fooBarQuux"
        )
    }
    
    func testContainer() {
        let resolver = TypeResolver<TypeUsage>.container
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self"
        )
    }
    
    func testDerivedContainer() {
        let resolver = TypeResolver.derived(
            from: TypeUsage(name: "containerA"),
            typeResolver: .derived(
                from: TypeUsage(name: "containerB"),
                typeResolver: .container
            )
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.containerA.containerB"
        )
    }

    func testExplicit() {
        let resolver = TypeResolver.explicit(TypeUsage(name: "FooBarQuux"))
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.fooBarQuux"
        )
    }

    func testProvidedByType() {
        let provider = TypeProvider(decl: TypeDeclaration(name: "FooProvider"), methodName: "provide")
        let resolver = TypeResolver<TypeUsage>.provided(TypeUsage(name: "Foo"), by: provider)
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.foo"
        )
    }

    func testBound() {
        let resolver = TypeResolver.bound(TypeUsage(name: "FooProtocol"), to: TypeUsage(name: "Foo"))
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.fooProtocol"
        )
    }
    
    func testDependency() {
        let resolver = TypeResolver.derived(
            from: TypeUsage(name: "containerA"),
            typeResolver: .explicit(TypeUsage(name: "Foo"))
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.containerA.foo"
        )
    }
    
    func testMultipleInheritance() {
        let resolver = TypeResolver.derived(
            from: TypeUsage(name: "ContainerB"),
            typeResolver: .derived(
                from: TypeUsage(name: "ContainerA"),
                typeResolver: .explicit(TypeUsage(name: "Foo"))
            )
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.containerB.containerA.foo"
        )
    }
    
    func testExternal() {
        let resolver = TypeResolver<TypeUsage>.external(
            TypeUsage(name: "SomeExternal")
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.someExternal"
        )
    }
    
    func testLazy() {
        let resolver = TypeResolver<TypeUsage>.derived(
            from: TypeUsage(name: "Parent"),
            typeResolver: .external(
                TypeUsage(name: "ParentExternal")
            )
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "this", isLazy: true),
            "{ [unowned this] in return this.parent.parentExternal }"
        )
    }
}
