//
//  HostEntryEditorView.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI

/// View for adding or editing a host entry
struct HostEntryEditorView: View {
    @StateObject private var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss

    let onSave: (HostEntry) -> Void

    init(entry: HostEntry?, hostsFile: HostsFile, onSave: @escaping (HostEntry) -> Void) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(entry: entry, hostsFile: hostsFile))
        self.onSave = onSave
    }

    var body: some View {
        Form {
            networkSection
            optionsSection
            if !viewModel.validationErrors.isEmpty {
                validationSection
            }
            infoSection
        }
        .formStyle(.grouped)
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(!viewModel.isValid)
            }
        }
        .onChange(of: viewModel.ipAddress) {
            viewModel.validate()
        }
        .onChange(of: viewModel.hostnamesText) {
            viewModel.validate()
        }
        .onAppear {
            viewModel.validate()
        }
    }

    private func save() {
        guard let entry = viewModel.createEntry() else {
            return
        }

        onSave(entry)
        dismiss()
    }

    @ViewBuilder
    private var networkSection: some View {
        Section("Network Information") {
            // IP Address
            VStack(alignment: .leading, spacing: 4) {
                Text("IP Address")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("192.168.1.100 or ::1", text: $viewModel.ipAddress)
                    .textFieldStyle(.roundedBorder)
                    .monospaced()
                    .autocorrectionDisabled()
            }

            // Hostnames
            VStack(alignment: .leading, spacing: 4) {
                Text("Hostnames (space or line separated)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $viewModel.hostnamesText)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 80)
                    .border(Color.secondary.opacity(0.2))
                    .autocorrectionDisabled()
            }
            .help("Enter one or more hostnames, separated by spaces or new lines")
        }
    }

    @ViewBuilder
    private var optionsSection: some View {
        Section("Additional Options") {
            // Comment
            VStack(alignment: .leading, spacing: 4) {
                Text("Comment (optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Development server", text: $viewModel.comment)
                    .textFieldStyle(.roundedBorder)
            }

            // Enabled toggle
            Toggle("Entry enabled", isOn: $viewModel.isEnabled)
                .help("Disabled entries are commented out in the hosts file")
        }
    }

    @ViewBuilder
    private var validationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.validationErrors, id: \.self) { error in
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(error.localizedDescription)
                                .font(.caption)
                            if let suggestion = error.recoverySuggestion {
                                Text(suggestion)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .listRowBackground(Color.orange.opacity(0.1))
    }

    @ViewBuilder
    private var infoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(icon: "info.circle", text: "IP addresses must be valid IPv4 or IPv6 format")
                InfoRow(icon: "info.circle", text: "Hostnames must follow RFC 1123 standards")
                InfoRow(icon: "info.circle", text: "Changes take effect immediately after saving")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Helper Views

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
    }
}

// MARK: - Preview
#Preview("Add Entry") {
    NavigationStack {
        HostEntryEditorView(
            entry: nil,
            hostsFile: .sample,
            onSave: { _ in }
        )
    }
}

#Preview("Edit Entry") {
    NavigationStack {
        HostEntryEditorView(
            entry: HostEntry.samples[3],
            hostsFile: .sample,
            onSave: { _ in }
        )
    }
}
