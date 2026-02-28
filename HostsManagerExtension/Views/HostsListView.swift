//
//  HostsListView.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI

/// Main view displaying the list of host entries
struct HostsListView: View {
    @StateObject private var viewModel = HostsViewModel()
    @State private var showingAddEntry = false
    @State private var selectedEntry: HostEntry?
    @State private var showingImportPicker = false
    @State private var showingExportPicker = false
    @State private var showingRestoreConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            NavigationSplitView {
                sidebarContent
            } detail: {
                detailContent
            }
            .alert(item: $viewModel.error) { alertError in
                Alert(
                    title: Text(alertError.title),
                    message: Text(alertError.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingAddEntry) {
                NavigationStack {
                    HostEntryEditorView(
                        entry: nil,
                        hostsFile: viewModel.fileService.hostsFile,
                        onSave: { viewModel.add($0) }
                    )
                }
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.text, .plainText],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .fileExporter(
                isPresented: $showingExportPicker,
                document: HostsFileDocument(content: viewModel.fileService.hostsFile.serialize()),
                contentType: .plainText,
                defaultFilename: "hosts"
            ) { result in
                handleExport(result: result)
            }
            .confirmationDialog(
                "Restore from Backup",
                isPresented: $showingRestoreConfirmation,
                titleVisibility: .visible
            ) {
                Button("Restore", role: .destructive) {
                    viewModel.restoreFromBackup()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will replace your current hosts file with the backup. This action cannot be undone.")
            }
            .task {
                await viewModel.loadInitial()
            }

            Divider()

            MenuBarFooter()
        }
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        VStack(spacing: 0) {
            if !viewModel.isXPCConnected {
                ConnectionWarningBanner {
                    Task { await viewModel.retryConnection() }
                }
            }

            statsBar
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "Stats: \(viewModel.totalEntries) total, \(viewModel.enabledEntries) enabled, " +
                    "\(viewModel.disabledEntries) disabled, \(viewModel.systemEntries) system"
                )

            Divider()

            if viewModel.isLoading {
                ProgressView("Loading hosts file…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityLabel("Loading")
            } else if viewModel.filteredEntries.isEmpty {
                HostsEmptyStateView(
                    isSearching: !viewModel.searchText.isEmpty,
                    onAddEntry: { showingAddEntry = true }
                )
            } else {
                List(selection: $selectedEntry) {
                    ForEach(viewModel.filteredEntries) { entry in
                        HostEntryRow(entry: entry)
                            .tag(entry)
                            .contextMenu {
                                entryContextMenu(for: entry)
                            }
                    }
                    .onDeleteCommand {
                        if let entry = selectedEntry {
                            viewModel.delete(entry)
                            selectedEntry = nil
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search hosts")
        .navigationTitle("Hosts Manager")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddEntry = true
                } label: {
                    Label("Add Entry", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
                .accessibilityLabel("Add new host entry")
                .accessibilityHint("Opens the editor to create a new host entry")
            }

            ToolbarItem(placement: .automatic) {
                Menu {
                    HostsMenuContent(
                        onImport: { showingImportPicker = true },
                        onExport: { showingExportPicker = true },
                        onBackup: { viewModel.createBackup() },
                        onRestore: { showingRestoreConfirmation = true },
                        onRefresh: { Task { await viewModel.reload() } }
                    )
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
                .accessibilityLabel("More actions")
            }
        }
    }

    // MARK: - Detail

    private var detailContent: some View {
        Group {
            if let entry = selectedEntry {
                HostEntryDetailView(entry: entry) { updatedEntry in
                    viewModel.update(updatedEntry)
                } onDelete: {
                    viewModel.delete(entry)
                    selectedEntry = nil
                } onToggle: {
                    viewModel.toggleEnabled(entry)
                }
            } else {
                EmptyDetailView()
            }
        }
    }

    // MARK: - Helper Views

    private var statsBar: some View {
        HStack(spacing: 20) {
            StatItem(label: "Total", value: "\(viewModel.totalEntries)", color: .blue)
            StatItem(label: "Enabled", value: "\(viewModel.enabledEntries)", color: .green)
            StatItem(label: "Disabled", value: "\(viewModel.disabledEntries)", color: .gray)
            StatItem(label: "System", value: "\(viewModel.systemEntries)", color: .orange)
        }
        .font(.caption)
    }

    @ViewBuilder
    private func entryContextMenu(for entry: HostEntry) -> some View {
        Button("Edit") {
            selectedEntry = entry
        }
        .accessibilityLabel("Edit \(entry.primaryHostname)")

        Button("Duplicate") {
            viewModel.duplicate(entry)
        }
        .accessibilityLabel("Duplicate \(entry.primaryHostname)")

        Divider()

        Button(entry.isEnabled ? "Disable" : "Enable") {
            viewModel.toggleEnabled(entry)
        }
        .accessibilityLabel(entry.isEnabled ? "Disable \(entry.primaryHostname)" : "Enable \(entry.primaryHostname)")

        if !entry.isSystemEntry {
            Button("Delete", role: .destructive) {
                viewModel.delete(entry)
            }
            .accessibilityLabel("Delete \(entry.primaryHostname)")
        }
    }

    // MARK: - File Handling

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            viewModel.importFromFile(url: url)
        case .failure(let error):
            viewModel.error = AlertError(error: error)
        }
    }

    private func handleExport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            viewModel.exportToFile(url: url)
        case .failure(let error):
            viewModel.error = AlertError(error: error)
        }
    }
}

// MARK: - Connection Warning Banner

private struct ConnectionWarningBanner: View {
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Helper not connected")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("The privileged helper tool is not running. Read-only mode.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Retry", action: onRetry)
                .font(.caption)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.15))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Warning: Helper tool not connected. Retry connection.")
    }
}

// MARK: - Hosts Menu Content

private struct HostsMenuContent: View {
    let onImport: () -> Void
    let onExport: () -> Void
    let onBackup: () -> Void
    let onRestore: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        Button(action: onImport) {
            Label("Import...", systemImage: "square.and.arrow.down")
        }

        Button(action: onExport) {
            Label("Export...", systemImage: "square.and.arrow.up")
        }

        Divider()

        Button(action: onBackup) {
            Label("Create Backup", systemImage: "clock.arrow.circlepath")
        }

        Button(action: onRestore) {
            Label("Restore from Backup", systemImage: "arrow.counterclockwise")
        }

        Divider()

        Button(action: onRefresh) {
            Label("Refresh", systemImage: "arrow.clockwise")
        }
        .keyboardShortcut("r", modifiers: .command)
    }
}

// MARK: - Empty State View

private struct HostsEmptyStateView: View {
    let isSearching: Bool
    let onAddEntry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            Text(isSearching ? "No Results" : "No Entries")
                .font(.title2)
                .fontWeight(.semibold)

            Text(isSearching
                 ? "Try a different search term"
                 : "Add your first host entry to get started")
                .foregroundColor(.secondary)

            if !isSearching {
                Button("Add Entry", action: onAddEntry)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut("n", modifiers: .command)
                    .accessibilityHint("Opens the editor to create a new host entry")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Menu Bar Footer

private struct MenuBarFooter: View {
    var body: some View {
        HStack {
            Text("Hosts Manager \(AppConstants.appVersion)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .keyboardShortcut("q", modifiers: .command)
            .accessibilityLabel("Quit Hosts Manager")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Preview
#Preview {
    HostsListView()
}
