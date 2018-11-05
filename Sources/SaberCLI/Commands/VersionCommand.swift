//
//  VersionCommand.swift
//  SaberCLI
//
//  Created by Andrew Pleshkov on 07/07/2018.
//

import Foundation
import Saber
import Commandant
import Result

public struct VersionCommand: CommandProtocol {
    
    public let verb = "version"
    public let function = "Print current version"
    
    public init() {        
    }
    
    public func run(_ options: NoOptions<Throwable>) -> Result<(), Throwable> {
        print(saberVersion)
        return .success(())
    }
}
