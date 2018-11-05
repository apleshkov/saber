//
//  SaberXProject.swift
//  Saber
//
//  Created by Andrew Pleshkov on 02/07/2018.
//

#if os(OSX)

import Foundation
import Basic
import xcodeproj

class SaberXProject {
    
    let targets: [Target]
    
    init(path: String, targetNames: Set<String>) throws {
        let absolutePath = AbsolutePath(path).parentDirectory
        var targets: [Target] = []
        let project = try XcodeProj(pathString: path).pbxproj
        let objects = project.objects
        objects.nativeTargets.values
            .filter { targetNames.contains($0.name) }
            .forEach { (nativeTarget) in
                var elements: [PBXFileElement] = []
                let sourcePhases = nativeTarget.buildPhases
                    .compactMap { $0 as? PBXSourcesBuildPhase }
                sourcePhases.forEach {
                    let elems = $0.files.compactMap { $0.file }
                    elements.append(contentsOf: elems)
                }
                let paths: [String] = elements
                    .compactMap { try? $0.fullPath(sourceRoot: absolutePath) }
                    .compactMap { $0 }
                    .filter { $0.extension == "swift" }
                    .compactMap { $0.asString }
                targets.append(
                    Target(name: nativeTarget.name, filePaths: paths)
                )
        }
        self.targets = targets
    }
    
    struct Target {
        
        let name: String

        let filePaths: [String]
    }
}

#endif
