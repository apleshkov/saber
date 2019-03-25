//
//  ContainerAnnTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 22/05/2018.
//

import XCTest
@testable import Saber

class ContainerAnnTests: XCTestCase {
    
    func testName() {
        XCTAssertEqual(
            ContainerAnnotationParser.parse("container(Foo)"),
            ContainerAnnotation.name("Foo")
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("container(  Bar )"),
            ContainerAnnotation.name("Bar")
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("container()"),
            nil
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("container( )"),
            nil
        )
    }

    func testScope() {
        XCTAssertEqual(
            ContainerAnnotationParser.parse("scope(Foo)"),
            ContainerAnnotation.scope("Foo")
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("scope(  Bar )"),
            ContainerAnnotation.scope("Bar")
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("scope()"),
            nil
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("scope( )"),
            nil
        )
    }

    func testDependencies() {
        XCTAssertEqual(
            ContainerAnnotationParser.parse("dependsOn()"),
            ContainerAnnotation.dependencies([])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("dependsOn(Foo)"),
            ContainerAnnotation.dependencies([
                ParsedTypeUsage(name: "Foo")
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("dependsOn(Foo, Bar)"),
            ContainerAnnotation.dependencies([
                ParsedTypeUsage(name: "Foo"),
                ParsedTypeUsage(name: "Bar")
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("dependsOn(,Foo,)"),
            ContainerAnnotation.dependencies([
                ParsedTypeUsage(name: "Foo")
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("dependsOn(Foo?, Bar!)"),
            ContainerAnnotation.dependencies([
                ParsedTypeUsage(name: "Foo", isOptional: true),
                ParsedTypeUsage(name: "Bar", isUnwrapped: true)
                ])
        )
    }

    func testExternals() {
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals()"),
            ContainerAnnotation.externals([])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(Foo)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo"), refType: .strong)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(weakFoo)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "weakFoo"), refType: .strong)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(unownedFoo)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "unownedFoo"), refType: .strong)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(weak     Foo)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo"), refType: .weak)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(unowned     Foo)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo"), refType: .unowned)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(Foo, Bar)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo"), refType: .strong),
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Bar"), refType: .strong)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(,Foo,)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo"), refType: .strong)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(Foo?, Bar!)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo", isOptional: true), refType: .strong),
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Bar", isUnwrapped: true), refType: .strong)
                ])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("externals(weak Foo?, unowned Bar!, Quux)"),
            ContainerAnnotation.externals([
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Foo", isOptional: true), refType: .weak),
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Bar", isUnwrapped: true), refType: .unowned),
                ParsedContainerExternal(type: ParsedTypeUsage(name: "Quux"), refType: .strong)
                ])
        )
    }
    
    func testImports() {
        XCTAssertEqual(
            ContainerAnnotationParser.parse("imports()"),
            ContainerAnnotation.imports([])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("imports(Foo)"),
            ContainerAnnotation.imports(["Foo"])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("imports(Foo, Bar)"),
            ContainerAnnotation.imports(["Foo", "Bar"])
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("imports(,Foo,)"),
            ContainerAnnotation.imports(["Foo"])
        )
    }
    
    func testThreadSafe() {
        XCTAssertEqual(
            ContainerAnnotationParser.parse("threadSafe()"),
            nil
        )
        XCTAssertEqual(
            ContainerAnnotationParser.parse("threadSafe"),
            ContainerAnnotation.threadSafe
        )
    }
}
