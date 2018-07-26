//
//  DataFactoryInvokedTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 18/05/2018.
//

import XCTest
@testable import Saber

class DataFactoryInvokedTests: XCTestCase {
    
    func testWithoutArgs() {
        let invoked = ContainerDataFactory().invoked("foo", isOptional: false, with: "bar", args: [])
        XCTAssertEqual(
            invoked,
            "foo.bar()"
        )
    }

    func testAllNamedArgs() {
        let args: [FunctionInvocationArgument] = [
            FunctionInvocationArgument(name: "baz", typeResolver: .explicit(TypeUsage(name: "Baz"))),
            FunctionInvocationArgument(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))
        ]
        let invoked = ContainerDataFactory().invoked("foo", isOptional: false, with: "bar", args: args)
        XCTAssertEqual(
            invoked,
            "foo.bar(baz: self.baz, quux: self.quux)"
        )
    }

    func testNotAllNamedArgs() {
        let args: [FunctionInvocationArgument] = [
            FunctionInvocationArgument(name: nil, typeResolver: .explicit(TypeUsage(name: "Baz"))),
            FunctionInvocationArgument(name: "quux", typeResolver: .explicit(TypeUsage(name: "Quux")))
        ]
        let invoked = ContainerDataFactory().invoked("foo", isOptional: false, with: "bar", args: args)
        XCTAssertEqual(
            invoked,
            "foo.bar(self.baz, quux: self.quux)"
        )
    }
    
    func testProvided() {
        let args: [FunctionInvocationArgument] = [
            FunctionInvocationArgument(
                name: "baz",
                typeResolver: .provided(
                    TypeUsage(name: "Baz"),
                    by: TypeProvider(decl: TypeDeclaration(name: "BazProvider"), methodName: "provide")
                )
            )
        ]
        let invoked = ContainerDataFactory().invoked("foo", isOptional: false, with: "bar", args: args)
        XCTAssertEqual(
            invoked,
            "foo.bar(baz: self.baz)"
        )
    }
    
    func testBound() {
        let args: [FunctionInvocationArgument] = [
            FunctionInvocationArgument(name: "quux", typeResolver: .bound(TypeUsage(name: "QuuxProtocol"), to: TypeUsage(name: "Quux")))
        ]
        let invoked = ContainerDataFactory().invoked("foo", isOptional: false, with: "bar", args: args)
        XCTAssertEqual(
            invoked,
            "foo.bar(quux: self.quuxProtocol)"
        )
    }
}
