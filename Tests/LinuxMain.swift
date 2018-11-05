import XCTest

import SaberTests
import SaberCLITests

var tests = [XCTestCaseEntry]()
tests += SaberTests.__allTests()
tests += SaberCLITests.__allTests()

XCTMain(tests)
