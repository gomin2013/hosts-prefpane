//
//  XPCBridge.swift
//  Hosts Manager — Shared
//
//  Pure-Foundation XPC contract and continuation-safety helpers.
//  Imported by: HostsManager (app), HostsManagerExtension, HostsManagerTests.
//  NOT imported by: HostsManagerHelper (has no XPC client code).
//

import Foundation

// MARK: - XPC Service Protocol

/// Async contract for all privileged-helper operations.
/// Implemented by `XPCService` (production) and `MockXPCService` (tests).
protocol XPCServiceProtocol: Sendable {
    func readHostsFile() async throws -> Data
    func writeHostsFile(content: Data) async throws
    func backupHostsFile() async throws
    func restoreHostsFile() async throws
    func checkConnection() async -> Bool
}

// MARK: - One-shot continuation wrappers

/// Wraps a non-throwing CheckedContinuation so it can only be resumed once.
/// Subsequent calls (e.g. from both an XPC error handler AND a callback) are no-ops.
final class Once<T: Sendable>: @unchecked Sendable {
    private var continuation: CheckedContinuation<T, Never>?
    private let lock = NSLock()

    init(_ continuation: CheckedContinuation<T, Never>) {
        self.continuation = continuation
    }

    func resume(returning value: T) {
        lock.lock()
        defer { lock.unlock() }
        continuation?.resume(returning: value)
        continuation = nil
    }
}

/// Wraps a throwing CheckedContinuation so it can only be resumed once.
final class OnceThrow<T: Sendable>: @unchecked Sendable {
    private var continuation: CheckedContinuation<T, Error>?
    private let lock = NSLock()

    init(_ continuation: CheckedContinuation<T, Error>) {
        self.continuation = continuation
    }

    func resume(returning value: T) {
        lock.lock()
        defer { lock.unlock() }
        continuation?.resume(returning: value)
        continuation = nil
    }

    func resume(throwing error: Error) {
        lock.lock()
        defer { lock.unlock() }
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

