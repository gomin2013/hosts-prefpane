//
//  HostsViewModel.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation
import SwiftUI
import Combine

/// Main view model for the hosts list view
@MainActor
class HostsViewModel: ObservableObject {
    @Published var entries: [HostEntry] = []
    @Published var selectedEntries: Set<UUID> = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var error: AlertError?
    @Published var showingImportDialog = false
    @Published var showingExportDialog = false

    private(set) var fileService = HostsFileService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to file service updates
        fileService.$hostsFile
            .map { $0.entries }
            .receive(on: DispatchQueue.main)
            .assign(to: &$entries)

        fileService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        fileService.$lastError
            .compactMap { $0 }
            .map { AlertError(error: $0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$error)
    }

    // MARK: - Lifecycle

    func loadInitial() async {
        do {
            try await fileService.load()
        } catch {
            self.error = AlertError(error: error)
        }
    }

    func reload() async {
        await fileService.reload()
    }

    // MARK: - Entry Management

    func add(_ entry: HostEntry) {
        Task {
            do {
                try await fileService.addEntry(entry)
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func update(_ entry: HostEntry) {
        Task {
            do {
                try await fileService.updateEntry(entry)
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func delete(_ entry: HostEntry) {
        Task {
            do {
                selectedEntries.remove(entry.id)
                try await fileService.deleteEntry(entry)
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func deleteSelected() {
        guard !selectedEntries.isEmpty else { return }
        Task {
            do {
                try await fileService.deleteEntries(ids: selectedEntries)
                selectedEntries.removeAll()
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func toggleEnabled(_ entry: HostEntry) {
        Task {
            do {
                try await fileService.toggleEntry(entry)
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func duplicate(_ entry: HostEntry) {
        let newEntry = HostEntry(
            ipAddress: entry.ipAddress,
            hostnames: entry.hostnames,
            isEnabled: entry.isEnabled,
            comment: (entry.comment ?? "") + " (copy)"
        )
        add(newEntry)
    }

    // MARK: - Backup & Restore

    func createBackup() {
        Task {
            do {
                try await fileService.createBackup()
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func restoreFromBackup() {
        Task {
            do {
                try await fileService.restoreFromBackup()
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    // MARK: - Import & Export

    func showImportDialog() {
        showingImportDialog = true
    }

    func showExportDialog() {
        showingExportDialog = true
    }

    func importFromFile(url: URL) {
        Task {
            do {
                try await fileService.importFromFile(url: url)
            } catch {
                self.error = AlertError(error: error)
            }
        }
    }

    func exportToFile(url: URL) {
        do {
            try fileService.exportToFile(url: url)
        } catch {
            self.error = AlertError(error: error)
        }
    }

    // MARK: - Filtering

    var filteredEntries: [HostEntry] {
        if searchText.isEmpty {
            return entries
        }

        return entries.filter { entry in
            entry.ipAddress.localizedCaseInsensitiveContains(searchText) ||
            entry.hostnames.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            (entry.comment?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    // MARK: - Statistics

    var totalEntries: Int { entries.count }
    var enabledEntries: Int { entries.filter { $0.isEnabled }.count }
    var disabledEntries: Int { entries.filter { !$0.isEnabled }.count }
    var systemEntries: Int { entries.filter { $0.isSystemEntry }.count }

    // MARK: - Connection

    var isXPCConnected: Bool {
        fileService.isXPCConnected
    }

    func retryConnection() async {
        await fileService.retryConnection()
    }
}
