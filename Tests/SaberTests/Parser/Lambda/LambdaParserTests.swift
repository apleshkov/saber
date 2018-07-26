//
//  LambdaParserTests.swift
//  SaberTests
//
//  Created by Andrew Pleshkov on 20/06/2018.
//

import XCTest
@testable import Saber

class LambdaParserTests: XCTestCase {
    
    func testLambda() {
        XCTAssertEqual(
            LambdaParser.parse("()"),
            nil
        )
        XCTAssertEqual(
            LambdaParser.parse("() -> ()"),
            ParsedLambda(returnType: nil)
        )
        XCTAssertEqual(
            LambdaParser.parse("() -> Foo?"),
            ParsedLambda(returnType: ParsedTypeUsage(name: "Foo", isOptional: true))
        )
        XCTAssertEqual(
            LambdaParser.parse("@escaping () -> Foo"),
            ParsedLambda(returnType: ParsedTypeUsage(name: "Foo"))
        )
        XCTAssertEqual(
            LambdaParser.parse("@autoclosure () -> Foo"),
            ParsedLambda(returnType: ParsedTypeUsage(name: "Foo"))
        )
        XCTAssertEqual(
            LambdaParser.parse("(() -> Foo)!"),
            ParsedLambda(returnType: ParsedTypeUsage(name: "Foo"))
        )
        XCTAssertEqual(
            LambdaParser.parse("(() -> Foo)?"),
            ParsedLambda(returnType: ParsedTypeUsage(name: "Foo"))
        )
    }
}
