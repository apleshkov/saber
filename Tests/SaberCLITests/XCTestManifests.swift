import XCTest

extension SaberConfigurationTests {
    static let __allTests = [
        ("testRootElements", testRootElements),
        ("testSpaceIdentation", testSpaceIdentation),
        ("testTabIdentation", testTabIdentation),
    ]
}

extension SaberXcodeTests {
    static let __allTests = [
        ("testXCommandOptions", testXCommandOptions),
        ("testXCommandOptionsWithWorkDir", testXCommandOptionsWithWorkDir),
        ("testXCommandRun", testXCommandRun),
        ("testXProject", testXProject),
    ]
}

extension SourcesCommandTests {
    static let __allTests = [
        ("testSrcCommandOptions", testSrcCommandOptions),
        ("testSrcCommandOptionsWithWorkDir", testSrcCommandOptionsWithWorkDir),
        ("testSrcCommandRun", testSrcCommandRun),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SaberConfigurationTests.__allTests),
        testCase(SaberXcodeTests.__allTests),
        testCase(SourcesCommandTests.__allTests),
    ]
}
#endif
