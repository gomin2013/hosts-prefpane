//
}
    }
        }
            }
                XCTFail("Expected tooManyHostnames error")
            } else {
                // Success
            if case .tooManyHostnames = validationError {
            }
                return
                XCTFail("Expected ValidationError")
            guard let validationError = error as? ValidationError else {
        XCTAssertThrowsError(try ValidationService.validateEntry(entry, in: hostsFile)) { error in

        )
            hostnames: tooManyHostnames
            ipAddress: "192.168.1.100",
        let entry = HostEntry(
        let tooManyHostnames = (1...30).map { "host\($0).example.com" }
        let hostsFile = HostsFile()
    func testEntryWithTooManyHostnames() {

    }
        }
            }
                XCTFail("Expected duplicateEntry error")
            } else {
                // Success
            if case .duplicateEntry = validationError {
            }
                return
                XCTFail("Expected ValidationError")
            guard let validationError = error as? ValidationError else {
        XCTAssertThrowsError(try ValidationService.validateEntry(newEntry, in: hostsFile)) { error in

        )
            hostnames: ["dev.example.com"] // duplicate!
            ipAddress: "192.168.1.101",
        let newEntry = HostEntry(

        hostsFile.upsert(existingEntry)
        )
            hostnames: ["dev.example.com"]
            ipAddress: "192.168.1.100",
        let existingEntry = HostEntry(
        var hostsFile = HostsFile()
    func testEntryWithDuplicateHostname() {

    }
        }
            XCTAssertTrue(error is ValidationError)
        XCTAssertThrowsError(try ValidationService.validateEntry(entry, in: hostsFile)) { error in

        )
            hostnames: []
            ipAddress: "192.168.1.100",
        let entry = HostEntry(
        let hostsFile = HostsFile()
    func testEntryWithNoHostnames() {

    }
        }
            XCTAssertTrue(error is ValidationError)
        XCTAssertThrowsError(try ValidationService.validateEntry(entry, in: hostsFile)) { error in

        )
            hostnames: ["dev.example.com"]
            ipAddress: "invalid-ip",
        let entry = HostEntry(
        let hostsFile = HostsFile()
    func testEntryWithInvalidIP() {

    }
        XCTAssertNoThrow(try ValidationService.validateEntry(entry, in: hostsFile))

        )
            hostnames: ["dev.example.com"]
            ipAddress: "192.168.1.100",
        let entry = HostEntry(
        let hostsFile = HostsFile()
    func testValidEntry() throws {

    // MARK: - Entry Validation Tests

    }
        }
            XCTAssertFalse(ValidationService.isValidHostname(hostname), "isValidHostname should return false for: \(hostname)")
            XCTAssertThrowsError(try ValidationService.validateHostname(hostname), "Should reject invalid hostname: \(hostname)")
        for hostname in invalidHostnames {

        ]
            String(repeating: "a.", count: 130) // FQDN too long
            String(repeating: "a", count: 64) + ".com", // label too long
            "invalid_hostname", // underscore not allowed in hostnames
            "inv alid.com",
            "invalid.",
            ".invalid",
            "invalid..com",
            "invalid-",
            "-invalid",
            "   ",
            "",
        let invalidHostnames = [
    func testInvalidHostnames() {

    }
        }
            XCTAssertTrue(ValidationService.isValidHostname(hostname), "isValidHostname should return true for: \(hostname)")
            XCTAssertNoThrow(try ValidationService.validateHostname(hostname), "Should accept valid hostname: \(hostname)")
        for hostname in validHostnames {

        ]
            "xn--e1afmkfd.xn--p1ai" // internationalized domain
            "a.b.c.d.e.f",
            "server-123",
            "my-server",
            "sub.example.com",
            "example.com",
            "localhost",
        let validHostnames = [
    func testValidHostnames() throws {

    // MARK: - Hostname Validation Tests

    }
        }
            XCTAssertFalse(ValidationService.isValidIPAddress(ip), "isValidIPAddress should return false for: \(ip)")
            XCTAssertThrowsError(try ValidationService.validateIPAddress(ip), "Should reject invalid IP: \(ip)")
        for ip in invalidIPs {

        ]
            "192.168.1.a"
            "   ",
            "",
            "not-an-ip",
            "192.168.1.1.1",
            "192.168.1",
            "256.1.1.1",
        let invalidIPs = [
    func testInvalidIPAddresses() {

    }
        }
            XCTAssertTrue(ValidationService.isValidIPAddress(ip), "isValidIPAddress should return true for: \(ip)")
            XCTAssertNoThrow(try ValidationService.validateIPAddress(ip), "Should accept valid IPv6: \(ip)")
        for ip in validIPs {

        ]
            "::"
            "2001:db8:85a3::8a2e:370:7334",
            "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
            "fe80::1",
            "::1",
        let validIPs = [
    func testValidIPv6Addresses() throws {

    }
        }
            XCTAssertTrue(ValidationService.isValidIPAddress(ip), "isValidIPAddress should return true for: \(ip)")
            XCTAssertNoThrow(try ValidationService.validateIPAddress(ip), "Should accept valid IPv4: \(ip)")
        for ip in validIPs {

        ]
            "0.0.0.0"
            "255.255.255.255",
            "10.0.0.1",
            "192.168.1.1",
            "127.0.0.1",
        let validIPs = [
    func testValidIPv4Addresses() throws {

    // MARK: - IP Address Validation Tests

final class ValidationTests: XCTestCase {

@testable import HostsManagerExtension
import XCTest

//
//  Created on February 9, 2026.
//
//  Hosts Manager Tests
//  ValidationTests.swift

