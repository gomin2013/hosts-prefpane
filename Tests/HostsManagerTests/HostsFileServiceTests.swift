//
//  HostsFileServiceTests.swift
//  Hosts Manager Tests
//
//  Created on March 1, 2026.
//

import XCTest

@MainActor
final class HostsFileServiceTests: XCTestCase {

    var mockXPC: MockXPCService!

    override func setUp() async throws {
        try await super.setUp()
        mockXPC = MockXPCService()
    }

    override func tearDown() async throws {
        mockXPC.reset()
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeService(seeded hostsContent: String = "") -> HostsFileService {
        mockXPC.seed(hostsContent: hostsContent)
        return HostsFileService(xpcOverride: mockXPC)
    }

    private let sampleContent = """
    ##
    # Host Database
    ##
    127.0.0.1\tlocalhost
    ::1\tlocalhost
    192.168.1.100\tdev.example.com\t# Dev server
    """

    // MARK: - Load

    func testLoadPopulatesEntries() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        XCTAssertFalse(service.hostsFile.entries.isEmpty)
        XCTAssertEqual(mockXPC.readCallCount, 1)
    }

    func testLoadSetsLastModified() async throws {
        let service = makeService(seeded: sampleContent)
        XCTAssertNil(service.lastModified)
        try await service.load()
        XCTAssertNotNil(service.lastModified)
    }

    func testLoadThrowsOnReadError() async {
        mockXPC.stubbedReadError = HelperError.fileReadError
        let service = makeService()
        await XCTAssertThrowsErrorAsync(try await service.load()) { error in
            XCTAssertTrue(error is HelperError)
        }
        XCTAssertNotNil(service.lastError)
    }

    func testLoadSetsIsLoadingFalseAfterCompletion() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()
        XCTAssertFalse(service.isLoading)
    }

    // MARK: - Add Entry

    func testAddEntryAppendsAndSaves() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()
        let initial = service.hostsFile.entries.count

        let newEntry = HostEntry(ipAddress: "10.0.0.5", hostnames: ["test.local"])
        try await service.addEntry(newEntry)

        XCTAssertEqual(service.hostsFile.entries.count, initial + 1)
        XCTAssertEqual(mockXPC.writeCallCount, 1)
        XCTAssertEqual(mockXPC.backupCallCount, 1)
    }

    func testAddDuplicateHostnameThrows() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        let duplicate = HostEntry(ipAddress: "10.0.0.9", hostnames: ["dev.example.com"])
        await XCTAssertThrowsErrorAsync(try await service.addEntry(duplicate)) { error in
            guard let validationError = error as? ValidationError,
                  case .duplicateEntry = validationError else {
                XCTFail("Expected ValidationError.duplicateEntry")
                return
            }
        }
        XCTAssertEqual(mockXPC.writeCallCount, 0) // should not have written
    }

    // MARK: - Update Entry

    func testUpdateEntryWritesToDisk() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        guard let entry = service.hostsFile.entries.first(where: { !$0.isSystemEntry }) else {
            XCTFail("No non-system entry found")
            return
        }

        let updated = entry.updating { $0.comment = "Updated comment" }
        try await service.updateEntry(updated)

        let found = service.hostsFile.entry(withID: entry.id)
        XCTAssertEqual(found?.comment, "Updated comment")
        XCTAssertEqual(mockXPC.writeCallCount, 1)
    }

    // MARK: - Delete Entry

    func testDeleteNonSystemEntrySucceeds() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        guard let entry = service.hostsFile.entries.first(where: { !$0.isSystemEntry }) else {
            XCTFail("No non-system entry")
            return
        }
        let countBefore = service.hostsFile.entries.count
        try await service.deleteEntry(entry)
        XCTAssertEqual(service.hostsFile.entries.count, countBefore - 1)
    }

    func testDeleteSystemEntryThrows() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        guard let systemEntry = service.hostsFile.entries.first(where: { $0.isSystemEntry }) else {
            XCTFail("No system entry")
            return
        }

        await XCTAssertThrowsErrorAsync(try await service.deleteEntry(systemEntry)) { error in
            guard let appError = error as? AppError,
                  case .operationFailed = appError else {
                XCTFail("Expected AppError.operationFailed")
                return
            }
        }
        XCTAssertEqual(mockXPC.writeCallCount, 0)
    }

    // MARK: - Toggle Entry

    func testToggleEntryFlipsEnabledState() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        guard let entry = service.hostsFile.entries.first(where: { !$0.isSystemEntry }) else {
            XCTFail("No non-system entry")
            return
        }
        let originalState = entry.isEnabled
        try await service.toggleEntry(entry)

        let toggled = service.hostsFile.entry(withID: entry.id)
        XCTAssertEqual(toggled?.isEnabled, !originalState)
        XCTAssertEqual(mockXPC.writeCallCount, 1)
    }

    // MARK: - Delete Multiple

    func testDeleteMultipleEntries() async throws {
        let service = makeService(seeded: sampleContent)
        try await service.load()

        let nonSystem = service.hostsFile.entries.filter { !$0.isSystemEntry }
        guard !nonSystem.isEmpty else {
            XCTFail("Need at least one non-system entry")
            return
        }
        let idsToDelete = Set(nonSystem.map { $0.id })
        let countBefore = service.hostsFile.entries.count

        try await service.deleteEntries(ids: idsToDelete)
        XCTAssertEqual(service.hostsFile.entries.count, countBefore - nonSystem.count)
    }

    // MARK: - Export

    func testExportToFile() throws {
        let service = makeService(seeded: sampleContent)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("hosts_export_\(UUID().uuidString)")

        // Seed internal hostsFile without going through XPC
        _ = try HostsFile.parse(content: sampleContent)

        // Just verify the method doesn't throw with a valid URL
        // (hostsFile is empty since we didn't load via XPC)
        XCTAssertNoThrow(try service.exportToFile(url: url))

        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Write error propagates

    func testSaveThrowsOnWriteError() async throws {
        mockXPC.stubbedWriteError = HelperError.fileWriteError
        let service = makeService(seeded: sampleContent)
        try await service.load()

        let entry = HostEntry(ipAddress: "10.0.0.99", hostnames: ["new.local"])
        await XCTAssertThrowsErrorAsync(try await service.addEntry(entry)) { error in
            XCTAssertNotNil(error)
        }
        XCTAssertNotNil(service.lastError)
    }
}

// MARK: - Async XCTAssert helper

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(message().isEmpty ? "Expected error to be thrown" : message(), file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
