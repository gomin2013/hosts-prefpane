//
//  HelperStatusMonitor.swift
//  Hosts Manager — Shared
//
//  @MainActor Observable wrapper that bridges XPCService.connectionStream
//  into a SwiftUI-friendly published property.
//
//  Usage in a View:
//      @StateObject private var helperStatus = HelperStatusMonitor.shared
//      // or via .environmentObject(HelperStatusMonitor.shared)
//
//  Imported by: HostsManagerExtension (Views/ViewModels only).
//

import Foundation
import Combine

// MARK: - HelperStatusMonitor

@MainActor
final class HelperStatusMonitor: ObservableObject {

    static let shared = HelperStatusMonitor()

    @Published private(set) var isConnected: Bool = false
    @Published private(set) var helperVersion: String = "Unknown"

    private var monitorTask: Task<Void, Never>?

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitorTask?.cancel()
        monitorTask = Task { [weak self] in
            for await connected in await XPCService.shared.connectionStream {
                guard !Task.isCancelled else { break }
                await MainActor.run { self?.isConnected = connected }

                // Fetch version string whenever we (re)connect
                if connected {
                    let version = await XPCService.shared.getVersion()
                    await MainActor.run { self?.helperVersion = version }
                }
            }
        }
    }

    deinit {
        monitorTask?.cancel()
    }
}

