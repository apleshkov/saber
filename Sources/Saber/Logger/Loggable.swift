//
//  Loggable.swift
//  Saber
//
//  Created by Andrew Pleshkov on 23/07/2018.
//

import Foundation

public protocol Loggable {
    
    func log(with logger: Logging, level: LogLevel)
}
