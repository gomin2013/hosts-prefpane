//
//  ValidationService.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation
import Network

/// Service for validating IP addresses and hostnames
class ValidationService {

    /// Maximum number of hostnames per entry
    static let maxHostnamesPerEntry = 20

    // MARK: - IP Address Validation

    /// Validate an IP address (IPv4 or IPv6)
    static func validateIPAddress(_ ip: String) throws {
        let trimmed = ip.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyIPAddress
        }

        // Try to parse as IPv4 or IPv6
        guard IPv4Address(trimmed) != nil || IPv6Address(trimmed) != nil else {
            throw ValidationError.invalidIPAddress(trimmed)
        }
    }

    /// Check if string is a valid IP address (without throwing)
    static func isValidIPAddress(_ ip: String) -> Bool {
        do {
            try validateIPAddress(ip)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Hostname Validation

    /// Validate a hostname according to RFC 1123
    static func validateHostname(_ hostname: String) throws {
        let trimmed = hostname.trimmingCharacters(in: .whitespaces)

        guard !trimmed.isEmpty else {
            throw ValidationError.emptyHostname
        }

        // Check length (max 253 characters for FQDN)
        guard trimmed.count <= 253 else {
            throw ValidationError.invalidHostname(trimmed)
        }

        // Split into labels (parts separated by dots)
        let labels = trimmed.components(separatedBy: ".")

        for label in labels {
            // Each label must be 1-63 characters
            guard label.count >= 1 && label.count <= 63 else {
                throw ValidationError.invalidHostname(trimmed)
            }

            // Cannot start or end with hyphen
            guard !label.hasPrefix("-") && !label.hasSuffix("-") else {
                throw ValidationError.invalidHostname(trimmed)
            }

            // Must contain only alphanumeric and hyphens
            let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
            guard label.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
                throw ValidationError.invalidHostname(trimmed)
            }
        }
    }

    /// Check if string is a valid hostname (without throwing)
    static func isValidHostname(_ hostname: String) -> Bool {
        do {
            try validateHostname(hostname)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Host Entry Validation

    /// Validate a complete host entry
    static func validateEntry(
        _ entry: HostEntry,
        in hostsFile: HostsFile
    ) throws {
        // Validate IP address
        try validateIPAddress(entry.ipAddress)

        // Must have at least one hostname
        guard !entry.hostnames.isEmpty else {
            throw ValidationError.emptyHostname
        }

        // Check maximum hostnames
        guard entry.hostnames.count <= maxHostnamesPerEntry else {
            throw ValidationError.tooManyHostnames(entry.hostnames.count, max: maxHostnamesPerEntry)
        }

        // Validate each hostname
        for hostname in entry.hostnames {
            try validateHostname(hostname)

            // Check for duplicates in the file
            if hostsFile.contains(hostname: hostname, excluding: entry.id) {
                throw ValidationError.duplicateEntry(hostname)
            }
        }
    }

    /// Validate that hostnames are not reserved (for editing system entries)
    static func validateNotReserved(_ hostnames: [String]) throws {
        for hostname in hostnames {
            if HostsFileConstants.reservedHostnames.contains(hostname) {
                throw ValidationError.reservedHostname(hostname)
            }
        }
    }
}

// MARK: - String Extension for Validation
extension String {
    var isValidIPAddress: Bool {
        ValidationService.isValidIPAddress(self)
    }

    var isValidHostname: Bool {
        ValidationService.isValidHostname(self)
    }
}

