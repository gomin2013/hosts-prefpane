//
//  HostEntryDetailView.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI

/// Detail view showing full information about a selected host entry
struct HostEntryDetailView: View {
    let entry: HostEntry
    let onUpdate: (HostEntry) -> Void
    let onDelete: () -> Void
    let onToggle: () -> Void

    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with status
                headerSection

                Divider()

                // Network information
                networkSection

                Divider()

                // Hostnames
                hostnamesSection

                Divider()

                // Metadata
                metadataSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
        .navigationTitle(entry.primaryHostname)
        .navigationSubtitle(entry.ipAddress)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEditor = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .disabled(entry.isSystemEntry)
            }
        }
        .sheet(isPresented: $showingEditor) {
            NavigationStack {
                HostEntryEditorView(
                    entry: entry,
                    hostsFile: HostsFileService.shared.hostsFile,
                    onSave: onUpdate
                )
            }
        }
        .confirmationDialog(
            "Delete Entry",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(entry.primaryHostname)'? This action cannot be undone.")
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(entry.isEnabled ? Color.green : Color.gray)
                    .frame(width: 48, height: 48)

                Image(systemName: entry.isEnabled ? "checkmark" : "xmark")
                    .foregroundColor(.white)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.isEnabled ? "Enabled" : "Disabled")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(entry.isEnabled ? "This entry is active" : "This entry is commented out")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if entry.isSystemEntry {
                Label("System", systemImage: "lock.fill")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(8)
            }
        }
    }

    private var networkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Network Information")

            DetailRow(label: "IP Address", value: entry.ipAddress, isMonospaced: true)

            if let comment = entry.comment {
                DetailRow(label: "Comment", value: comment)
            }
        }
    }

    private var hostnamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Hostnames (\(entry.hostnames.count))")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(entry.hostnames.enumerated()), id: \.offset) { index, hostname in
                    HStack {
                        if index == 0 {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        } else {
                            Image(systemName: "link")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(hostname)
                            .font(.system(.body, design: .monospaced))

                        Spacer()

                        Button {
                            copyToClipboard(hostname)
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(4)
                }
            }
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Metadata")

            DetailRow(label: "Created", value: formatDate(entry.createdAt))
            DetailRow(label: "Modified", value: formatDate(entry.modifiedAt))
            DetailRow(label: "Entry ID", value: entry.id.uuidString, isMonospaced: true)
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                onToggle()
            } label: {
                Label(entry.isEnabled ? "Disable Entry" : "Enable Entry",
                      systemImage: entry.isEnabled ? "pause.circle" : "play.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            if !entry.isSystemEntry {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete Entry", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(.top, 12)
    }

    // MARK: - Helpers

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var isMonospaced: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(isMonospaced ? .system(.body, design: .monospaced) : .body)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HostEntryDetailView(
            entry: HostEntry.samples[3],
            onUpdate: { _ in },
            onDelete: {},
            onToggle: {}
        )
    }
}

