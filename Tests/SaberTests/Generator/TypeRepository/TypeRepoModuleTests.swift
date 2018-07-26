//
//  TypeRepoModuleTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 09/06/2018.
//

import XCTest
@testable import Saber

class TypeRepoModuleTests: XCTestCase {
    
    func testType() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.scope(Singleton)
                struct Foo {}
                """, moduleName: "A"
                ).parse(to: factory)
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}
                """, moduleName: "B"
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertEqual(
            try? repo.find(by: .modular(module: "A", name: "Foo")).key,
            .modular(module: "A", name: "Foo")
        )
        XCTAssertEqual(
            try? repo.find(by: .name("Foo")).key,
            .modular(module: "A", name: "Foo")
        )
        XCTAssertEqual(
            repo.find(by: "Foo")?.key,
            .modular(module: "A", name: "Foo")
        )
        XCTAssertEqual(
            repo.find(by: "A.Foo")?.key,
            .modular(module: "A", name: "Foo")
        )
        XCTAssertEqual(
            try? repo.find(by: .name("Bar")).key,
            nil
        )
    }

    func testTypeCollisions() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                // @saber.scope(Singleton)
                struct Foo {}
                """, moduleName: "A"
                ).parse(to: factory)
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                protocol AppConfig {}

                // @saber.scope(Singleton)
                struct Foo {}
                """, moduleName: "B"
                ).parse(to: factory)
            return factory.make()
        }()
        let repo = try! TypeRepository(parsedData: parsedData)
        XCTAssertThrowsError(try repo.find(by: .name("Foo")).key, ".name()", {
            XCTAssertEqual(
                $0.localizedDescription,
                Throwable.declCollision(name: "Foo", modules: ["A", "B"]).localizedDescription
            )
        })
        XCTAssertEqual(
            repo.find(by: "Foo")?.key,
            nil
        )
        XCTAssertEqual(
            repo.find(by: "A.Foo")?.key,
            .modular(module: "A", name: "Foo")
        )
        XCTAssertEqual(
            try! repo.find(by: .modular(module: "B", name: "Foo")).key,
            .modular(module: "B", name: "Foo")
        )
    }
    
    func testExternals1() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                struct SomeExternal {}
                """, moduleName: "A"
                ).parse(to: factory)
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                // @saber.externals(SomeExternal)
                protocol AppConfig {}

                // @saber.container(User)
                // @saber.scope(UserScope)
                // @saber.externals(A.SomeExternal)
                protocol UserConfig {}
                """, moduleName: "B"
                ).parse(to: factory)
            return factory.make()
        }()
        XCTAssertNoThrow(try TypeRepository(parsedData: parsedData))
    }
    
    func testExternalsCollision() {
        let parsedData: ParsedData = {
            let factory = ParsedDataFactory()
            try! FileParser(contents:
                """
                struct SomeExternal {}
                """, moduleName: "A"
                ).parse(to: factory)
            try! FileParser(contents:
                """
                // @saber.container(App)
                // @saber.scope(Singleton)
                // @saber.externals(SomeExternal)
                protocol AppConfig {}

                struct SomeExternal {}
                """, moduleName: "B"
                ).parse(to: factory)
            return factory.make()
        }()
        XCTAssertThrowsError(try TypeRepository(parsedData: parsedData))
    }
}
