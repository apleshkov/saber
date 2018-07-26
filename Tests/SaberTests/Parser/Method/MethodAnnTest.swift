//
//  MethodAnnTest.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import XCTest
@testable import Saber

class MethodAnnTest: XCTestCase {
    
    func testInject() {
        XCTAssertEqual(
            MethodAnnotationParser.parse("inject()"),
            nil
        )
        XCTAssertEqual(
            MethodAnnotationParser.parse("inject"),
            MethodAnnotation.inject
        )
    }

    func testProvide() {
        XCTAssertEqual(
            MethodAnnotationParser.parse("provider()"),
            nil
        )
        XCTAssertEqual(
            MethodAnnotationParser.parse("provider"),
            MethodAnnotation.provider
        )
    }

    func testDidInject() {
        XCTAssertEqual(
            MethodAnnotationParser.parse("didInject()"),
            nil
        )
        XCTAssertEqual(
            MethodAnnotationParser.parse("didInject"),
            MethodAnnotation.didInject
        )
    }
}
