//
//  HostsFileService.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation
import Combine

/// Service coordinating hosts file I/O operations
@MainActor
class HostsFileService: ObservableObject {
    static let shared = HostsFileService()

    @Published private(set) var hostsFile: HostsFile = HostsFile()
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: Error?
    @Published private(set) var lastModified: Date?

    private let xpcService: XPCServiceProtocol

    /// Default singleton initialiser — uses the real XPC service
    init() {
        self.xpcService = XPCService.shared
    }

    /// Testable initialiser — accepts any XPCServiceProtocol implementation
    init(xpcOverride: XPCServiceProtocol) {
        self.xpcService = xpcOverride
    }

    // MARK: - Read Operations

    /// Load the hosts file from disk
    func load() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await xpcService.readHostsFile()

            guard let content = String(data: data, encoding: .utf8) else {
                throw AppError.invalidFileFormat
            }

            let parsed = try HostsFile.parse(content: content)

            self.hostsFile = parsed
            self.lastModified = Date()
            self.lastError = nil

            AppLogger.fileIO.info("Loaded hosts file with \(parsed.entries.count) entries")

        } catch {
            self.lastError = error
            AppLogger.fileIO.errorLog("Failed to load hosts file", error: error)
            throw error
        }
    }

    /// Reload the hosts file (convenience method)
    func reload() async {
        do {
            try await load()
        } catch {
            // Error already logged and stored
        }
    }

    // MARK: - Write Operations

    /// Save the current hosts file to disk
    func save() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let content = hostsFile.serialize()

            guard let data = content.data(using: .utf8) else {
                throw AppError.invalidFileFormat
            }

            // Create backup before writing
            try await xpcService.backupHostsFile()

            // Write the file
            try await xpcService.writeHostsFile(content: data)

            self.lastModified = Date()
            self.lastError = nil

            AppLogger.fileIO.info("Saved hosts file with \(self.hostsFile.entries.count) entries")

        } catch {
            self.lastError = error
            AppLogger.fileIO.errorLog("Failed to save hosts file", error: error)
            throw error
        }
    }

    // MARK: - Entry Management

    /// Add a new entry
    func addEntry(_ entry: HostEntry) async throws {
        // Validate before adding
        try ValidationService.validateEntry(entry, in: hostsFile)

        hostsFile.upsert(entry)
        try await save()
    }

    /// Update an existing entry
    func updateEntry(_ entry: HostEntry) async throws {
        // Validate before updating
        try ValidationService.validateEntry(entry, in: hostsFile)

        hostsFile.upsert(entry)
        try await save()
    }

    /// Delete an entry
    func deleteEntry(_ entry: HostEntry) async throws {
        // Don't allow deleting system entries
        guard !entry.isSystemEntry else {
            throw AppError.operationFailed("Cannot delete system entries")
        }

        hostsFile.remove(entry)
        try await save()
    }

    /// Delete multiple entries
    func deleteEntries(ids: Set<UUID>) async throws {
        // Filter out system entries
        let systemEntries = hostsFile.entries.filter { $0.isSystemEntry && ids.contains($0.id) }
        guard systemEntries.isEmpty else {
            throw AppError.operationFailed("Cannot delete system entries")
        }

        hostsFile.remove(ids: ids)
        try await save()
    }

    /// Toggle enabled state of an entry
    func toggleEntry(_ entry: HostEntry) async throws {
        var updated = entry
        updated.isEnabled.toggle()
        updated.modifiedAt = Date()

        hostsFile.upsert(updated)
        try await save()
    }

    // MARK: - Connection Status

    /// Whether the XPC helper is currently connected
    var isXPCConnected: Bool {
        (xpcService as? XPCService)?.isConnected ?? true
    }

    /// Re-check helper connection and reload if successful
    func retryConnection() async {
        if let realXPC = xpcService as? XPCService {
            let connected = await realXPC.checkConnection()
            if connected {
                await reload()
            }
        }
    }

    // MARK: - Backup & Restore

    /// Create a backup of the current hosts file
    func createBackup() async throws {
        try await xpcService.backupHostsFile()
        AppLogger.fileIO.info("Created hosts file backup")
    }

    /// Restore from backup
    func restoreFromBackup() async throws {
        try await xpcService.restoreHostsFile()
        try await load()
        AppLogger.fileIO.info("Restored hosts file from backup")
    }

    // MARK: - Import & Export

    /// Export hosts file to a custom location
    func exportToFile(url: URL) throws {
        let content = hostsFile.serialize()
        try content.write(to: url, atomically: true, encoding: .utf8)
        AppLogger.fileIO.info("Exported hosts file to \(url.path)")
    }

    /// Import hosts file from a custom location
    func importFromFile(url: URL) async throws {
        let content = try String(contentsOf: url, encoding: .utf8)
        let parsed = try HostsFile.parse(content: content)

        // Validate all entries before importing
        for entry in parsed.entries {
            // Basic validation only (no duplicate check since we're replacing everything)
            try ValidationService.validateIPAddress(entry.ipAddress)
            for hostname in entry.hostnames {
                try ValidationService.validateHostname(hostname)
            }
        }

        hostsFile = parsed
        try await save()

        AppLogger.fileIO.info("Imported hosts file from \(url.path) with \(parsed.entries.count) entries")
    }
}
