//
//  LogLevel.swift
//  Saber
//
//  Created by Andrew Pleshkov on 23/07/2018.
//

import Foundation

public enum LogLevel: Int, Comparable {
    case info
    case debug
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension LogLevel {
    
    public static func make(from rawValue: String) throws -> LogLevel {
        if rawValue == "info" {
            return .info
        }
        if rawValue == "debug" {
            return .debug
        }
        throw Throwable.message("Invalid log level: '\(rawValue)'. Use info or debug")
    }
}
