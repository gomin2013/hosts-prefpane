//
//  HelperProtocol.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

/// Protocol for communication between the app and privileged helper
@objc protocol HelperProtocol {

    /// Read the hosts file content
    /// - Parameter completion: Callback with file data or error
    func readHostsFile(completion: @escaping (Data?, Error?) -> Void)

    /// Write content to the hosts file
    /// - Parameters:
    ///   - content: The new hosts file content
    ///   - completion: Callback with success status and optional error
    func writeHostsFile(content: Data, completion: @escaping (Bool, Error?) -> Void)

    /// Create a backup of the current hosts file
    /// - Parameter completion: Callback with success status and optional error
    func backupHostsFile(completion: @escaping (Bool, Error?) -> Void)

    /// Restore hosts file from backup
    /// - Parameter completion: Callback with success status and optional error
    func restoreHostsFile(completion: @escaping (Bool, Error?) -> Void)

    /// Get the helper tool version
    /// - Parameter completion: Callback with version string
    func getVersion(completion: @escaping (String) -> Void)

    /// Check if helper is running and responsive
    /// - Parameter completion: Callback with status
    func ping(completion: @escaping (Bool) -> Void)
}

/// Errors that can occur in the helper tool
enum HelperError: Error, LocalizedError {
    case fileReadError
    case fileWriteError
    case backupFailed
    case restoreFailed
    case permissionDenied
    case invalidData
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .fileReadError:
            return "Failed to read hosts file"
        case .fileWriteError:
            return "Failed to write hosts file"
        case .backupFailed:
            return "Failed to create backup"
        case .restoreFailed:
            return "Failed to restore from backup"
        case .permissionDenied:
            return "Permission denied"
        case .invalidData:
            return "Invalid data provided"
        case .connectionFailed:
            return "Failed to connect to helper tool"
        }
    }
}

