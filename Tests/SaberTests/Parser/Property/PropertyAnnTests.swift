//
//  PropertyAnnTests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 28/05/2018.
//

import XCTest
@testable import Saber

class PropertyAnnTests: XCTestCase {
    
    func testInject() {
        XCTAssertEqual(
            PropertyAnnotationParser.parse("inject()"),
            nil
        )
        XCTAssertEqual(
            PropertyAnnotationParser.parse("inject"),
            PropertyAnnotation.inject
        )
    }
}
