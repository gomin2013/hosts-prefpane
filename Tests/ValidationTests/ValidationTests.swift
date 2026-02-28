//
//  ValidationTests.swift
//  Hosts Manager Tests
//
//  Created on February 9, 2026.
//

import XCTest

final class ValidationTests: XCTestCase {

    // MARK: - IP Address Validation Tests

    func testValidIPv4Addresses() throws {
        let validIPs = [
            "127.0.0.1",
            "192.168.1.1",
            "10.0.0.1",
            "255.255.255.255",
            "0.0.0.0"
        ]

        for ipAddress in validIPs {
            XCTAssertNoThrow(
                try ValidationService.validateIPAddress(ipAddress),
                "Should accept valid IPv4: \(ipAddress)"
            )
            XCTAssertTrue(
                ValidationService.isValidIPAddress(ipAddress),
                "isValidIPAddress should return true for: \(ipAddress)"
            )
        }
    }

    func testValidIPv6Addresses() throws {
        let validIPs = [
            "::1",
            "fe80::1",
            "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
            "2001:db8:85a3::8a2e:370:7334",
            "::"
        ]

        for ipAddress in validIPs {
            XCTAssertNoThrow(
                try ValidationService.validateIPAddress(ipAddress),
                "Should accept valid IPv6: \(ipAddress)"
            )
            XCTAssertTrue(
                ValidationService.isValidIPAddress(ipAddress),
                "isValidIPAddress should return true for: \(ipAddress)"
            )
        }
    }

    func testInvalidIPAddresses() {
        let invalidIPs = [
            "256.1.1.1",
            "not-an-ip",
            "",
            "   ",
            "192.168.1.a"
        ]

        for ipAddress in invalidIPs {
            XCTAssertThrowsError(
                try ValidationService.validateIPAddress(ipAddress),
                "Should reject invalid IP: \(ipAddress)"
            )
            XCTAssertFalse(
                ValidationService.isValidIPAddress(ipAddress),
                "isValidIPAddress should return false for: \(ipAddress)"
            )
        }
    }

    // MARK: - Hostname Validation Tests

    func testValidHostnames() throws {
        let validHostnames = [
            "localhost",
            "example.com",
            "sub.example.com",
            "my-server",
            "server-123",
            "a.b.c.d.e.f",
            "xn--e1afmkfd.xn--p1ai" // internationalized domain
        ]

        for hostname in validHostnames {
            XCTAssertNoThrow(
                try ValidationService.validateHostname(hostname),
                "Should accept valid hostname: \(hostname)"
            )
            XCTAssertTrue(
                ValidationService.isValidHostname(hostname),
                "isValidHostname should return true for: \(hostname)"
            )
        }
    }

    func testInvalidHostnames() {
        let invalidHostnames = [
            "",
            "   ",
            "-invalid",
            "invalid-",
            "invalid..com",
            ".invalid",
            "invalid.",
            "inv alid.com",
            "invalid_hostname", // underscore not allowed in hostnames
            String(repeating: "a", count: 64) + ".com", // label too long
            String(repeating: "a.", count: 130) // FQDN too long
        ]

        for hostname in invalidHostnames {
            XCTAssertThrowsError(
                try ValidationService.validateHostname(hostname),
                "Should reject invalid hostname: \(hostname)"
            )
            XCTAssertFalse(
                ValidationService.isValidHostname(hostname),
                "isValidHostname should return false for: \(hostname)"
            )
        }
    }

    // MARK: - Entry Validation Tests

    func testValidEntry() throws {
        let hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com"]
        )
        XCTAssertNoThrow(try ValidationService.validateEntry(entry, in: hostsFile))
    }

    func testEntryWithInvalidIP() {
        let hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "invalid-ip",
            hostnames: ["dev.example.com"]
        )
        XCTAssertThrowsError(try ValidationService.validateEntry(entry, in: hostsFile)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testEntryWithNoHostnames() {
        let hostsFile = HostsFile()
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: []
        )
        XCTAssertThrowsError(try ValidationService.validateEntry(entry, in: hostsFile)) { error in
            XCTAssertTrue(error is ValidationError)
        }
    }

    func testEntryWithDuplicateHostname() {
        var hostsFile = HostsFile()
        let existingEntry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: ["dev.example.com"]
        )

        hostsFile.upsert(existingEntry)

        let newEntry = HostEntry(
            ipAddress: "192.168.1.101",
            hostnames: ["dev.example.com"] // duplicate!
        )

        XCTAssertThrowsError(try ValidationService.validateEntry(newEntry, in: hostsFile)) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError")
                return
            }
            if case .duplicateEntry = validationError {
                // Success
            } else {
                XCTFail("Expected duplicateEntry error")
            }
        }
    }

    func testEntryWithTooManyHostnames() {
        let hostsFile = HostsFile()
        let tooManyHostnames = (1...30).map { "host\($0).example.com" }
        let entry = HostEntry(
            ipAddress: "192.168.1.100",
            hostnames: tooManyHostnames
        )

        XCTAssertThrowsError(try ValidationService.validateEntry(entry, in: hostsFile)) { error in
            guard let validationError = error as? ValidationError else {
                XCTFail("Expected ValidationError")
                return
            }
            if case .tooManyHostnames = validationError {
                // Success
            } else {
                XCTFail("Expected tooManyHostnames error")
            }
        }
    }
}
