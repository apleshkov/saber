//
//  ContainerParser.swift
//  Saber
//
//  Created by andrey.pleshkov on 25/05/2018.
//

import Foundation
import SourceKittenFramework

class ContainerParser {

    static func parse(_ structure: [String : SourceKitRepresentable], rawData: RawData) throws -> ParsedContainer? {
        let annotations = rawData
            .annotations(for: structure)
            .compactMap { return ContainerAnnotationParser.parse($0) }
        guard structure.swiftDeclKind == .protocol, let protocolName = structure.swiftName else {
            return nil
        }
        guard annotations.count > 0 else {
            return nil
        }
        var foundName: String? = nil
        var foundScopeName: String? = nil
        var foundDependencies: [ParsedTypeUsage] = []
        var foundExternals: [ParsedContainerExternal] = []
        var foundImports: [String] = []
        var isThreadSafe = false
        annotations.forEach {
            switch $0 {
            case .name(let name):
                foundName = name
            case .scope(let scopeName):
                foundScopeName = scopeName
            case .dependencies(let dependencies):
                foundDependencies.append(contentsOf: dependencies)
            case .externals(let externals):
                foundExternals.append(contentsOf: externals)
            case .imports(let imports):
                foundImports.append(contentsOf: imports)
            case .threadSafe:
                isThreadSafe = true
            }
        }
        guard let name = foundName else {
            throw Throwable.message("Invalid '\(protocolName)' container annotations: 'name' not found")
        }
        guard let scopeName = foundScopeName else {
            throw Throwable.message("Invalid '\(protocolName)' container annotations: 'scopeName' not found")
        }
        var container = ParsedContainer(name: name, scopeName: scopeName, protocolName: protocolName)
        container.dependencies = foundDependencies
        container.externals = foundExternals
        container.isThreadSafe = isThreadSafe
        container.imports = foundImports
        return container
    }
}
