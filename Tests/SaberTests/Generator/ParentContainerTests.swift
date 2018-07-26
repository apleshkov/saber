//
//  ParentContainerTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 11/05/2018.
//  Copyright © 2018 test. All rights reserved.
//

import XCTest
@testable import Saber

class ParentContainerTests: XCTestCase {

    func testParentContainerDependencies() {
        var parentContainer = Container(name: "ParentContainer")
        parentContainer.services.append(
            {
                return Service(typeResolver: .explicit(TypeDeclaration(name: "Foo")), storage: .none)
            }()
        )
        let parentType = TypeUsage(name: parentContainer.name)
        var container = Container(name: "TestContainer").add(dependency: parentType)
        container.services.append(
            {
                var decl = TypeDeclaration(name: "Bar")
                decl.initializer = .some(args: [
                    FunctionInvocationArgument(
                        name: "foo",
                        typeResolver: .derived(from: parentType, typeResolver: .explicit(TypeUsage(name: "Foo")))
                    )
                    ])
                return Service(typeResolver: .explicit(decl), storage: .none)
            }()
        )
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.initializer.args.map { "\($0.name): \($0.typeName)" },
            ["parentContainer: ParentContainer"]
        )
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public unowned let parentContainer: ParentContainer"]
            ]
        )
        XCTAssertEqual(
            data.initializer.creations,
            []
        )
        XCTAssertEqual(
            data.initializer.storedProperties,
            [
                "self.parentContainer = parentContainer"
            ]
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var bar: Bar {",
                    "    let bar = self.makeBar()",
                    "    return bar",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeBar() -> Bar {",
                    "    return Bar(foo: self.parentContainer.foo)",
                    "}"
                ]
            ]
        )
    }

    func testMultipleChildContainers() {
        let aDependency = TypeUsage(name: "ContainerA")
        let bDependency = TypeUsage(name: "ContainerB")
        let container: Container = {
            var container = Container(name: "ContainerC")
                .add(dependency: aDependency)
                .add(dependency: bDependency)
            container.services.append(
                {
                    var decl = TypeDeclaration(name: "Baz")
                    decl.memberInjections = [
                        MemberInjection(
                            name: "foo",
                            typeResolver: .derived(
                                from: aDependency,
                                typeResolver: .explicit(TypeUsage(name: "Foo"))
                            )
                        ),
                        MemberInjection(
                            name: "bar",
                            typeResolver: .derived(
                                from: bDependency,
                                typeResolver: .explicit(TypeUsage(name: "Bar"))
                            )
                        ),
                        MemberInjection(
                            name: "quux",
                            typeResolver: .derived(
                                from: bDependency,
                                typeResolver: .derived(
                                    from: aDependency,
                                    typeResolver: .explicit(TypeUsage(name: "Quux"))
                                )
                            )
                        )
                    ]
                    return Service(typeResolver: .explicit(decl), storage: .none)
                }()
            )
            return container
        }()
        let data = ContainerDataFactory().make(from: container)
        XCTAssertEqual(
            data.storedProperties,
            [
                ["public unowned let containerA: ContainerA"],
                ["public unowned let containerB: ContainerB"]
            ]
        )
        XCTAssertEqual(
            data.getters,
            [
                [
                    "public var baz: Baz {",
                    "    var baz = self.makeBaz()",
                    "    self.injectTo(baz: &baz)",
                    "    return baz",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.makers,
            [
                [
                    "private func makeBaz() -> Baz {",
                    "    return Baz()",
                    "}"
                ]
            ]
        )
        XCTAssertEqual(
            data.injectors,
            [
                [
                    "private func injectTo(baz: inout Baz) {",
                    "    baz.foo = self.containerA.foo",
                    "    baz.bar = self.containerB.bar",
                    "    baz.quux = self.containerB.containerA.quux",
                    "}"
                ]
            ]
        )
    }
}
