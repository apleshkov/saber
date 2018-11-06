//
//  SaberXcodeTests.swift
//  SaberCLITests
//
//  Created by Andrew Pleshkov on 05/11/2018.
//

import XCTest
import Saber
@testable import SaberCLI

class SaberXcodeTests: XCTestCase {

    override func setUp() {
        try! FileManager.default.createDirectory(at: TestPaths.tmpDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    override func tearDown() {
        try! FileManager.default.removeItem(at: TestPaths.tmpDir)
    }
    
    func testXProject() {
        #if os(OSX)
        let proj = try! SaberXProject(path: TestPaths.xprojectFile.path, targetNames: ["SaberTestProject"])
        let targets = proj.targets
        XCTAssertEqual(
            targets.map { $0.name },
            ["SaberTestProject"]
        )
        XCTAssertEqual(
            targets.map { $0.filePaths.count },
            [3]
        )
        #endif
    }
    
    func testXCommandOptions() {
        #if os(OSX)
        let path = "/path/to/Foo/Foo.xcodeproj"
        let outPath = "/path/to/Foo/Saber"
        let rawConfig = "accessLevel: public"
        let logLevel = "info"
        let opts = XcodeProjectCommand
            .Options
            .create(workDir: "")(path)("Foo, Bar")(outPath)(rawConfig)(logLevel)
        XCTAssertEqual(opts.url.path, path)
        XCTAssertEqual(opts.targetNames.sorted(), ["Bar", "Foo"])
        XCTAssertEqual(opts.outDir.path, outPath)
        XCTAssertEqual(
            opts.config,
            {
                var config = SaberConfiguration.default
                config.accessLevel = "public"
                return config
            }()
        )
        XCTAssertEqual(opts.logLevel, logLevel)
        #endif
    }
    
    func testXCommandOptionsWithWorkDir() {
        #if os(OSX)
        let workDir = TestPaths.fixturesDir.path
        let path = "Foo.xcodeproj"
        let outPath = "Saber"
        let configPath = "config.yml"
        let opts = XcodeProjectCommand
            .Options
            .create(workDir: workDir)(path)("Foo")(outPath)(configPath)("")
        XCTAssertEqual(opts.url.path, "\(workDir)/\(path)")
        XCTAssertEqual(opts.targetNames, ["Foo"])
        XCTAssertEqual(opts.outDir.path, "\(workDir)/\(outPath)")
        XCTAssertEqual(
            opts.config,
            {
                var config = SaberConfiguration.default
                config.accessLevel = "public"
                return config
            }()
        )
        XCTAssertEqual(opts.logLevel, "")
        #endif
    }
    
    func testXCommandRun() {
        #if os(OSX)
        let path = TestPaths.xprojectFile.path
        let outPath = TestPaths.tmpDir.path
        let opts = XcodeProjectCommand
            .Options
            .create(workDir: "")(path)("SaberTestProject")(outPath)("")("")
        XCTAssertEqual(opts.config, nil)
        let cmd = XcodeProjectCommand(config: .default)
        _ = cmd.run(opts)
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(outPath)/AppContainer.saber.swift"))
        #endif
    }
}
