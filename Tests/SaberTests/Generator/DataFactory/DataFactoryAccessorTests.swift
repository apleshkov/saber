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
    
    func testExternalProperty() {
        let resolver = TypeResolver.external(
            from: TypeUsage(name: "SomeExternal"),
            kind: .property(name: "foo")
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.someExternal.foo"
        )
    }
    
    func testExternalFunction() {
        let bazResolver = TypeResolver.external(
            from: TypeUsage(name: "SomeExternal"),
            kind: .property(name: "baz")
        )
        let quuxResolver = TypeResolver.derived(
            from: TypeUsage(name: "ContainerB"),
            typeResolver: .derived(
                from: TypeUsage(name: "ContainerA"),
                typeResolver: .explicit(TypeUsage(name: "Quux"))
            )
        )
        let resolver = TypeResolver.external(
            from: TypeUsage(name: "SomeExternal"),
            kind: .method(
                name: "foo",
                args: [
                    FunctionInvocationArgument(
                        name: "bar",
                        typeResolver: .explicit(TypeUsage(name: "Bar"))
                    ),
                    FunctionInvocationArgument(
                        name: "baz",
                        typeResolver: bazResolver
                    ),
                    FunctionInvocationArgument(
                        name: "quux",
                        typeResolver: quuxResolver
                    )
                ])
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "self"),
            "self.someExternal.foo(bar: self.bar, baz: self.someExternal.baz, quux: self.containerB.containerA.quux)"
        )
    }
    
    func testLazy() {
        let resolver = TypeResolver<TypeUsage>.derived(
            from: TypeUsage(name: "Parent"),
            typeResolver: .external(
                from: TypeUsage(name: "ParentExternal"),
                kind: .property(name: "bar")
            )
        )
        XCTAssertEqual(
            ContainerDataFactory().accessor(of: resolver, owner: "this", isLazy: true),
            "{ [unowned this] in return this.parent.parentExternal.bar }"
        )
    }
}
