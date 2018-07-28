//
//  DirectoryTraverser.swift
//  SaberCLI
//
//  Created by andrey.pleshkov on 04/07/2018.
//

import Foundation
import Saber

private let fm = FileManager.default

enum DirectoryTraverser {

    static func traverse(_ path: String, fn: (_ path: String) throws -> ()) throws {
        var isDirectoryObjC: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDirectoryObjC) else {
            Logger?.debug("Ignoring \(path): not exist")
            return
        }
        let isDirectory = isDirectoryObjC.boolValue
        if !isDirectory {
            try fn(path)
            return
        }
        guard isDirectory else {
            Logger?.debug("Ignoring \(path): not a directory")
            return
        }
        Logger?.info("Traversing \(path)...")
        let directoryContents = try fm.contentsOfDirectory(atPath: path)
        for entry in directoryContents {
            let p = URL(fileURLWithPath: path).appendingPathComponent(entry).path
            try traverse(p, fn: fn)
        }
    }
}
