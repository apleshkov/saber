//
//  DataFactoryMemberNameTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 19/05/2018.
//

import XCTest
@testable import Saber

class DataFactoryMemberNameTests: XCTestCase {
    
    func testSimple() {
        XCTAssertEqual(
            ContainerDataFactory().memberName(of: TypeUsage(name: "Foo")),
            "foo"
        )
    }
    
    func testCamelCase() {
        XCTAssertEqual(
            ContainerDataFactory().memberName(of: TypeUsage(name: "FooBarQuux")),
            "fooBarQuux"
        )
    }
    
    func testNested() {
        XCTAssertEqual(
            ContainerDataFactory().memberName(of: TypeUsage(name: "Foo.Bar.Quux")),
            "fooBarQuux"
        )
    }
    
    func testGeneric() {
        var type = TypeUsage(name: "Array")
        type.generics.append(TypeUsage(name: "Int"))
        XCTAssertEqual(
            ContainerDataFactory().memberName(of: type),
            "array_Int"
        )
    }
    
    func testOptionalGeneric() {
        var type = TypeUsage(name: "Array")
        type.generics.append(TypeUsage(name: "Int").set(isOptional: true))
        XCTAssertEqual(
            ContainerDataFactory().memberName(of: type),
            "array_OptionalInt"
        )
    }
    
    func testTwoGenerics() {
        var type = TypeUsage(name: "Dictionary")
        type.generics.append(TypeUsage(name: "String"))
        type.generics.append(TypeUsage(name: "Foo.Bar").set(isOptional: true))
        XCTAssertEqual(
            ContainerDataFactory().memberName(of: type),
            "dictionary_String_OptionalFooBar"
        )
    }
}
