//
//  ConfigDecoder.swift
//  SaberCLI
//
//  Created by andrey.pleshkov on 05/07/2018.
//

import Foundation
import Yams
import Saber

class ConfigDecoder {

    private let raw: String

    private let decoder: YAMLDecoder

    init(raw: String) {
        self.raw = raw
        self.decoder = YAMLDecoder()
    }

    func decode<T>(baseURL: URL?) throws -> T where T: Decodable {
        let contents: String
        if raw.hasSuffix(".yml") {
            let url = URL(fileURLWithPath: raw).saber_relative(to: baseURL)
            contents = try String(contentsOf: url, encoding: .utf8)
        } else {
            contents = raw
        }
        return try decoder.decode(T.self, from: contents)
    }
}
