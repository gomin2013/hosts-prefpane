//
//  HostEntryTests.swift
//  Hosts Manager Tests
//
//  Created on March 1, 2026.
//

import XCTest

final class HostEntryTests: XCTestCase {

    // MARK: - Initialisation

    func testDefaultInit() {
        let entry = HostEntry(ipAddress: "127.0.0.1", hostnames: ["localhost"])
        XCTAssertFalse(entry.id.uuidString.isEmpty)
        XCTAssertEqual(entry.ipAddress, "127.0.0.1")
        XCTAssertEqual(entry.hostnames, ["localhost"])
        XCTAssertTrue(entry.isEnabled)
        XCTAssertNil(entry.comment)
    }

    func testInitWithAllParameters() {
        let id = UUID()
        let created = Date(timeIntervalSince1970: 1000)
        let modified = Date(timeIntervalSince1970: 2000)
        let entry = HostEntry(
            id: id,
            ipAddress: "192.168.1.1",
            hostnames: ["a.com", "b.com"],
            isEnabled: false,
            comment: "test comment",
            createdAt: created,
            modifiedAt: modified
        )
        XCTAssertEqual(entry.id, id)
        XCTAssertEqual(entry.ipAddress, "192.168.1.1")
        XCTAssertEqual(entry.hostnames, ["a.com", "b.com"])
        XCTAssertFalse(entry.isEnabled)
        XCTAssertEqual(entry.comment, "test comment")
        XCTAssertEqual(entry.createdAt, created)
        XCTAssertEqual(entry.modifiedAt, modified)
    }

    // MARK: - Computed Properties

    func testPrimaryHostname() {
        let entry = HostEntry(ipAddress: "10.0.0.1", hostnames: ["first.com", "second.com"])
        XCTAssertEqual(entry.primaryHostname, "first.com")
    }

    func testPrimaryHostnameFallback() {
        let entry = HostEntry(ipAddress: "10.0.0.1", hostnames: [])
        XCTAssertEqual(entry.primaryHostname, "Unknown")
    }

    func testAdditionalHostnames() {
        let entry = HostEntry(ipAddress: "10.0.0.1", hostnames: ["a.com", "b.com", "c.com"])
        XCTAssertEqual(entry.additionalHostnames, ["b.com", "c.com"])
    }

    func testAdditionalHostnamesEmpty() {
        let entry = HostEntry(ipAddress: "10.0.0.1", hostnames: ["a.com"])
        XCTAssertTrue(entry.additionalHostnames.isEmpty)
    }

    func testHostnamesString() {
        let entry = HostEntry(ipAddress: "10.0.0.1", hostnames: ["a.com", "b.com"])
        XCTAssertEqual(entry.hostnamesString, "a.com b.com")
    }

    // MARK: - hostsFileFormat

    func testHostsFileFormatEnabled() {
        let entry = HostEntry(ipAddress: "192.168.1.100", hostnames: ["dev.com"], isEnabled: true)
        let line = entry.hostsFileFormat
        XCTAssertEqual(line, "192.168.1.100\tdev.com")
        XCTAssertFalse(line.hasPrefix("#"))
    }

    func testHostsFileFormatDisabled() {
        let entry = HostEntry(ipAddress: "192.168.1.100", hostnames: ["dev.com"], isEnabled: false)
        XCTAssertTrue(entry.hostsFileFormat.hasPrefix("# "))
        XCTAssertTrue(entry.hostsFileFormat.contains("192.168.1.100"))
    }

    func testHostsFileFormatWithComment() {
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.com"],
            isEnabled: true,
            comment: "my comment"
        )
        XCTAssertTrue(entry.hostsFileFormat.hasSuffix("# my comment"))
    }

    func testHostsFileFormatMultipleHostnames() {
        let entry = HostEntry(ipAddress: "10.0.0.1", hostnames: ["a.com", "b.com", "c.com"])
        XCTAssertEqual(entry.hostsFileFormat, "10.0.0.1\ta.com b.com c.com")
    }

    // MARK: - isSystemEntry

    func testIsSystemEntryLocalhost() {
        let entry = HostEntry(ipAddress: "127.0.0.1", hostnames: ["localhost"])
        XCTAssertTrue(entry.isSystemEntry)
    }

    func testIsSystemEntryBroadcasthost() {
        let entry = HostEntry(ipAddress: "255.255.255.255", hostnames: ["broadcasthost"])
        XCTAssertTrue(entry.isSystemEntry)
    }

    func testIsNotSystemEntry() {
        let entry = HostEntry(ipAddress: "192.168.1.1", hostnames: ["dev.example.com"])
        XCTAssertFalse(entry.isSystemEntry)
    }

    // MARK: - updating()

    func testUpdating() {
        let original = HostEntry(ipAddress: "10.0.0.1", hostnames: ["a.com"])
        let beforeModify = original.modifiedAt

        // Slight delay to ensure time difference
        let updated = original.updating { $0.ipAddress = "10.0.0.2" }

        XCTAssertEqual(updated.id, original.id)
        XCTAssertEqual(updated.ipAddress, "10.0.0.2")
        XCTAssertEqual(updated.hostnames, original.hostnames)
        XCTAssertGreaterThanOrEqual(updated.modifiedAt, beforeModify)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.com", "api.dev.com"],
            isEnabled: false,
            comment: "roundtrip"
        )
        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(HostEntry.self, from: data)

        XCTAssertEqual(entry.id, decoded.id)
        XCTAssertEqual(entry.ipAddress, decoded.ipAddress)
        XCTAssertEqual(entry.hostnames, decoded.hostnames)
        XCTAssertEqual(entry.isEnabled, decoded.isEnabled)
        XCTAssertEqual(entry.comment, decoded.comment)
    }

    // MARK: - Comparable (sorting)

    func testSystemEntriesComeFirst() {
        let systemEntry = HostEntry(ipAddress: "127.0.0.1", hostnames: ["localhost"])
        let regularEntry = HostEntry(ipAddress: "192.168.1.1", hostnames: ["zzz.com"])
        XCTAssertLessThan(systemEntry, regularEntry)
    }

    func testAlphabeticalSort() {
        let alphaEntry = HostEntry(ipAddress: "10.0.0.1", hostnames: ["alpha.com"])
        let betaEntry = HostEntry(ipAddress: "10.0.0.2", hostnames: ["beta.com"])
        XCTAssertLessThan(alphaEntry, betaEntry)
    }

    func testSortedArray() {
        let entries = [
            HostEntry(ipAddress: "10.0.0.3", hostnames: ["zebra.com"]),
            HostEntry(ipAddress: "127.0.0.1", hostnames: ["localhost"]),
            HostEntry(ipAddress: "10.0.0.1", hostnames: ["alpha.com"])
        ]
        let sorted = entries.sorted()
        XCTAssertEqual(sorted[0].primaryHostname, "localhost")   // system first
        XCTAssertEqual(sorted[1].primaryHostname, "alpha.com")
        XCTAssertEqual(sorted[2].primaryHostname, "zebra.com")
    }

    // MARK: - Hashable / Equatable

    func testHashableConsistency() {
        let entry = HostEntry(ipAddress: "127.0.0.1", hostnames: ["localhost"])
        var set = Set<HostEntry>()
        set.insert(entry)
        set.insert(entry)
        XCTAssertEqual(set.count, 1)
    }
}
