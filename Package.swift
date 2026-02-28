// swift-tools-version: 6.0
// Swift Package Manager configuration for Hosts Manager
// Note: This allows building/testing individual components
// Full Xcode project is still recommended for the complete macOS app bundle

import PackageDescription

let package = Package(
    name: "HostsManager",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "HostsManagerExtension",
            targets: ["HostsManagerExtension"]
        )
    ],
    targets: [
        // Extension logic + Shared code compiled as one module for SPM builds
        .target(
            name: "HostsManagerExtension",
            dependencies: [],
            path: ".",
            exclude: [
                "HostsManagerExtension/Assets.xcassets",
                "HostsManagerExtension/HostsManagerExtension.entitlements",
                "HostsManagerExtension/Info.plist",
                "HostsManagerExtension/HostsManagerExtension.swift",
                "HostsManagerApp",
                "HostsManagerHelper",
                "Tests",
                "HostsManager.xcodeproj",
                "README.md",
                "Package.swift"
            ],
            sources: [
                "Shared",
                "HostsManagerExtension"
            ]
        ),

        // Tests for validation and parsing
        .testTarget(
            name: "ValidationTests",
            dependencies: ["HostsManagerExtension"],
            path: "Tests/ValidationTests"
        ),

        .testTarget(
            name: "ParserTests",
            dependencies: ["HostsManagerExtension"],
            path: "Tests/ParserTests"
        ),

        .testTarget(
            name: "HostsManagerTests",
            dependencies: ["HostsManagerExtension"],
            path: "Tests/HostsManagerTests"
        )
    ],
    swiftLanguageModes: [.v5]
)
