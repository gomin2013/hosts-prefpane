//
//  Logger.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation
import os.log

/// Centralized logging utility for the Hosts Manager app
enum AppLogger {
    private static let subsystem = AppConstants.appBundleID

    static let general = Logger(subsystem: subsystem, category: "general")
    static let fileIO = Logger(subsystem: subsystem, category: "file-io")
    static let xpc = Logger(subsystem: subsystem, category: "xpc")
    static let validation = Logger(subsystem: subsystem, category: "validation")
    static let userInterface = Logger(subsystem: subsystem, category: "ui")
    static let helper = Logger(subsystem: subsystem, category: "helper")
}

extension Logger {
    /// Log a debug message with context
    func debugLog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = file.components(separatedBy: "/").last ?? file
        self.log(level: .debug, "[\(fileName):\(line)] \(function) - \(message)")
    }

    /// Log an info message with context
    func infoLog(_ message: String, file: String = #file, function: String = #function) {
        self.log(level: .info, "[\(function)] \(message)")
    }

    /// Log a warning with context
    func warningLog(_ message: String, file: String = #file, function: String = #function) {
        self.log(level: .error, "⚠️ [\(function)] \(message)")
    }

    /// Log an error with context
    func errorLog(_ message: String, error: Error? = nil, file: String = #file, function: String = #function) {
        if let error = error {
            self.log(level: .error, "❌ [\(function)] \(message) - Error: \(error.localizedDescription)")
        } else {
            self.log(level: .error, "❌ [\(function)] \(message)")
        }
    }
}
