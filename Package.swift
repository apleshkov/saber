// swift-tools-version:4.2

import PackageDescription

var package = Package(
    name: "Saber",
    products: [
        .executable(
            name: "saber",
            targets: ["SaberLauncher"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.22.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.15.0"),
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
        .target(
            name: "SaberLauncher",
            dependencies: ["Saber", "SaberCLI", "Commandant"]
        ),
        .testTarget(
            name: "SaberTests",
            dependencies: ["Saber"]
        ),
        .testTarget(
            name: "SaberCLITests",
            dependencies: ["SaberCLI"]
        )
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)

#if os(OSX)
package.dependencies.append(
    .package(url: "https://github.com/xcode-project-manager/xcodeproj.git", from: "6.4.0")
)
package.targets[1].dependencies.append("xcodeproj")
#endif
