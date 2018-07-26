//
//  ConsoleLogger.swift
//  Saber
//
//  Created by andrey.pleshkov on 23/07/2018.
//

import Foundation

public class ConsoleLogger: Logging {

    let level: LogLevel
    
    public init(level: LogLevel) {
        self.level = level
    }

    public func log(_ level: LogLevel, message: @autoclosure () -> String) {
        if self.level < level {
            return
        }
        fputs("\(message())\n", stdout)
    }
}
