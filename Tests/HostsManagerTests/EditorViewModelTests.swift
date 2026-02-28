//
//  EditorViewModelTests.swift
//  Hosts Manager Tests
//
//  Created on March 1, 2026.
//

import XCTest

@MainActor
final class EditorViewModelTests: XCTestCase {

    var emptyHostsFile: HostsFile!
    var populatedHostsFile: HostsFile!

    override func setUp() {
        super.setUp()
        emptyHostsFile = HostsFile()

        var file = HostsFile()
        file.upsert(HostEntry(ipAddress: "192.168.1.100", hostnames: ["existing.com"]))
        populatedHostsFile = file
    }

    // MARK: - Init (Add mode)

    func testInitAddMode() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        XCTAssertFalse(viewModel.isEditing)
        XCTAssertEqual(viewModel.title, "Add Host Entry")
        XCTAssertEqual(viewModel.ipAddress, "")
        XCTAssertEqual(viewModel.hostnamesText, "")
        XCTAssertEqual(viewModel.comment, "")
        XCTAssertTrue(viewModel.isEnabled)
    }

    // MARK: - Init (Edit mode)

    func testInitEditMode() {
        let entry = HostEntry(
            ipAddress: "10.0.0.1",
            hostnames: ["a.com", "b.com"],
            isEnabled: false,
            comment: "my comment"
        )
        let viewModel = EditorViewModel(entry: entry, hostsFile: emptyHostsFile)
        XCTAssertTrue(viewModel.isEditing)
        XCTAssertEqual(viewModel.title, "Edit Host Entry")
        XCTAssertEqual(viewModel.ipAddress, "10.0.0.1")
        XCTAssertTrue(viewModel.hostnamesText.contains("a.com"))
        XCTAssertTrue(viewModel.hostnamesText.contains("b.com"))
        XCTAssertEqual(viewModel.comment, "my comment")
        XCTAssertFalse(viewModel.isEnabled)
    }

    // MARK: - hostnames computed property

    func testHostnamesSpaceSeparated() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.hostnamesText = "a.com b.com c.com"
        XCTAssertEqual(viewModel.hostnames, ["a.com", "b.com", "c.com"])
    }

    func testHostnamesNewlineSeparated() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.hostnamesText = "a.com\nb.com\nc.com"
        XCTAssertEqual(viewModel.hostnames, ["a.com", "b.com", "c.com"])
    }

    func testHostnamesFiltersEmpty() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.hostnamesText = "  a.com   "
        XCTAssertEqual(viewModel.hostnames, ["a.com"])
    }

    // MARK: - Validation

    func testValidInputPassesValidation() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "192.168.1.1"
        viewModel.hostnamesText = "dev.example.com"
        let result = viewModel.validate()
        XCTAssertTrue(result)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
    }

    func testEmptyIPFailsValidation() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = ""
        viewModel.hostnamesText = "dev.example.com"
        let result = viewModel.validate()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.validationErrors.contains(.emptyIPAddress))
    }

    func testInvalidIPFailsValidation() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "999.999.999.999"
        viewModel.hostnamesText = "dev.example.com"
        let result = viewModel.validate()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.validationErrors.contains(.invalidIPAddress("999.999.999.999")))
    }

    func testEmptyHostnameFailsValidation() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "192.168.1.1"
        viewModel.hostnamesText = ""
        let result = viewModel.validate()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.validationErrors.contains(.emptyHostname))
    }

    func testInvalidHostnameFailsValidation() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "192.168.1.1"
        viewModel.hostnamesText = "-invalid"
        let result = viewModel.validate()
        XCTAssertFalse(result)
        XCTAssertFalse(viewModel.validationErrors.isEmpty)
    }

    func testDuplicateHostnameFailsValidation() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: populatedHostsFile)
        viewModel.ipAddress = "10.0.0.2"
        viewModel.hostnamesText = "existing.com"
        let result = viewModel.validate()
        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.validationErrors.contains(.duplicateEntry("existing.com")))
    }

    func testEditingOwnEntryDoesNotTriggerDuplicate() {
        let entry = populatedHostsFile.entries.first!
        let viewModel = EditorViewModel(entry: entry, hostsFile: populatedHostsFile)
        // Same hostname, same entry — should not be a duplicate
        viewModel.ipAddress = entry.ipAddress
        viewModel.hostnamesText = entry.hostnamesString
        let result = viewModel.validate()
        XCTAssertTrue(result)
    }

    // MARK: - createEntry()

    func testCreateEntryAddMode() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "10.10.10.10"
        viewModel.hostnamesText = "new.example.com"
        viewModel.comment = "brand new"
        viewModel.isEnabled = false

        let entry = viewModel.createEntry()
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry?.ipAddress, "10.10.10.10")
        XCTAssertEqual(entry?.hostnames, ["new.example.com"])
        XCTAssertEqual(entry?.comment, "brand new")
        XCTAssertFalse(entry?.isEnabled ?? true)
    }

    func testCreateEntryEditModePreservesID() {
        let original = HostEntry(
            ipAddress: "10.0.0.1",
            hostnames: ["original.com"],
            isEnabled: true
        )
        var file = HostsFile()
        file.upsert(original)

        let viewModel = EditorViewModel(entry: original, hostsFile: file)
        viewModel.ipAddress = "10.0.0.2"
        viewModel.hostnamesText = "updated.com"

        let updated = viewModel.createEntry()
        XCTAssertEqual(updated?.id, original.id)
        XCTAssertEqual(updated?.ipAddress, "10.0.0.2")
        XCTAssertEqual(updated?.hostnames, ["updated.com"])
        XCTAssertGreaterThanOrEqual(updated!.modifiedAt, original.modifiedAt)
    }

    func testCreateEntryReturnsNilWhenInvalid() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = ""
        viewModel.hostnamesText = ""
        let entry = viewModel.createEntry()
        XCTAssertNil(entry)
        XCTAssertTrue(viewModel.showingValidationAlert)
    }

    func testCreateEntryTrimsIPWhitespace() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "  192.168.1.1  "
        viewModel.hostnamesText = "dev.com"
        let entry = viewModel.createEntry()
        XCTAssertEqual(entry?.ipAddress, "192.168.1.1")
    }

    func testEmptyCommentBecomesNil() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = "192.168.1.1"
        viewModel.hostnamesText = "dev.com"
        viewModel.comment = ""
        let entry = viewModel.createEntry()
        XCTAssertNil(entry?.comment)
    }

    // MARK: - validationErrorMessage

    func testValidationErrorMessage() {
        let viewModel = EditorViewModel(entry: nil, hostsFile: emptyHostsFile)
        viewModel.ipAddress = ""
        viewModel.hostnamesText = ""
        viewModel.validate()
        XCTAssertFalse(viewModel.validationErrorMessage.isEmpty)
    }
}
