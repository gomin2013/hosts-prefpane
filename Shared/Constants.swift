//
//  Constants.swift
//  Hosts Manager
//
//  Created on February 9, 2026.
//

import Foundation

enum AppConstants {
    // Bundle Identifiers
    static let appBundleID = "com.hostsmanager.app"
    static let extensionBundleID = "com.hostsmanager.extension"
    static let helperBundleID = "com.hostsmanager.helper"

    // File Paths
    static let hostsFilePath = "/etc/hosts"
    static let backupFilePath = "/var/tmp/hosts.backup"

    // XPC Service
    static let helperMachServiceName = "com.hostsmanager.helper"

    // App Info
    static let appVersion = "2.0.0"
    static let targetOS = "macOS Sequoia 15.0+"

    // UI Constants — Menu Bar Popover
    static let menuBarPopoverWidth: CGFloat = 800
    static let menuBarPopoverHeight: CGFloat = 580

    // Legacy window size (kept for SPM/test builds)
    static let defaultWindowWidth: CGFloat = 800
    static let defaultWindowHeight: CGFloat = 600
    static let minimumWindowWidth: CGFloat = 600
    static let minimumWindowHeight: CGFloat = 400
}

enum HostsFileConstants {
    static let defaultHeader = """
        ##
        # Host Database
        #
        # localhost is used to configure the loopback interface
        # when the system is booting.  Do not change this entry.
        ##
        """

    static let localhostIPv4 = "127.0.0.1"
    static let localhostIPv6 = "::1"
    static let broadcastHost = "255.255.255.255"

    static let reservedHostnames = [
        "localhost",
        "broadcasthost"
    ]
}
