//
}
    }
        ))
            comment: "Loopback"
            isEnabled: true,
            hostnames: ["localhost"],
            ipAddress: "127.0.0.1",
        HostEntryRow(entry: HostEntry(
    List {
#Preview("System Entry") {

}
    }
        ))
            comment: "Currently disabled"
            isEnabled: false,
            hostnames: ["staging.example.com"],
            ipAddress: "192.168.1.101",
        HostEntryRow(entry: HostEntry(
    List {
#Preview("Disabled Entry") {

}
    }
        ))
            comment: "Development server"
            isEnabled: true,
            hostnames: ["dev.example.com", "www.dev.example.com"],
            ipAddress: "192.168.1.100",
        HostEntryRow(entry: HostEntry(
    List {
#Preview("Enabled Entry") {
// MARK: - Preview

}
    }
        }
            return .gray
        } else {
            return .green
        if entry.isEnabled {
    private var statusColor: Color {

    }
        .padding(.vertical, 4)
        }
            }
                    .cornerRadius(4)
                    .background(Color.secondary.opacity(0.1))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .font(.caption)
                Text(comment)
            if let comment = entry.comment, !comment.isEmpty {
            // Comment badge

            Spacer()

            }
                }
                    }
                            .foregroundColor(.orange)
                            .font(.caption)
                        Label("System", systemImage: "lock.fill")
                    if entry.isSystemEntry {

                    }
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Label("\(entry.hostnames.count - 1) more", systemImage: "link")
                    if entry.hostnames.count > 1 {
                HStack(spacing: 8) {
                // Additional info

                    .monospaced()
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                Text(entry.ipAddress)
                // IP address

                    .foregroundColor(entry.isEnabled ? .primary : .secondary)
                    .font(.headline)
                Text(entry.primaryHostname)
                // Primary hostname
            VStack(alignment: .leading, spacing: 4) {

                .frame(width: 8, height: 8)
                .fill(statusColor)
            Circle()
            // Status indicator
        HStack(spacing: 12) {
    var body: some View {

    let entry: HostEntry
struct HostEntryRow: View {
/// Row component for displaying a single host entry in the list

import SwiftUI

//
//  Created on February 9, 2026.
//
//  Hosts Manager
//  HostEntryRow.swift

