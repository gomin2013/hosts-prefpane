//
//  ParserTests.swift
//  Hosts Manager Tests
//
//  Created on February 9, 2026.
//

import XCTest
@testable import HostsManagerExtension

final class ParserTests: XCTestCase {

    func testParseEmptyFile() throws {
        let content = ""
        let hostsFile = try HostsFile.parse(content: content)

        XCTAssertTrue(hostsFile.entries.isEmpty)
        XCTAssertFalse(hostsFile.headerComments.isEmpty) // Should have default header
    }

    func testParseBasicEntries() throws {
        let content = """
        ##
        # Host Database
        ##
        127.0.0.1   localhost
        ::1         localhost
        """

        let hostsFile = try HostsFile.parse(content: content)

        XCTAssertEqual(hostsFile.entries.count, 2)
        XCTAssertFalse(hostsFile.headerComments.isEmpty)

        let firstEntry = hostsFile.entries[0]
        XCTAssertEqual(firstEntry.ipAddress, "127.0.0.1")
        XCTAssertEqual(firstEntry.hostnames, ["localhost"])
        XCTAssertTrue(firstEntry.isEnabled)
    }

    func testParseDisabledEntry() throws {
        let content = """
        127.0.0.1   localhost
        # 192.168.1.100   dev.example.com
        """

        let hostsFile = try HostsFile.parse(content: content)

        XCTAssertEqual(hostsFile.entries.count, 2)

        let disabledEntry = hostsFile.entries[1]
        XCTAssertEqual(disabledEntry.ipAddress, "192.168.1.100")
        XCTAssertEqual(disabledEntry.hostnames, ["dev.example.com"])
        XCTAssertFalse(disabledEntry.isEnabled)
    }

    func testParseEntryWithComment() throws {
        let content = """
        192.168.1.100   dev.example.com   # Development server
        """

        let hostsFile = try HostsFile.parse(content: content)

        XCTAssertEqual(hostsFile.entries.count, 1)

        let entry = hostsFile.entries[0]
        XCTAssertEqual(entry.ipAddress, "192.168.1.100")
        XCTAssertEqual(entry.hostnames, ["dev.example.com"])
        XCTAssertEqual(entry.comment, "Development server")
        XCTAssertTrue(entry.isEnabled)
    }

    func testParseEntryWithMultipleHostnames() throws {
        let content = """
        192.168.1.100   dev.example.com www.dev.example.com api.dev.example.com
        """

        let hostsFile = try HostsFile.parse(content: content)

        XCTAssertEqual(hostsFile.entries.count, 1)

        let entry = hostsFile.entries[0]
        XCTAssertEqual(entry.ipAddress, "192.168.1.100")
        XCTAssertEqual(entry.hostnames.count, 3)
        XCTAssertEqual(entry.hostnames, ["dev.example.com", "www.dev.example.com", "api.dev.example.com"])
    }

    func testSerializeBasicEntry() {
        var hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com"],
            isEnabled: true
        )
        hostsFile.upsert(entry)

        let serialized = hostsFile.serialize()

        XCTAssertTrue(serialized.contains("192.168.1.100"))
        XCTAssertTrue(serialized.contains("dev.example.com"))
        XCTAssertFalse(serialized.contains("# 192.168.1.100")) // Should not be commented
    }

    func testSerializeDisabledEntry() {
        var hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com"],
            isEnabled: false
        )
        hostsFile.upsert(entry)

        let serialized = hostsFile.serialize()

        XCTAssertTrue(serialized.contains("# 192.168.1.100")) // Should be commented
        XCTAssertTrue(serialized.contains("dev.example.com"))
    }

    func testSerializeEntryWithComment() {
        var hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com"],
            isEnabled: true,
            comment: "Development server"
        )
        hostsFile.upsert(entry)

        let serialized = hostsFile.serialize()

        XCTAssertTrue(serialized.contains("192.168.1.100"))
        XCTAssertTrue(serialized.contains("dev.example.com"))
        XCTAssertTrue(serialized.contains("# Development server"))
    }

    func testRoundTripParsing() throws {
        let originalContent = """
        ##
        # Host Database
        ##
        127.0.0.1   localhost
        ::1         localhost
        192.168.1.100   dev.example.com www.dev.example.com   # Development
        # 192.168.1.101   staging.example.com   # Disabled
        """

        let hostsFile = try HostsFile.parse(content: originalContent)
        let serialized = hostsFile.serialize()
        let reparsed = try HostsFile.parse(content: serialized)

        XCTAssertEqual(hostsFile.entries.count, reparsed.entries.count)

        for (original, reparsedEntry) in zip(hostsFile.entries.sorted(), reparsed.entries.sorted()) {
            XCTAssertEqual(original.ipAddress, reparsedEntry.ipAddress)
            XCTAssertEqual(original.hostnames, reparsedEntry.hostnames)
            XCTAssertEqual(original.isEnabled, reparsedEntry.isEnabled)
        }
    }

    func testHostsFileContainsHostname() {
        var hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com"]
        )
        hostsFile.upsert(entry)

        XCTAssertTrue(hostsFile.contains(hostname: "dev.example.com"))
        XCTAssertFalse(hostsFile.contains(hostname: "staging.example.com"))
        XCTAssertFalse(hostsFile.contains(hostname: "dev.example.com", excluding: entry.id))
    }
}

