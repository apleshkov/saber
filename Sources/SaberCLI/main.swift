//
//  main.swift
//  Saber
//
//  Created by Andrew Pleshkov on 02/07/2018.
//

import Foundation
import Commandant
import Saber

let config = SaberConfiguration.default

let registry = CommandRegistry<Throwable>()
registry.register(XcodeProjectCommand(config: config))
registry.register(SourcesCommand(config: config))
registry.register(VersionCommand())
registry.register(HelpCommand(registry: registry))

registry.main(defaultVerb: "help") { (error) in
    fputs("\(error)\n", stderr)
}
