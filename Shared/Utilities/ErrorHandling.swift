//
//  ErrorHandling.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

/// Generic app error types
enum AppError: LocalizedError {
    case fileNotFound(String)
    case fileAccessDenied(String)
    case invalidFileFormat
    case helperNotInstalled
    case helperConnectionFailed
    case operationFailed(String)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .fileAccessDenied(let path):
            return "Access denied to file: \(path)"
        case .invalidFileFormat:
            return "Invalid hosts file format"
        case .helperNotInstalled:
            return "Privileged helper tool is not installed"
        case .helperConnectionFailed:
            return "Failed to connect to helper tool"
        case .operationFailed(let reason):
            return "Operation failed: \(reason)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "Please check if the file exists"
        case .fileAccessDenied:
            return "Please grant the necessary permissions"
        case .invalidFileFormat:
            return "The hosts file may be corrupted. Consider restoring from backup"
        case .helperNotInstalled:
            return "Please reinstall the application"
        case .helperConnectionFailed:
            return "Try restarting the application"
        case .operationFailed:
            return "Please try again"
        case .unknown:
            return "Please report this issue"
        }
    }
}

/// Error wrapper for SwiftUI alerts
struct AlertError: Identifiable {
    let id = UUID()
    let error: Error

    var title: String {
        "Error"
    }

    var message: String {
        error.localizedDescription
    }
}
