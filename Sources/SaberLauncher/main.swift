//
//  main.swift
//  Saber
//
//  Created by Andrew Pleshkov on 02/07/2018.
//

import Foundation
import Commandant
import Saber
import SaberCLI

let config = SaberConfiguration.default

let registry = CommandRegistry<Throwable>()
#if os(OSX)
registry.register(XcodeProjectCommand(config: config))
#endif
registry.register(SourcesCommand(config: config))
registry.register(VersionCommand())
registry.register(HelpCommand(registry: registry))

registry.main(defaultVerb: "help") { (error) in
    fputs("\(error)\n", stderr)
}
