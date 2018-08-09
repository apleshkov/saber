//
//  SaberConfiguration+Tests.swift
//  SaberTests
//
//  Created by andrey.pleshkov on 09/08/2018.
//

import Foundation
@testable import Saber

extension SaberConfiguration {

    static let test: SaberConfiguration = {
        var config = SaberConfiguration.default
        config.accessLevel = "public"
        config.lazyTypealias = "LazyInjection"
        return config
    }()
}
