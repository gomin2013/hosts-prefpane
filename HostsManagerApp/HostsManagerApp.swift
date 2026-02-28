//
//  HostsManagerApp.swift
//  Hosts Manager
//

import SwiftUI

/// Main application entry point — lives in the menu bar (no Dock icon)
@main
struct HostsManagerApp: App {

    init() {
        // All SMAppService lifecycle logic lives in HelperManager (Shared/XPC/).
        Task { await HelperManager.shared.ensureRegistered() }
    }

    var body: some Scene {
        MenuBarExtra("Hosts Manager", systemImage: "network") {
            HostsListView()
                .frame(
                    width: AppConstants.menuBarPopoverWidth,
                    height: AppConstants.menuBarPopoverHeight
                )
        }
        .menuBarExtraStyle(.window)
    }
}
