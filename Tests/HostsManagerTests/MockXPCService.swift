//
//  MockXPCService.swift
//  Hosts Manager Tests
//
//  Created on March 1, 2026.
//

import Foundation

// MARK: - Mock XPC Service

/// In-memory mock XPC service for unit testing — no helper process required
final class MockXPCService: XPCServiceProtocol {

    // MARK: Configurable stubs
    var stubbedReadData: Data = Data()
    var stubbedReadError: Error?
    var stubbedWriteError: Error?
    var stubbedBackupError: Error?
    var stubbedRestoreError: Error?
    var stubbedIsConnected: Bool = true

    // MARK: Call tracking
    private(set) var readCallCount = 0
    private(set) var writeCallCount = 0
    private(set) var backupCallCount = 0
    private(set) var restoreCallCount = 0
    private(set) var lastWrittenData: Data?

    // MARK: In-memory storage
    private var storage: Data = Data()

    // MARK: - XPCServiceProtocol

    func readHostsFile() async throws -> Data {
        readCallCount += 1
        if let error = stubbedReadError { throw error }
        return stubbedReadData.isEmpty ? storage : stubbedReadData
    }

    func writeHostsFile(content: Data) async throws {
        writeCallCount += 1
        if let error = stubbedWriteError { throw error }
        storage = content
        lastWrittenData = content
    }

    func backupHostsFile() async throws {
        backupCallCount += 1
        if let error = stubbedBackupError { throw error }
    }

    func restoreHostsFile() async throws {
        restoreCallCount += 1
        if let error = stubbedRestoreError { throw error }
    }

    func checkConnection() async -> Bool {
        stubbedIsConnected
    }

    // MARK: - Helpers

    /// Seed the in-memory store with a hosts file string
    func seed(hostsContent: String) {
        storage = Data(hostsContent.utf8)
        stubbedReadData = Data()          // use storage path
    }

    func reset() {
        stubbedReadData = Data()
        stubbedReadError = nil
        stubbedWriteError = nil
        stubbedBackupError = nil
        stubbedRestoreError = nil
        stubbedIsConnected = true
        readCallCount = 0
        writeCallCount = 0
        backupCallCount = 0
        restoreCallCount = 0
        lastWrittenData = nil
        storage = Data()
    }
}
