//
//  HelperService.swift
//  HostsManagerHelper
//
//  Created on February 9, 2026.
//

import Foundation

/// Implementation of the privileged helper service
class HelperService: NSObject, HelperProtocol {
    private let hostsFilePath = AppConstants.hostsFilePath
    private let backupFilePath = AppConstants.backupFilePath
    private let fileManager = FileManager.default

    // MARK: - HelperProtocol Implementation

    func readHostsFile(completion: @escaping (Data?, Error?) -> Void) {
        AppLogger.helper.info("Reading hosts file from \(self.hostsFilePath)")

        do {
            let url = URL(fileURLWithPath: hostsFilePath)
            let data = try Data(contentsOf: url)

            AppLogger.helper.info("Successfully read \(data.count) bytes from hosts file")
            completion(data, nil)
        } catch {
            AppLogger.helper.error("Failed to read hosts file", error: error)
            completion(nil, HelperError.fileReadError)
        }
    }

    func writeHostsFile(content: Data, completion: @escaping (Bool, Error?) -> Void) {
        AppLogger.helper.info("Writing \(content.count) bytes to hosts file")

        do {
            // Create backup first
            try createBackup()

            // Write new content atomically
            let url = URL(fileURLWithPath: hostsFilePath)
            try content.write(to: url, options: .atomic)

            // Set proper permissions (644)
            try fileManager.setAttributes(
                [.posixPermissions: 0o644],
                ofItemAtPath: hostsFilePath
            )

            // Flush DNS cache
            flushDNSCache()

            AppLogger.helper.info("Successfully wrote hosts file")
            completion(true, nil)
        } catch {
            AppLogger.helper.error("Failed to write hosts file", error: error)
            completion(false, HelperError.fileWriteError)
        }
    }

    func backupHostsFile(completion: @escaping (Bool, Error?) -> Void) {
        AppLogger.helper.info("Creating backup of hosts file")

        do {
            try createBackup()
            AppLogger.helper.info("Successfully created backup")
            completion(true, nil)
        } catch {
            AppLogger.helper.error("Failed to create backup", error: error)
            completion(false, HelperError.backupFailed)
        }
    }

    func restoreHostsFile(completion: @escaping (Bool, Error?) -> Void) {
        AppLogger.helper.info("Restoring hosts file from backup")

        do {
            guard fileManager.fileExists(atPath: backupFilePath) else {
                throw HelperError.restoreFailed
            }

            // Copy backup to hosts file
            if fileManager.fileExists(atPath: hostsFilePath) {
                try fileManager.removeItem(atPath: hostsFilePath)
            }

            try fileManager.copyItem(atPath: backupFilePath, toPath: hostsFilePath)

            // Set proper permissions
            try fileManager.setAttributes(
                [.posixPermissions: 0o644],
                ofItemAtPath: hostsFilePath
            )

            // Flush DNS cache
            flushDNSCache()

            AppLogger.helper.info("Successfully restored from backup")
            completion(true, nil)
        } catch {
            AppLogger.helper.error("Failed to restore from backup", error: error)
            completion(false, HelperError.restoreFailed)
        }
    }

    func getVersion(completion: @escaping (String) -> Void) {
        completion(AppConstants.appVersion)
    }

    func ping(completion: @escaping (Bool) -> Void) {
        AppLogger.helper.info("Received ping")
        completion(true)
    }

    // MARK: - Private Helpers

    private func createBackup() throws {
        guard fileManager.fileExists(atPath: hostsFilePath) else {
            throw HelperError.fileReadError
        }

        // Remove old backup if it exists
        if fileManager.fileExists(atPath: backupFilePath) {
            try fileManager.removeItem(atPath: backupFilePath)
        }

        // Create new backup
        try fileManager.copyItem(atPath: hostsFilePath, toPath: backupFilePath)

        AppLogger.helper.info("Created backup at \(self.backupFilePath)")
    }

    private func flushDNSCache() {
        AppLogger.helper.info("Flushing DNS cache")

        let task = Process()
        task.launchPath = "/usr/bin/dscacheutil"
        task.arguments = ["-flushcache"]

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                AppLogger.helper.info("DNS cache flushed successfully")
            } else {
                AppLogger.helper.warning("DNS cache flush exited with status \(task.terminationStatus)")
            }
        } catch {
            AppLogger.helper.error("Failed to flush DNS cache", error: error)
        }

        // Also try discoveryutil for macOS 10.10+
        let discoveryTask = Process()
        discoveryTask.launchPath = "/usr/bin/discoveryutil"
        discoveryTask.arguments = ["mdnsflushcache"]

        do {
            try discoveryTask.run()
            discoveryTask.waitUntilExit()
        } catch {
            // Silently fail if discoveryutil doesn't exist
        }

        // Flush mDNSResponder for good measure
        let killTask = Process()
        killTask.launchPath = "/usr/bin/killall"
        killTask.arguments = ["-HUP", "mDNSResponder"]

        do {
            try killTask.run()
            killTask.waitUntilExit()
        } catch {
            AppLogger.helper.error("Failed to HUP mDNSResponder", error: error)
        }
    }
}

