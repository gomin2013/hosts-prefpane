//
//  XPCService.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

/// XPC client for communicating with the privileged helper tool
@MainActor
class XPCService: ObservableObject {
    static let shared = XPCService()

    @Published private(set) var isConnected = false
    @Published private(set) var helperVersion: String?

    private var connection: NSXPCConnection?
    private let connectionQueue = DispatchQueue(label: "com.hostsmanager.xpc", qos: .userInitiated)

    private init() {
        setupConnection()
    }

    deinit {
        connection?.invalidate()
    }

    // MARK: - Connection Management

    private func setupConnection() {
        let newConnection = NSXPCConnection(machServiceName: AppConstants.helperMachServiceName, options: .privileged)

        newConnection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)

        newConnection.invalidationHandler = { [weak self] in
            Task { @MainActor in
                AppLogger.xpc.warning("XPC connection invalidated")
                self?.isConnected = false
                self?.connection = nil
            }
        }

        newConnection.interruptionHandler = { [weak self] in
            Task { @MainActor in
                AppLogger.xpc.warning("XPC connection interrupted")
                self?.isConnected = false
            }
        }

        newConnection.resume()
        self.connection = newConnection

        // Test connection
        Task {
            await checkConnection()
        }
    }

    /// Check if the helper is responsive
    func checkConnection() async -> Bool {
        guard let helper = getHelper() else {
            await MainActor.run {
                self.isConnected = false
            }
            return false
        }

        return await withCheckedContinuation { continuation in
            helper.ping { [weak self] success in
                Task { @MainActor in
                    self?.isConnected = success
                    if success {
                        AppLogger.xpc.info("XPC connection established")
                    }
                }
                continuation.resume(returning: success)
            }
        }
    }

    private func getHelper() -> HelperProtocol? {
        guard let connection = connection else {
            AppLogger.xpc.error("No XPC connection available")
            return nil
        }

        return connection.remoteObjectProxyWithErrorHandler { error in
            AppLogger.xpc.error("XPC proxy error", error: error)
        } as? HelperProtocol
    }

    // MARK: - Public API

    /// Read the hosts file
    func readHostsFile() async throws -> Data {
        guard let helper = getHelper() else {
            throw HelperError.connectionFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            helper.readHostsFile { data, error in
                if let error = error {
                    AppLogger.xpc.error("Failed to read hosts file", error: error)
                    continuation.resume(throwing: error)
                } else if let data = data {
                    AppLogger.xpc.info("Successfully read hosts file (\(data.count) bytes)")
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: HelperError.fileReadError)
                }
            }
        }
    }

    /// Write to the hosts file
    func writeHostsFile(content: Data) async throws {
        guard let helper = getHelper() else {
            throw HelperError.connectionFailed
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            helper.writeHostsFile(content: content) { success, error in
                if let error = error {
                    AppLogger.xpc.error("Failed to write hosts file", error: error)
                    continuation.resume(throwing: error)
                } else if success {
                    AppLogger.xpc.info("Successfully wrote hosts file (\(content.count) bytes)")
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HelperError.fileWriteError)
                }
            }
        }
    }

    /// Create a backup of the hosts file
    func backupHostsFile() async throws {
        guard let helper = getHelper() else {
            throw HelperError.connectionFailed
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            helper.backupHostsFile { success, error in
                if let error = error {
                    AppLogger.xpc.error("Failed to backup hosts file", error: error)
                    continuation.resume(throwing: error)
                } else if success {
                    AppLogger.xpc.info("Successfully backed up hosts file")
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HelperError.backupFailed)
                }
            }
        }
    }

    /// Restore hosts file from backup
    func restoreHostsFile() async throws {
        guard let helper = getHelper() else {
            throw HelperError.connectionFailed
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            helper.restoreHostsFile { success, error in
                if let error = error {
                    AppLogger.xpc.error("Failed to restore hosts file", error: error)
                    continuation.resume(throwing: error)
                } else if success {
                    AppLogger.xpc.info("Successfully restored hosts file")
                    continuation.resume()
                } else {
                    continuation.resume(throwing: HelperError.restoreFailed)
                }
            }
        }
    }

    /// Get helper tool version
    func getVersion() async -> String {
        guard let helper = getHelper() else {
            return "Unknown"
        }

        return await withCheckedContinuation { continuation in
            helper.getVersion { version in
                continuation.resume(returning: version)
            }
        }
    }
}

