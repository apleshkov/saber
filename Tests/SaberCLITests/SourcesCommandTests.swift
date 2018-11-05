//
//  SourcesCommandTests.swift
//  SaberCLITests
//
//  Created by Andrew Pleshkov on 05/11/2018.
//

import XCTest
@testable import SaberCLI

class SourcesCommandTests: XCTestCase {

    override func setUp() {
        try! FileManager.default.createDirectory(at: TestPaths.tmpDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: TestPaths.tmpDir)
    }
    
    func testSrcCommandOptions() {
        let inputPath = "/path/to/Foo/Sources"
        let outDir = "/path/to/Foo/Saber"
        let opts = SourcesCommand
            .Options
            .create(workDir: "")(inputPath)(outDir)("")("")
        XCTAssertEqual(opts.inputDir.path, inputPath)
        XCTAssertEqual(opts.outDir.path, outDir)
        XCTAssertEqual(opts.config, nil)
        XCTAssertEqual(opts.logLevel, "")
    }
    
    func testSrcCommandOptionsWithWorkDir() {
        let workDir = "/path/to/Foo"
        let inputPath = "Sources"
        let outDir = "Saber"
        let opts = SourcesCommand
            .Options
            .create(workDir: workDir)(inputPath)(outDir)("")("")
        XCTAssertEqual(opts.inputDir.path, "\(workDir)/\(inputPath)")
        XCTAssertEqual(opts.outDir.path, "\(workDir)/\(outDir)")
        XCTAssertEqual(opts.config, nil)
        XCTAssertEqual(opts.logLevel, "")
    }
    
    func testSrcCommandRun() {
        let inputPath = TestPaths.xprojectDir.path
        let outDir = TestPaths.tmpDir.path
        let opts = SourcesCommand
            .Options
            .create(workDir: "")(inputPath)(outDir)("")("")
        XCTAssertEqual(opts.inputDir.path, inputPath)
        XCTAssertEqual(opts.outDir.path, outDir)
        XCTAssertEqual(opts.config, nil)
        XCTAssertEqual(opts.logLevel, "")
        let cmd = SourcesCommand(config: .default)
        _ = cmd.run(opts)
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(outDir)/AppContainer.saber.swift"))
    }
}
