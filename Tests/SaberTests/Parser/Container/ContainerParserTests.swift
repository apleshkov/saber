//
//  ContainerParserTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 25/05/2018.
//

import XCTest
@testable import Saber
import SourceKittenFramework

class ContainerParserTests: XCTestCase {

    func testSimple() {
        XCTAssertEqual(
            try parse(contents:
                """
                // @saber.container(FooContainer)
                // @saber.scope(FooScope)
                protocol FooContaining {}
                """
            ),
            [
                ParsedContainer(
                    name: "FooContainer",
                    scopeName: "FooScope",
                    protocolName: "FooContaining"
                )
            ]
        )
    }

    func testNoName() {
        XCTAssertThrowsError(
            try parse(contents:
                """
                // @saber.scope(FooScope)
                protocol FooContaining {}
                """
            )
        )
    }

    func testNoScope() {
        XCTAssertThrowsError(
            try parse(contents:
                """
                // @saber.container(FooContainer)
                protocol FooContaining {}
                """
            )
        )
    }

    func testNonProtocol() {
        XCTAssertEqual(
            try parse(contents:
                """
                // @saber.container(FooContainer)
                // non-protocol
                struct FooContaining {}
                """
            ),
            []
        )
    }

    func test() {
        XCTAssertEqual(
            try parse(contents:
                """
                // @saber.container(FooContainer)
                // @saber.scope(FooScope)
                // @saber.dependsOn(BarContainer, BazContainer)
                // @saber.externals(FooExternals1, FooExternals2)
                // @saber.imports(UIKit)
                // @saber.threadSafe
                protocol FooContaining {}
                """
            ),
            [
                ParsedContainer(
                    name: "FooContainer",
                    scopeName: "FooScope",
                    protocolName: "FooContaining",
                    dependencies: [
                        ParsedTypeUsage(name: "BarContainer"),
                        ParsedTypeUsage(name: "BazContainer")
                    ],
                    externals: [
                        ParsedTypeUsage(name: "FooExternals1"),
                        ParsedTypeUsage(name: "FooExternals2")
                    ],
                    isThreadSafe: true,
                    imports: ["UIKit"]
                )
            ]
        )
    }
}

private func parse(contents: String) throws -> [ParsedContainer] {
    let structure = try! Structure(file: File(contents: contents))
    let rawData = RawData(contents: contents)
    return try structure.dictionary.swiftSubstructures!.compactMap {
        return try ContainerParser.parse($0, rawData: rawData)
    }
}
