//
//  FileRenderer.swift
//  SaberCLI
//
//  Created by andrey.pleshkov on 03/07/2018.
//

import Foundation
import Saber

class FileRenderer {

    static let fileSuffix = "saber.swift"
    
    let outDir: URL

    let config: SaberConfiguration
    
    let version: String

    init(outDir: URL, config: SaberConfiguration, version: String) {
        self.outDir = outDir
        self.config = config
        self.version = version
    }

    func render(containers: [Container]) throws {
        let dataFactory = ContainerDataFactory(config: config)
        try containers.forEach {
            let data = dataFactory.make(from: $0)
            let renderer = Renderer(data: data, config: config, version: version)
            let generated = renderer.render()
            let containerURL = outDir.appendingPathComponent("\($0.name).\(FileRenderer.fileSuffix)")
            try generated.write(to: containerURL, atomically: false, encoding: .utf8)
            Logger?.info("Rendered: '\(containerURL.path)'")
        }
    }
}

extension FileRenderer {

    struct Params {
        var version: String
        var parsedDataFactory: ParsedDataFactory
        var outDir: URL
        var config: SaberConfiguration
    }

    static func render(params: FileRenderer.Params) throws {
        let containers = try ContainerFactory.make(from: params.parsedDataFactory)
        guard containers.count > 0 else {
            throw Throwable.message("No containers found")
        }
        try FileRenderer(outDir: params.outDir, config: params.config, version: params.version)
            .render(containers: containers)
    }
}
