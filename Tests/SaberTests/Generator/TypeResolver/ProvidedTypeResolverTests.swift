//
//  ProvidedTypeResolverTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 11/05/2018.
//

import XCTest
@testable import Saber

class ProvidedTypeResolverTests: XCTestCase {

    func testTypedProvider() {
        var decl = TypeDeclaration(name: "FooBar")
        decl.memberInjections = [MemberInjection(name: "baz", typeResolver: .explicit(TypeUsage(name: "Baz")))]
        let resolver = TypeResolver<TypeDeclaration>.provided(
            TypeUsage(name: decl.name),
            by: TypeProvider(
                decl: TypeDeclaration(name: "CoolProvider"),
                methodName: "provide"
            )
        )
        let service = Service(typeResolver: resolver, storage: .none)
        let container = Container(name: "Test")
            .add(service: service)
            .add(
                service: Service(
                    typeResolver: .explicit(TypeDeclaration(name: "CoolProvider")),
                    storage: .none
                )
        )
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
                ],
                [
                    "public var coolProvider: CoolProvider {",
                    "    let coolProvider = self.makeCoolProvider()",
                    "    return coolProvider",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeFooBar() -> FooBar {",
                    "    let provider = self.coolProvider",
                    "    return provider.provide()",
                    "}"
                ],
                [
                    "private func makeCoolProvider() -> CoolProvider {",
                    "    return CoolProvider()",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.injectors,
            []
        )
    }
    
    func testCachedTypedProvider() {
        let decl = TypeDeclaration(name: "FooBar")
        let providerDecl = TypeDeclaration(name: "CoolProvider")
            .set(
                initializer: .some(
                    args: [
                        FunctionInvocationArgument(
                            name: "quux",
                            typeResolver: .explicit(TypeUsage(name: "Quux"))
                        )
                    ]
                )
        )
        let resolver = TypeResolver<TypeDeclaration>.provided(
            TypeUsage(name: decl.name),
            by: TypeProvider(
                decl: providerDecl,
                methodName: "provide"
            )
        )
        let service = Service(typeResolver: resolver, storage: .cached)
        let container = Container(name: "Test")
            .add(service: service)
            .add(
                service: Service(
                    typeResolver: .explicit(providerDecl),
                    storage: .cached
                )
        )
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            [
                ["private var cached_coolProvider: CoolProvider?"]
            ]
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var fooBar: FooBar {",
                    "    let fooBar = self.makeFooBar()",
                    "    return fooBar",
                    "}"
                ],
                [
                    "public var coolProvider: CoolProvider {",
                    "    if let cached = self.cached_coolProvider { return cached }",
                    "    let coolProvider = self.makeCoolProvider()",
                    "    self.cached_coolProvider = coolProvider",
                    "    return coolProvider",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeFooBar() -> FooBar {",
                    "    let provider = self.coolProvider",
                    "    return provider.provide()",
                    "}"
                ],
                [
                    "private func makeCoolProvider() -> CoolProvider {",
                    "    return CoolProvider(quux: self.quux)",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.injectors,
            []
        )
    }
}
