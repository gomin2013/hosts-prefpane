//
//  HostEntryRow.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import SwiftUI

/// Row component for displaying a single host entry in the list
struct HostEntryRow: View {
    let entry: HostEntry

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                // Primary hostname
                Text(entry.primaryHostname)
                    .font(.headline)
                    .foregroundColor(entry.isEnabled ? .primary : .secondary)

                // IP address
                Text(entry.ipAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospaced()

                // Additional info
                HStack(spacing: 8) {
                    if entry.hostnames.count > 1 {
                        Label("\(entry.hostnames.count - 1) more", systemImage: "link")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if entry.isSystemEntry {
                        Label("System", systemImage: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }

            Spacer()

            // Comment badge
            if let comment = entry.comment, !comment.isEmpty {
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
                    .accessibilityLabel("Comment: \(comment)")
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint(entry.isSystemEntry ? "System entry — cannot be deleted" : "Double-tap to view details")
    }

    private var statusColor: Color {
        entry.isEnabled ? .green : .gray
    }

    private var accessibilityDescription: String {
        var parts: [String] = []
        parts.append(entry.isEnabled ? "Enabled" : "Disabled")
        parts.append(entry.primaryHostname)
        parts.append("IP: \(entry.ipAddress)")
        if entry.hostnames.count > 1 {
            parts.append("\(entry.hostnames.count - 1) additional hostname\(entry.hostnames.count > 2 ? "s" : "")")
        }
        if entry.isSystemEntry { parts.append("System entry") }
        if let comment = entry.comment, !comment.isEmpty { parts.append("Comment: \(comment)") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Preview
#Preview("Enabled Entry") {
    List {
        HostEntryRow(entry: HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com", "www.dev.example.com"],
            isEnabled: true,
            comment: "Development server"
        ))
    }
}

#Preview("Disabled Entry") {
    List {
        HostEntryRow(entry: HostEntry(
            ipAddress: "192.168.1.101",
            hostnames: ["staging.example.com"],
            isEnabled: false,
            comment: "Currently disabled"
        ))
    }
}

#Preview("System Entry") {
    List {
        HostEntryRow(entry: HostEntry(
            ipAddress: "127.0.0.1",
            hostnames: ["localhost"],
            isEnabled: true,
            comment: "Loopback"
        ))
    }
}
