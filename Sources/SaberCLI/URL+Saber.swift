//
//  URL+Saber.swift
//  SaberCLI
//
//  Created by andrey.pleshkov on 06/07/2018.
//

import Foundation

extension URL {

    func saber_relative(to baseURL: URL?) -> URL {
        guard let baseURL = baseURL else {
            return self
        }
        return baseURL.appendingPathComponent(self.relativePath)
    }
}
