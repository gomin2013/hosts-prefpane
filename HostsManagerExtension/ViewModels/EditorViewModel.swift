//
//  EditorViewModel.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation
import SwiftUI

/// View model for the entry editor
@MainActor
class EditorViewModel: ObservableObject {
    @Published var ipAddress: String
    @Published var hostnamesText: String
    @Published var comment: String
    @Published var isEnabled: Bool

    @Published var validationErrors: [ValidationError] = []
    @Published var showingValidationAlert = false

    private let originalEntry: HostEntry?
    private let hostsFile: HostsFile

    init(entry: HostEntry?, hostsFile: HostsFile) {
        self.originalEntry = entry
        self.hostsFile = hostsFile

        if let entry = entry {
            self.ipAddress = entry.ipAddress
            self.hostnamesText = entry.hostnamesString
            self.comment = entry.comment ?? ""
            self.isEnabled = entry.isEnabled
        } else {
            self.ipAddress = ""
            self.hostnamesText = ""
            self.comment = ""
            self.isEnabled = true
        }
    }

    var isEditing: Bool {
        originalEntry != nil
    }

    var title: String {
        isEditing ? "Edit Host Entry" : "Add Host Entry"
    }

    var hostnames: [String] {
        hostnamesText
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var isValid: Bool {
        validate()
        return validationErrors.isEmpty
    }

    @discardableResult
    func validate() -> Bool {
        validationErrors.removeAll()

        // Validate IP address
        do {
            try ValidationService.validateIPAddress(ipAddress)
        } catch let error as ValidationError {
            validationErrors.append(error)
        } catch {}

        // Validate hostnames
        if hostnames.isEmpty {
            validationErrors.append(.emptyHostname)
        } else {
            for hostname in hostnames {
                do {
                    try ValidationService.validateHostname(hostname)

                    // Check for duplicates in the file
                    if hostsFile.contains(hostname: hostname, excluding: originalEntry?.id) {
                        validationErrors.append(.duplicateEntry(hostname))
                    }
                } catch let error as ValidationError {
                    if !validationErrors.contains(error) {
                        validationErrors.append(error)
                    }
                } catch {}
            }
        }

        return validationErrors.isEmpty
    }

    func createEntry() -> HostEntry? {
        guard isValid else {
            showingValidationAlert = true
            return nil
        }

        if let original = originalEntry {
            return original.updating { entry in
                entry.ipAddress = ipAddress.trimmingCharacters(in: .whitespaces)
                entry.hostnames = hostnames
                entry.comment = comment.isEmpty ? nil : comment
                entry.isEnabled = isEnabled
            }
        } else {
            return HostEntry(
                ipAddress: ipAddress.trimmingCharacters(in: .whitespaces),
                hostnames: hostnames,
                isEnabled: isEnabled,
                comment: comment.isEmpty ? nil : comment
            )
        }
    }

    var validationErrorMessage: String {
        validationErrors.map { $0.localizedDescription }.joined(separator: "\n")
    }
}
