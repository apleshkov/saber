//
//  DirectoryTraverser.swift
//  SaberCLI
//
//  Created by andrey.pleshkov on 04/07/2018.
//

import Foundation
import Basic
import Saber

private let fs = localFileSystem

enum DirectoryTraverser {

    static func traverse(_ pathString: String, fn: (_ path: AbsolutePath) throws -> ()) throws {
        try traverse(AbsolutePath(pathString), fn: fn)
    }

    static func traverse(_ path: AbsolutePath, fn: (_ path: AbsolutePath) throws -> ()) throws {
        if fs.isFile(path) {
            try fn(path)
            return
        }
        guard fs.isDirectory(path) else {
            Logger?.debug("Ignoring \(path.asString): not a directory")
            return
        }
        Logger?.info("Traversing \(path.asString)...")
        try fs.getDirectoryContents(path).forEach {
            let entry = path.appending(component: $0)
            try traverse(entry, fn: fn)
        }
    }
}
