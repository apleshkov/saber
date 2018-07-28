// swift-tools-version:4.0

import PackageDescription

var package = Package(
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
    ],
    targets: [
        .target(
            name: "Saber",
            dependencies: ["SourceKittenFramework"]
        ),
        .target(
            name: "SaberCLI",
            dependencies: ["Saber", "Commandant"]
        ),
        .testTarget(
            name: "SaberTests",
            dependencies: ["Saber"]
        )
    ]
)

#if os(OSX)
package.dependencies.append(
    .package(url: "https://github.com/xcode-project-manager/xcodeproj.git", from: "5.0.0-rc1")
)
package.targets[1].dependencies.append("xcodeproj")
#endif
