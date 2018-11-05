//
//  ConsoleLogger.swift
//  Saber
//
//  Created by andrey.pleshkov on 23/07/2018.
//

import Foundation

public class ConsoleLogger: Logging {

    public var currentLevel: LogLevel?
    
    public func log(_ level: LogLevel, message: @autoclosure () -> String) {
        guard let currentLevel = currentLevel else {
            return
        }
        if currentLevel < level {
            return
        }
        fputs("\(message())\n", stdout)
    }
}
