//
//  SourcesCommandTests.swift
//  SaberCLITests
//
//  Created by Andrew Pleshkov on 05/11/2018.
//

import XCTest
import Saber
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
        let rawConfig = "accessLevel: public"
        let opts = SourcesCommand
            .Options
            .create(workDir: "")(inputPath)(outDir)(rawConfig)("info")
        XCTAssertEqual(opts.inputDir.path, inputPath)
        XCTAssertEqual(opts.outDir.path, outDir)
        XCTAssertEqual(
            opts.config,
            {
                var config = SaberConfiguration.default
                config.accessLevel = "public"
                return config
            }()
        )
        XCTAssertEqual(opts.logLevel, "info")
    }
    
    func testSrcCommandOptionsWithWorkDir() {
        let workDir = TestPaths.fixturesDir.path
        let inputPath = "Sources"
        let outDir = "Saber"
        let configPath = "config.yml"
        let opts = SourcesCommand
            .Options
            .create(workDir: workDir)(inputPath)(outDir)(configPath)("")
        XCTAssertEqual(opts.inputDir.path, "\(workDir)/\(inputPath)")
        XCTAssertEqual(opts.outDir.path, "\(workDir)/\(outDir)")
        XCTAssertEqual(
            opts.config,
            {
                var config = SaberConfiguration.default
                config.accessLevel = "public"
                return config
            }()
        )
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
