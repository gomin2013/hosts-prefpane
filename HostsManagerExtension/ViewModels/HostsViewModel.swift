//
}
    var systemEntries: Int { entries.filter { $0.isSystemEntry }.count }
    var disabledEntries: Int { entries.filter { !$0.isEnabled }.count }
    var enabledEntries: Int { entries.filter { $0.isEnabled }.count }
    var totalEntries: Int { entries.count }

    // MARK: - Statistics

    }
        }
            (entry.comment?.localizedCaseInsensitiveContains(searchText) ?? false)
            entry.hostnames.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            entry.ipAddress.localizedCaseInsensitiveContains(searchText) ||
        return entries.filter { entry in

        }
            return entries
        if searchText.isEmpty {
    var filteredEntries: [HostEntry] {

    // MARK: - Filtering

    }
        }
            self.error = AlertError(error: error)
        } catch {
            try fileService.exportToFile(url: url)
        do {
    func exportToFile(url: URL) {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                try await fileService.importFromFile(url: url)
            do {
        Task {
    func importFromFile(url: URL) {

    }
        showingExportDialog = true
    func showExportDialog() {

    }
        showingImportDialog = true
    func showImportDialog() {

    // MARK: - Import & Export

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                try await fileService.restoreFromBackup()
            do {
        Task {
    func restoreFromBackup() {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                try await fileService.createBackup()
            do {
        Task {
    func createBackup() {

    // MARK: - Backup & Restore

    }
        add(newEntry)

        newEntry.comment = (newEntry.comment ?? "") + " (copy)"
        newEntry.modifiedAt = Date()
        newEntry.createdAt = Date()
        newEntry.id = UUID()
        var newEntry = entry
    func duplicate(_ entry: HostEntry) {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                try await fileService.toggleEntry(entry)
            do {
        Task {
    func toggleEnabled(_ entry: HostEntry) {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                selectedEntries.removeAll()
                try await fileService.deleteEntries(ids: selectedEntries)
            do {
        Task {

        guard !selectedEntries.isEmpty else { return }
    func deleteSelected() {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                selectedEntries.remove(entry.id)
                try await fileService.deleteEntry(entry)
            do {
        Task {
    func delete(_ entry: HostEntry) {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                try await fileService.updateEntry(entry)
            do {
        Task {
    func update(_ entry: HostEntry) {

    }
        }
            }
                self.error = AlertError(error: error)
            } catch {
                try await fileService.addEntry(entry)
            do {
        Task {
    func add(_ entry: HostEntry) {

    // MARK: - Entry Management

    }
        await fileService.reload()
    func reload() async {

    }
        }
            self.error = AlertError(error: error)
        } catch {
            try await fileService.load()
        do {
    func loadInitial() async {

    // MARK: - Lifecycle

    }
            .assign(to: &$error)
            .receive(on: DispatchQueue.main)
            .map { AlertError(error: $0) }
            .compactMap { $0 }
        fileService.$lastError

            .assign(to: &$isLoading)
            .receive(on: DispatchQueue.main)
        fileService.$isLoading

            .assign(to: &$entries)
            .receive(on: DispatchQueue.main)
            .map { $0.entries }
        fileService.$hostsFile
        // Subscribe to file service updates
    init() {

    private var cancellables = Set<AnyCancellable>()
    private let fileService = HostsFileService.shared

    @Published var showingExportDialog = false
    @Published var showingImportDialog = false
    @Published var error: AlertError?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedEntries: Set<UUID> = []
    @Published var entries: [HostEntry] = []
class HostsViewModel: ObservableObject {
@MainActor
/// Main view model for the hosts list view

import Combine
import SwiftUI
import Foundation

//
//  Created on February 9, 2026.
//
//  Hosts Manager
//  HostsViewModel.swift

