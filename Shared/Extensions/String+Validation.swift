//
//  String+Validation.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

extension String {
    /// Check if the string is empty or contains only whitespace
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Remove all whitespace characters
    var removingWhitespace: String {
        components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined()
    }

    /// Split into lines
    var lines: [String] {
        components(separatedBy: .newlines)
    }

    /// Check if string contains only ASCII characters
    var isASCII: Bool {
        allSatisfy { $0.isASCII }
    }
}
