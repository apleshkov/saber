//
//  TestPaths.swift
//  SaberCLITests
//
//  Created by Andrew Pleshkov on 05/11/2018.
//

import Foundation

struct TestPaths {
    
    static var rootDir: URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
    
    static var fixturesDir: URL {
        return rootDir.appendingPathComponent("Fixtures")
    }
    
    static var tmpDir: URL {
        return rootDir.appendingPathComponent("Temp")
    }
    
    static var xprojectDir: URL {
        return TestPaths
            .fixturesDir
            .appendingPathComponent("SaberTestProject")
    }
    
    static var xprojectFile: URL {
        return xprojectDir
            .appendingPathComponent("SaberTestProject.xcodeproj")
    }
    
    static var configFile: URL {
        return fixturesDir
            .appendingPathComponent("config.yml")
    }
}
