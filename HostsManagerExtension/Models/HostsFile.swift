//
//  HostsFile.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

/// Represents the complete hosts file with all entries
struct HostsFile {
    var entries: [HostEntry]
    var headerComments: [String]

    init(entries: [HostEntry] = [], headerComments: [String] = []) {
        self.entries = entries
        self.headerComments = headerComments
    }

    /// Parse a hosts file content string into a HostsFile structure
    static func parse(content: String) throws -> HostsFile {
        var entries: [HostEntry] = []
        var headerComments: [String] = []
        var isInHeader = true

        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            // Skip empty lines
            if trimmedLine.isEmpty {
                continue
            }

            // Handle comment-only lines
            if trimmedLine.hasPrefix("#") {
                if isInHeader {
                    headerComments.append(trimmedLine)
                }
                continue
            }

            // We've left the header once we hit a non-comment line
            isInHeader = false

            // Parse entry line
            if let entry = parseEntry(from: line) {
                entries.append(entry)
            }
        }

        // If no header comments were found, use default
        if headerComments.isEmpty {
            headerComments = HostsFileConstants.defaultHeader
                .components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }

        return HostsFile(entries: entries, headerComments: headerComments)
    }

    /// Parse a single entry line
    private static func parseEntry(from line: String) -> HostEntry? {
        var workingLine = line
        var isEnabled = true
        var comment: String?

        // Check if entry is disabled (commented out)
        if workingLine.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
            isEnabled = false
            // Remove the leading #
            if let hashIndex = workingLine.firstIndex(of: "#") {
                workingLine = String(workingLine[workingLine.index(after: hashIndex)...])
            }
        }

        // Extract inline comment if present
        if let commentIndex = workingLine.firstIndex(of: "#") {
            comment = String(workingLine[workingLine.index(after: commentIndex)...])
                .trimmingCharacters(in: .whitespaces)
            workingLine = String(workingLine[..<commentIndex])
        }

        // Split by whitespace to get IP and hostnames
        let components = workingLine
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        guard components.count >= 2 else {
            return nil
        }

        let ipAddress = components[0]
        let hostnames = Array(components[1...])

        return HostEntry(
            ipAddress: ipAddress,
            hostnames: hostnames,
            isEnabled: isEnabled,
            comment: comment
        )
    }

    /// Serialize the hosts file back to string format
    func serialize() -> String {
        var output: [String] = []

        // Add header comments
        output.append(contentsOf: headerComments)
        output.append("")

        // Add entries (sorted: system entries first, then alphabetically)
        let sortedEntries = entries.sorted()

        for entry in sortedEntries {
            output.append(entry.hostsFileFormat)
        }

        // Ensure trailing newline
        output.append("")

        return output.joined(separator: "\n")
    }

    /// Find an entry by ID
    func entry(withID id: UUID) -> HostEntry? {
        entries.first { $0.id == id }
    }

    /// Check if a hostname already exists
    func contains(hostname: String, excluding entryID: UUID? = nil) -> Bool {
        entries.contains { entry in
            guard entry.id != entryID else { return false }
            return entry.hostnames.contains(hostname)
        }
    }

    /// Add or update an entry
    mutating func upsert(_ entry: HostEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
    }

    /// Remove an entry
    mutating func remove(_ entry: HostEntry) {
        entries.removeAll { $0.id == entry.id }
    }

    /// Remove entries by ID
    mutating func remove(ids: Set<UUID>) {
        entries.removeAll { ids.contains($0.id) }
    }
}

// MARK: - Sample Data
extension HostsFile {
    static var sample: HostsFile {
        HostsFile(
            entries: HostEntry.samples,
            headerComments: HostsFileConstants.defaultHeader
                .components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        )
    }
}

