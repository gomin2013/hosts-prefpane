//
//  XPCService.swift
//  Hosts Manager — Shared
//
//  Swift actor — fully isolated from the main actor and from SwiftUI.
//  Connection state is broadcast via `connectionStream` (AsyncStream<Bool>)
//  so any consumer (View, ViewModel, test) can observe without @Published coupling.
//
//  Imported by: HostsManager (app), HostsManagerExtension, HostsManagerTests.
//

import Foundation

// MARK: - XPCService actor

actor XPCService: XPCServiceProtocol {

    // MARK: Singleton
    static let shared = XPCService()

    // MARK: Connection-state stream
    //
    // Observers subscribe like:
    //   Task { for await connected in XPCService.shared.connectionStream { … } }
    //
    private(set) var isConnected = false
    let connectionStream: AsyncStream<Bool>
    private let connectionContinuation: AsyncStream<Bool>.Continuation

    // MARK: Private state
    private var connection: NSXPCConnection?
    private var reconnectAttempts = 0
    private var reconnectTask: Task<Void, Never>?

    // MARK: Init
    private init() {
        var cont: AsyncStream<Bool>.Continuation!
        connectionStream = AsyncStream<Bool>(bufferingPolicy: .bufferingNewest(1)) { cont = $0 }
        connectionContinuation = cont
        setupConnection()
    }

    deinit {
        connection?.invalidate()
        reconnectTask?.cancel()
        connectionContinuation.finish()
    }

    // MARK: - Connection Management

    private func setupConnection() {
        connection?.invalidate()
        connection = nil

        let newConnection = NSXPCConnection(
            machServiceName: AppConstants.helperMachServiceName,
            options: .privileged
        )
        newConnection.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)

        // Capture `self` as unowned — actor references are safe here because
        // the handlers only dispatch a Task back to the actor.
        newConnection.invalidationHandler = { [weak self] in
            Task { [weak self] in
                await self?.handleInvalidation()
            }
        }

        newConnection.interruptionHandler = { [weak self] in
            Task { [weak self] in
                await self?.handleInterruption()
            }
        }

        newConnection.resume()
        connection = newConnection
        reconnectAttempts = 0

        Task {
            let ok = await checkConnection()
            if ok { AppLogger.xpc.info("XPC connection verified ✓") }
        }
    }

    private func handleInvalidation() {
        AppLogger.xpc.warning("XPC connection invalidated")
        updateConnected(false)
        connection = nil
        scheduleReconnect()
    }

    private func handleInterruption() {
        AppLogger.xpc.warning("XPC connection interrupted")
        updateConnected(false)
        scheduleReconnect()
    }

    private func updateConnected(_ value: Bool) {
        isConnected = value
        connectionContinuation.yield(value)
    }

    private func scheduleReconnect() {
        reconnectTask?.cancel()
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30.0)
        reconnectAttempts += 1
        let attempt = reconnectAttempts
        AppLogger.xpc.info("Reconnect attempt \(attempt) in \(delay)s")

        reconnectTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self.setupConnection()
        }
    }

    // MARK: - Ping

    func checkConnection() async -> Bool {
        return await withCheckedContinuation { (raw: CheckedContinuation<Bool, Never>) in
            let once = Once(raw)

            guard let conn = connection else {
                AppLogger.xpc.error("checkConnection: no connection object")
                once.resume(returning: false)
                return
            }

            // Error handler fires immediately if XPC can't reach the helper.
            // once.resume ensures the continuation is resolved even if ping's
            // callback is never called.
            let proxy = conn.remoteObjectProxyWithErrorHandler { [weak self] error in
                AppLogger.xpc.errorLog("checkConnection proxy error", error: error)
                Task { [weak self] in await self?.updateConnected(false) }
                once.resume(returning: false)
            }

            guard let helper = proxy as? HelperProtocol else {
                AppLogger.xpc.error("checkConnection: proxy cast failed")
                once.resume(returning: false)
                return
            }

            helper.ping { [weak self] success in
                Task { [weak self] in
                    await self?.updateConnected(success)
                    if success { await self?.resetReconnectAttempts() }
                }
                once.resume(returning: success)
            }
        }
    }

    private func resetReconnectAttempts() {
        reconnectAttempts = 0
        AppLogger.xpc.info("XPC connection established ✓")
    }

    // MARK: - Proxy factory

    private func makeProxy(onError: @escaping @Sendable (Error) -> Void) -> HelperProtocol? {
        guard let conn = connection else {
            AppLogger.xpc.error("No XPC connection available")
            return nil
        }
        let proxy = conn.remoteObjectProxyWithErrorHandler { error in
            AppLogger.xpc.errorLog("XPC proxy error", error: error)
            onError(error)
        }
        return proxy as? HelperProtocol
    }

    // MARK: - Public API

    func readHostsFile() async throws -> Data {
        try await withCheckedThrowingContinuation { (raw: CheckedContinuation<Data, Error>) in
            let once = OnceThrow(raw)
            guard let helper = makeProxy(onError: { once.resume(throwing: $0) }) else {
                once.resume(throwing: HelperError.connectionFailed); return
            }
            helper.readHostsFile { data, error in
                if let error { once.resume(throwing: error) }
                else if let data {
                    AppLogger.xpc.info("Read hosts file (\(data.count) bytes)")
                    once.resume(returning: data)
                } else { once.resume(throwing: HelperError.fileReadError) }
            }
        }
    }

    func writeHostsFile(content: Data) async throws {
        try await withCheckedThrowingContinuation { (raw: CheckedContinuation<Void, Error>) in
            let once = OnceThrow(raw)
            guard let helper = makeProxy(onError: { once.resume(throwing: $0) }) else {
                once.resume(throwing: HelperError.connectionFailed); return
            }
            helper.writeHostsFile(content: content) { success, error in
                if let error { once.resume(throwing: error) }
                else if success {
                    AppLogger.xpc.info("Wrote hosts file (\(content.count) bytes)")
                    once.resume(returning: ())
                } else { once.resume(throwing: HelperError.fileWriteError) }
            }
        }
    }

    func backupHostsFile() async throws {
        try await withCheckedThrowingContinuation { (raw: CheckedContinuation<Void, Error>) in
            let once = OnceThrow(raw)
            guard let helper = makeProxy(onError: { once.resume(throwing: $0) }) else {
                once.resume(throwing: HelperError.connectionFailed); return
            }
            helper.backupHostsFile { success, error in
                if let error { once.resume(throwing: error) }
                else if success {
                    AppLogger.xpc.info("Backed up hosts file")
                    once.resume(returning: ())
                } else { once.resume(throwing: HelperError.backupFailed) }
            }
        }
    }

    func restoreHostsFile() async throws {
        try await withCheckedThrowingContinuation { (raw: CheckedContinuation<Void, Error>) in
            let once = OnceThrow(raw)
            guard let helper = makeProxy(onError: { once.resume(throwing: $0) }) else {
                once.resume(throwing: HelperError.connectionFailed); return
            }
            helper.restoreHostsFile { success, error in
                if let error { once.resume(throwing: error) }
                else if success {
                    AppLogger.xpc.info("Restored hosts file")
                    once.resume(returning: ())
                } else { once.resume(throwing: HelperError.restoreFailed) }
            }
        }
    }

    func getVersion() async -> String {
        await withCheckedContinuation { (raw: CheckedContinuation<String, Never>) in
            let once = Once(raw)
            guard let helper = makeProxy(onError: { _ in once.resume(returning: "Unknown") }) else {
                once.resume(returning: "Unknown"); return
            }
            helper.getVersion { once.resume(returning: $0) }
        }
    }
}

