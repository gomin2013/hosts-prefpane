//
//  HelperManager.swift
//  Hosts Manager — Shared
//
//  Owns the entire SMAppService daemon lifecycle.
//  Imported by: HostsManager (app) only — registration MUST happen in the main app process.
//  (The extension and helper targets do NOT need this file.)
//

import Foundation
import ServiceManagement

// MARK: - HelperManager actor

/// Manages registration of the privileged helper daemon via SMAppService.
/// Call `ensureRegistered()` once at app startup.
actor HelperManager {

    static let shared = HelperManager()
    private init() {}

    /// Register the privileged helper daemon.
    /// - `.notRegistered`  → registers for the first time
    /// - `.requiresApproval` → opens System Settings › Login Items for the user
    /// - `.enabled`  → no-op (already running)
    /// - `.notFound` → logs an error (plist missing from bundle)
    func ensureRegistered() {
        let service = SMAppService.daemon(plistName: "Launchd.plist")
        let status  = service.status

        AppLogger.general.info("Helper status: \(status.rawValue)")

        switch status {
        case .notRegistered:
            do {
                try service.register()
                AppLogger.general.info("Helper registered ✓")
            } catch {
                AppLogger.general.error("Failed to register helper: \(error.localizedDescription)")
            }

        case .requiresApproval:
            AppLogger.general.warning("Helper requires user approval — opening System Settings")
            SMAppService.openSystemSettingsLoginItems()

        case .enabled:
            AppLogger.general.info("Helper already enabled ✓")

        case .notFound:
            AppLogger.general.error("Launchd.plist not found in app bundle")

        @unknown default:
            AppLogger.general.warning("Unknown helper status: \(status.rawValue)")
        }
    }

    /// Unregister the daemon (useful for a "Quit & Uninstall" feature).
    func unregister() async {
        let service = SMAppService.daemon(plistName: "Launchd.plist")
        do {
            try await service.unregister()
            AppLogger.general.info("Helper unregistered")
        } catch {
            AppLogger.general.error("Failed to unregister helper: \(error.localizedDescription)")
        }
    }
}

