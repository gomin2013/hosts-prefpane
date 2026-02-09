// swift-tools-version: 5.9
// Swift Package Manager configuration for Hosts Manager
// Note: This allows building/testing individual components
// Full Xcode project is still recommended for the complete macOS app bundle

import PackageDescription

let package = Package(
    name: "HostsManager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Shared library used by all targets
        .library(
            name: "Shared",
            targets: ["Shared"]
        ),
    ],
    targets: [
        // Shared code (models, protocols, utilities)
        .target(
            name: "Shared",
            dependencies: [],
            path: "Shared",
            exclude: []
        ),

        // Tests for validation and parsing
        .testTarget(
            name: "ValidationTests",
            dependencies: ["Shared"],
            path: "Tests/ValidationTests"
        ),

        .testTarget(
            name: "ParserTests",
            dependencies: ["Shared"],
            path: "Tests/ParserTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)



