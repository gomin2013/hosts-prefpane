//
//  HostsManagerExtension.swift
//  Hosts Manager Extension
//
//  Created on February 9, 2026.
//

import SwiftUI

/// Settings extension entry point
/// Note: For macOS Sequoia, this will use the Settings Extension framework
/// For now, this serves as the main interface when run standalone
@main
struct HostsManagerExtension: App {
    var body: some Scene {
        WindowGroup {
            HostsListView()
                .frame(
                    minWidth: AppConstants.minimumWindowWidth,
                    minHeight: AppConstants.minimumWindowHeight
                )
        }
        .defaultSize(
            width: AppConstants.defaultWindowWidth,
            height: AppConstants.defaultWindowHeight
        )
    }
}

// Note: When building as a proper Settings Extension for macOS Sequoia,
// replace the above with:
//
// import SettingsKit
//
// @main
// struct HostsManagerExtension: SettingsExtension {
//     var body: some SettingsExtensionScene {
//         SettingsScene {
//             HostsListView()
//         }
//     }
// }

