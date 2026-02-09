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
    }

    // MARK: - Sidebar

    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // Statistics bar
            statsBar
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // List
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredEntries.isEmpty {
                emptyStateView
            } else {
                List(selection: $selectedEntry) {
                    ForEach(viewModel.filteredEntries) { entry in
                        HostEntryRow(entry: entry)
                            .tag(entry)
                            .contextMenu {
                                entryContextMenu(for: entry)
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
            }

            ToolbarItem(placement: .automatic) {
                Menu {
                    menuContent
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                }
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

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text(viewModel.searchText.isEmpty ? "No Entries" : "No Results")
                .font(.title2)
                .fontWeight(.semibold)

            Text(viewModel.searchText.isEmpty
                 ? "Add your first host entry to get started"
                 : "Try a different search term")
                .foregroundColor(.secondary)

            if viewModel.searchText.isEmpty {
                Button("Add Entry") {
                    showingAddEntry = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var menuContent: some View {
        Group {
            Button {
                showingImportPicker = true
            } label: {
                Label("Import...", systemImage: "square.and.arrow.down")
            }

            Button {
                showingExportPicker = true
            } label: {
                Label("Export...", systemImage: "square.and.arrow.up")
            }

            Divider()

            Button {
                viewModel.createBackup()
            } label: {
                Label("Create Backup", systemImage: "clock.arrow.circlepath")
            }

            Button {
                showingRestoreConfirmation = true
            } label: {
                Label("Restore from Backup", systemImage: "arrow.counterclockwise")
            }

            Divider()

            Button {
                Task { await viewModel.reload() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .keyboardShortcut("r", modifiers: .command)
        }
    }

    @ViewBuilder
    private func entryContextMenu(for entry: HostEntry) -> some View {
        Button("Edit") {
            selectedEntry = entry
        }

        Button("Duplicate") {
            viewModel.duplicate(entry)
        }

        Divider()

        Button(entry.isEnabled ? "Disable" : "Enable") {
            viewModel.toggleEnabled(entry)
        }

        if !entry.isSystemEntry {
            Button("Delete", role: .destructive) {
                viewModel.delete(entry)
            }
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

// MARK: - Supporting Views

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyDetailView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Select an Entry")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a host entry from the list to view details")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Document Type
struct HostsFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var content: String

    init(content: String) {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

// MARK: - Preview
#Preview {
    HostsListView()
}

