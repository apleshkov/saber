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

struct VersionCommand: CommandProtocol {
    
    let verb = "version"
    let function = "Print current version"
    
    func run(_ options: NoOptions<Throwable>) -> Result<(), Throwable> {
        print(saberVersion)
        return .success(())
    }
}
