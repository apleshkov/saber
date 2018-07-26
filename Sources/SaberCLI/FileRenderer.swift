//
//  FileRenderer.swift
//  SaberCLI
//
//  Created by andrey.pleshkov on 03/07/2018.
//

import Foundation
import Basic
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
        var rawConfig: String
        var defaultConfig: SaberConfiguration
    }

    static func render(params: FileRenderer.Params) throws {
        let containers = try ContainerFactory.make(from: params.parsedDataFactory)
        guard containers.count > 0 else {
            throw Throwable.message("No containers found")
        }
        let config: SaberConfiguration
        if params.rawConfig.count > 0 {
            config = try ConfigDecoder(raw: params.rawConfig).decode()
        } else {
            config = params.defaultConfig
        }
        try FileRenderer(outDir: params.outDir, config: config, version: params.version)
            .render(containers: containers)
    }
}
