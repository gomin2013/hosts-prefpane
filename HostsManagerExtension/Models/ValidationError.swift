//
//  ValidationError.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

/// Errors that can occur during validation of host entries
enum ValidationError: LocalizedError, Equatable {
    case invalidIPAddress(String)
    case invalidHostname(String)
    case emptyIPAddress
    case emptyHostname
    case duplicateEntry(String)
    case reservedHostname(String)
    case tooManyHostnames(Int, max: Int)

    var errorDescription: String? {
        switch self {
        case .invalidIPAddress(let ip):
            return "Invalid IP address: '\(ip)'"
        case .invalidHostname(let hostname):
            return "Invalid hostname: '\(hostname)'"
        case .emptyIPAddress:
            return "IP address cannot be empty"
        case .emptyHostname:
            return "At least one hostname is required"
        case .duplicateEntry(let hostname):
            return "Duplicate hostname: '\(hostname)'"
        case .reservedHostname(let hostname):
            return "Reserved hostname cannot be modified: '\(hostname)'"
        case .tooManyHostnames(let count, let max):
            return "Too many hostnames (\(count)). Maximum allowed: \(max)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .invalidIPAddress:
            return "Please enter a valid IPv4 (e.g., 192.168.1.1) or IPv6 (e.g., ::1) address"
        case .invalidHostname:
            return "Hostnames must follow RFC 1123 standards. Use only letters, numbers, dots, and hyphens"
        case .emptyIPAddress:
            return "Enter an IP address"
        case .emptyHostname:
            return "Enter at least one hostname"
        case .duplicateEntry:
            return "This hostname already exists in the hosts file"
        case .reservedHostname:
            return "System hostnames like 'localhost' and 'broadcasthost' are protected"
        case .tooManyHostnames:
            return "Remove some hostnames or split into multiple entries"
        }
    }
}

