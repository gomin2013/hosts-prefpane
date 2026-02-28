//
//  HostEntry.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

/// Represents a single entry in the hosts file
struct HostEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var ipAddress: String
    var hostnames: [String]
    var isEnabled: Bool
    var comment: String?
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        ipAddress: String,
        hostnames: [String],
        isEnabled: Bool = true,
        comment: String? = nil,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.ipAddress = ipAddress
        self.hostnames = hostnames
        self.isEnabled = isEnabled
        self.comment = comment
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }

    /// The primary hostname (first in the list)
    var primaryHostname: String {
        hostnames.first ?? "Unknown"
    }

    /// Additional hostnames (excluding the first)
    var additionalHostnames: [String] {
        Array(hostnames.dropFirst())
    }

    /// All hostnames as a single string
    var hostnamesString: String {
        hostnames.joined(separator: " ")
    }

    /// Format the entry for writing to hosts file
    var hostsFileFormat: String {
        var line = ""

        // Add comment prefix if disabled
        if !isEnabled {
            line += "# "
        }

        // IP address and hostnames
        line += "\(ipAddress)\t\(hostnamesString)"

        // Add inline comment if present
        if let comment = comment, !comment.isEmpty {
            line += " # \(comment)"
        }

        return line
    }

    /// Check if this is a system-reserved entry
    var isSystemEntry: Bool {
        hostnames.contains { HostsFileConstants.reservedHostnames.contains($0) }
    }

    /// Create a copy with updated modification date
    func updating(_ update: (inout HostEntry) -> Void) -> HostEntry {
        var copy = self
        copy.modifiedAt = Date()
        update(&copy)
        return copy
    }
}

// MARK: - Comparable
extension HostEntry: Comparable {
    static func < (lhs: HostEntry, rhs: HostEntry) -> Bool {
        // System entries come first
        if lhs.isSystemEntry != rhs.isSystemEntry {
            return lhs.isSystemEntry
        }

        // Then sort by primary hostname
        return lhs.primaryHostname.localizedCaseInsensitiveCompare(rhs.primaryHostname) == .orderedAscending
    }
}

// MARK: - Sample Data
extension HostEntry {
    static let samples: [HostEntry] = [
        HostEntry(
            ipAddress: "127.0.0.1",
            hostnames: ["localhost"],
            isEnabled: true,
            comment: "Loopback"
        ),
        HostEntry(
            ipAddress: "::1",
            hostnames: ["localhost"],
            isEnabled: true,
            comment: "IPv6 loopback"
        ),
        HostEntry(
            ipAddress: "255.255.255.255",
            hostnames: ["broadcasthost"],
            isEnabled: true
        ),
        HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com", "www.dev.example.com"],
            isEnabled: true,
            comment: "Development server"
        ),
        HostEntry(
            ipAddress: "192.168.1.101",
            hostnames: ["staging.example.com"],
            isEnabled: false,
            comment: "Staging environment (disabled)"
        )
    ]
}
