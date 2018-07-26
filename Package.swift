// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Saber",
    products: [
        .library(
            name: "Saber",
            targets: ["Saber"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.21.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.14.0"),
        .package(url: "https://github.com/xcode-project-manager/xcodeproj.git", from: "5.0.0-rc1")
    ],
    targets: [
        .target(
            name: "Saber",
            dependencies: ["SourceKittenFramework"]
        ),
        .target(
            name: "SaberCLI",
            dependencies: ["Saber", "Commandant", "xcodeproj"]
        ),
        .testTarget(
            name: "SaberTests",
            dependencies: ["Saber"]
        )
    ]
)
