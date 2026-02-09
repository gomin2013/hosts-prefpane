#!/usr/bin/swift
// Script to generate Xcode project structure for Hosts Manager
// This creates a Package.swift as an alternative to using Xcode directly

import Foundation

let packageContent = """
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HostsManager",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "HostsManagerApp",
            targets: ["HostsManagerApp"]
        ),
        .executable(
            name: "HostsManagerHelper",
            targets: ["HostsManagerHelper"]
        ),
    ],
    targets: [
        // Main App Target
        .executableTarget(
            name: "HostsManagerApp",
            dependencies: ["Shared"],
            path: "HostsManagerApp"
        ),

        // Extension Target (will be embedded in app bundle manually)
        .target(
            name: "HostsManagerExtension",
            dependencies: ["Shared"],
            path: "HostsManagerExtension"
        ),

        // Privileged Helper Tool
        .executableTarget(
            name: "HostsManagerHelper",
            dependencies: ["Shared"],
            path: "HostsManagerHelper"
        ),

        // Shared Code
        .target(
            name: "Shared",
            path: "Shared"
        ),

        // Tests
        .testTarget(
            name: "HostsManagerTests",
            dependencies: ["Shared"],
            path: "Tests"
        ),
    ]
)
"""

// Write Package.swift
let fileURL = URL(fileURLWithPath: "Package.swift")
try packageContent.write(to: fileURL, atomically: true, encoding: .utf8)

print("✅ Package.swift created successfully!")
print("📦 You can now build with: swift build")
print("🧪 Run tests with: swift test")

