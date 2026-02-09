# Claude.md - hosts-prefpane Modernization Plan
## Project: macOS Sequoia SwiftUI Migration

**Version:** 2.0.0  
**Target OS:** macOS Sequoia (15.0+)  
**Date:** February 9, 2026  
**Branch:** feature-sequoia  
**Status:** Planning & Implementation Phase

---

## 📋 Executive Summary

This document outlines the complete modernization plan for **hosts-prefpane**, transforming it from a legacy System Preferences `.prefPane` bundle into a modern macOS Sequoia **Settings Extension** built entirely with SwiftUI.

### What We're Building
A native macOS Sequoia Settings extension that allows users to:
- View, add, edit, and delete entries in `/etc/hosts` file
- Enable/disable host entries without deletion
- Import/export hosts configurations
- Validate IP addresses and hostnames
- Apply changes with proper privilege escalation

### Why This Migration?
1. **Deprecation**: Legacy `.prefPane` bundles are deprecated in macOS Sequoia
2. **Modern UI**: SwiftUI provides native appearance and better maintainability
3. **Settings Integration**: Native integration with macOS Settings app
4. **Security**: Modern privilege escalation with `SMAppService`
5. **User Experience**: Consistent with macOS Sequoia design language

---

## 🏗️ Architecture Overview

### From Legacy to Modern

#### **Before (Legacy Architecture)**
```
┌─────────────────────────────┐
│  System Preferences.app     │
│  ┌───────────────────────┐  │
│  │  hosts.prefPane       │  │
│  │  (NSPreferencePane)   │  │
│  │  - Cocoa UI (XIB/NIB) │  │
│  │  - Authorization APIs │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

#### **After (Modern Architecture)**
```
┌──────────────────────────────────────────┐
│  Settings.app (macOS Sequoia)            │
│  ┌────────────────────────────────────┐  │
│  │  Hosts Manager Extension           │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │  SwiftUI Views               │  │  │
│  │  │  - HostsListView             │  │  │
│  │  │  - HostEntryEditor           │  │  │
│  │  │  - SettingsView              │  │  │
│  │  └──────────────────────────────┘  │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │  ViewModel Layer             │  │  │
│  │  │  - HostsManager              │  │  │
│  │  │  - FileIOService             │  │  │
│  │  └──────────────────────────────┘  │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
           ↕ XPC Communication
┌──────────────────────────────────────────┐
│  Privileged Helper Tool                  │
│  - Read/Write /etc/hosts                 │
│  - Managed by SMAppService               │
└──────────────────────────────────────────┘
```

---

## 🎯 Technical Requirements

### Development Environment
- **Xcode:** 15.0 or later
- **Swift:** 5.9+
- **Minimum Deployment:** macOS Sequoia 15.0
- **Testing Device:** macOS Sequoia or later

### Key Technologies
1. **SwiftUI** - All UI components
2. **Combine** - Reactive data flow
3. **SettingsKit** - Settings extension framework
4. **SMAppService** - Modern privilege escalation
5. **XPC** - Inter-process communication
6. **Swift Concurrency** - async/await pattern

### Required Entitlements
```xml
<!-- Settings Extension Entitlement -->
com.apple.developer.settings-extension

<!-- Helper Tool -->
com.apple.security.app-sandbox (NO for helper)
com.apple.application-identifier

<!-- File Access -->
com.apple.security.files.user-selected.read-write
com.apple.security.temporary-exception.files.absolute-path.read-write
  /etc/hosts (via privileged helper)
```

---

## 📦 Project Structure

```
hosts-prefpane/
├── Claude.md                          # This document
├── README.md                          # Project readme
├── .gitignore                         # Git ignore rules
│
├── HostsManager.xcodeproj/            # Xcode project
│
├── HostsManagerApp/                   # Main application
│   ├── HostsManagerApp.swift          # @main App entry
│   ├── Info.plist
│   ├── Assets.xcassets/
│   └── Resources/
│
├── HostsManagerExtension/             # Settings Extension target
│   ├── HostsManagerExtension.swift    # Extension entry point
│   ├── Views/
│   │   ├── HostsListView.swift        # Main list view
│   │   ├── HostEntryEditorView.swift  # Add/Edit entry
│   │   ├── HostEntryRow.swift         # List row component
│   │   ├── ImportExportView.swift     # Import/Export UI
│   │   └── AboutView.swift            # About section
│   ├── ViewModels/
│   │   ├── HostsViewModel.swift       # Main view model
│   │   └── EditorViewModel.swift      # Editor logic
│   ├── Models/
│   │   ├── HostEntry.swift            # Host entry model
│   │   ├── HostsFile.swift            # Hosts file parser
│   │   └── ValidationError.swift      # Validation types
│   ├── Services/
│   │   ├── HostsFileService.swift     # File I/O coordinator
│   │   ├── XPCService.swift           # XPC client
│   │   └── ValidationService.swift    # IP/hostname validation
│   ├── Info.plist
│   └── Assets.xcassets/
│
├── HostsManagerHelper/                # Privileged helper tool
│   ├── main.swift                     # Helper entry point
│   ├── HelperProtocol.swift           # XPC protocol
│   ├── HelperService.swift            # Helper implementation
│   ├── HostsFileManager.swift         # Root file operations
│   ├── Info.plist
│   └── Launchd.plist                  # SMAppService config
│
├── Shared/                            # Shared code
│   ├── Constants.swift                # App constants
│   ├── Extensions/
│   │   ├── String+Validation.swift
│   │   └── View+Extensions.swift
│   └── Utilities/
│       ├── Logger.swift
│       └── ErrorHandling.swift
│
└── Tests/                             # Unit tests
    ├── HostsManagerTests/
    ├── ValidationTests/
    └── ParserTests/
```

---

## 🚀 Implementation Phases

### Phase 1: Project Setup & Infrastructure (Week 1)

#### 1.1 Create Xcode Project
- [ ] Create new macOS App project with SwiftUI
- [ ] Configure minimum deployment target (macOS 15.0)
- [ ] Set up proper bundle identifiers
  - App: `com.yourcompany.hostsmanager`
  - Extension: `com.yourcompany.hostsmanager.extension`
  - Helper: `com.yourcompany.hostsmanager.helper`

#### 1.2 Add Settings Extension Target
```swift
// HostsManagerExtension.swift
import SwiftUI
import SettingsKit

@main
struct HostsManagerExtension: SettingsExtension {
    var body: some SettingsExtensionScene {
        SettingsScene {
            HostsListView()
        }
    }
}
```

#### 1.3 Configure Info.plist
```xml
<!-- Extension Info.plist -->
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.Settings.extension</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).HostsManagerExtension</string>
</dict>
<key>SettingsExtension</key>
<dict>
    <key>Title</key>
    <string>Hosts Manager</string>
    <key>Category</key>
    <string>General</string>
    <key>Icon</key>
    <string>network</string>
</dict>
```

#### 1.4 Set Up Git & Version Control
- [ ] Create .gitignore for Xcode
- [ ] Initialize proper branching strategy
- [ ] Set up commit message conventions

---

### Phase 2: Data Models & Business Logic (Week 1-2)

#### 2.1 Host Entry Model
```swift
// Models/HostEntry.swift
import Foundation

struct HostEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var ipAddress: String
    var hostnames: [String]
    var isEnabled: Bool
    var comment: String?
    var createdAt: Date
    var modifiedAt: Date
    
    init(
        id: UUID = UUID(),
        ipAddress: String,
        hostnames: [String],
        isEnabled: Bool = true,
        comment: String? = nil
    ) {
        self.id = id
        self.ipAddress = ipAddress
        self.hostnames = hostnames
        self.isEnabled = isEnabled
        self.comment = comment
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    var primaryHostname: String {
        hostnames.first ?? "Unknown"
    }
    
    var hostsFileFormat: String {
        let prefix = isEnabled ? "" : "# "
        let hostnamesString = hostnames.joined(separator: " ")
        let commentSuffix = comment.map { " # \($0)" } ?? ""
        return "\(prefix)\(ipAddress) \(hostnamesString)\(commentSuffix)"
    }
}
```

#### 2.2 Hosts File Parser
```swift
// Models/HostsFile.swift
import Foundation

struct HostsFile {
    var entries: [HostEntry]
    var rawHeader: String // Preserve header comments
    
    static func parse(content: String) throws -> HostsFile {
        // Parse logic:
        // 1. Extract header comments
        // 2. Parse each line
        // 3. Handle commented lines (disabled entries)
        // 4. Validate IP addresses and hostnames
        // 5. Return HostsFile with entries
    }
    
    func serialize() -> String {
        // Convert entries back to /etc/hosts format
        // Preserve header, maintain order
    }
}
```

#### 2.3 Validation Service
```swift
// Services/ValidationService.swift
import Foundation
import Network

enum ValidationError: LocalizedError {
    case invalidIPAddress(String)
    case invalidHostname(String)
    case duplicateEntry(String)
    case emptyHostname
    
    var errorDescription: String? {
        switch self {
        case .invalidIPAddress(let ip):
            return "Invalid IP address: \(ip)"
        case .invalidHostname(let host):
            return "Invalid hostname: \(host)"
        case .duplicateEntry(let host):
            return "Duplicate entry: \(host)"
        case .emptyHostname:
            return "Hostname cannot be empty"
        }
    }
}

class ValidationService {
    static func validateIPAddress(_ ip: String) throws {
        // Validate IPv4 and IPv6
        guard IPv4Address(ip) != nil || IPv6Address(ip) != nil else {
            throw ValidationError.invalidIPAddress(ip)
        }
    }
    
    static func validateHostname(_ hostname: String) throws {
        // RFC 1123 hostname validation
        let pattern = "^(?!-)[A-Za-z0-9-]{1,63}(?<!-)(\\.(?!-)[A-Za-z0-9-]{1,63}(?<!-))*$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(hostname.startIndex..., in: hostname)
        
        guard regex.firstMatch(in: hostname, range: range) != nil else {
            throw ValidationError.invalidHostname(hostname)
        }
    }
}
```

---

### Phase 3: Privileged Helper Tool (Week 2-3)

#### 3.1 XPC Protocol Definition
```swift
// Shared/HelperProtocol.swift
import Foundation

@objc protocol HelperProtocol {
    func readHostsFile(completion: @escaping (Data?, Error?) -> Void)
    func writeHostsFile(content: Data, completion: @escaping (Bool, Error?) -> Void)
    func backupHostsFile(completion: @escaping (Bool, Error?) -> Void)
    func restoreHostsFile(completion: @escaping (Bool, Error?) -> Void)
    func getVersion(completion: @escaping (String) -> Void)
}
```

#### 3.2 Helper Tool Implementation
```swift
// HostsManagerHelper/HelperService.swift
import Foundation

class HelperService: NSObject, HelperProtocol {
    private let hostsFilePath = "/etc/hosts"
    private let backupPath = "/var/tmp/hosts.backup"
    
    func readHostsFile(completion: @escaping (Data?, Error?) -> Void) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: hostsFilePath))
            completion(data, nil)
        } catch {
            completion(nil, error)
        }
    }
    
    func writeHostsFile(content: Data, completion: @escaping (Bool, Error?) -> Void) {
        do {
            // Create backup first
            try? FileManager.default.copyItem(
                atPath: hostsFilePath,
                toPath: backupPath
            )
            
            // Write new content
            try content.write(to: URL(fileURLWithPath: hostsFilePath), options: .atomic)
            
            // Flush DNS cache
            flushDNSCache()
            
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    private func flushDNSCache() {
        let task = Process()
        task.launchPath = "/usr/bin/dscacheutil"
        task.arguments = ["-flushcache"]
        try? task.run()
    }
}
```

#### 3.3 SMAppService Configuration
```swift
// HostsManagerApp/HelperInstaller.swift
import ServiceManagement

class HelperInstaller {
    static let shared = HelperInstaller()
    
    private let helperIdentifier = "com.yourcompany.hostsmanager.helper"
    
    func installHelper() async throws {
        let service = SMAppService.daemon(plistName: "com.yourcompany.hostsmanager.helper.plist")
        
        try await service.register()
        
        // Verify installation
        guard service.status == .enabled else {
            throw HelperError.installationFailed
        }
    }
    
    func checkHelperStatus() -> SMAppService.Status {
        let service = SMAppService.daemon(plistName: "com.yourcompany.hostsmanager.helper.plist")
        return service.status
    }
}
```

#### 3.4 Launchd Configuration
```xml
<!-- HostsManagerHelper/Launchd.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yourcompany.hostsmanager.helper</string>
    <key>MachServices</key>
    <dict>
        <key>com.yourcompany.hostsmanager.helper</key>
        <true/>
    </dict>
    <key>Program</key>
    <string>/Library/PrivilegedHelperTools/com.yourcompany.hostsmanager.helper</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Library/PrivilegedHelperTools/com.yourcompany.hostsmanager.helper</string>
    </array>
</dict>
</plist>
```

---

### Phase 4: SwiftUI Views (Week 3-4)

#### 4.1 Main Hosts List View
```swift
// Views/HostsListView.swift
import SwiftUI

struct HostsListView: View {
    @StateObject private var viewModel = HostsViewModel()
    @State private var showingAddEntry = false
    @State private var selectedEntry: HostEntry?
    @State private var searchText = ""
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - List of entries
            List(selection: $selectedEntry) {
                ForEach(filteredEntries) { entry in
                    HostEntryRow(entry: entry)
                        .tag(entry)
                        .contextMenu {
                            Button("Edit") {
                                selectedEntry = entry
                            }
                            Button("Duplicate") {
                                viewModel.duplicate(entry)
                            }
                            Divider()
                            Button(entry.isEnabled ? "Disable" : "Enable") {
                                viewModel.toggleEnabled(entry)
                            }
                            Button("Delete", role: .destructive) {
                                viewModel.delete(entry)
                            }
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search hosts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddEntry = true }) {
                        Label("Add Entry", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Button("Import...") {
                            viewModel.showImportDialog()
                        }
                        Button("Export...") {
                            viewModel.showExportDialog()
                        }
                        Divider()
                        Button("Refresh") {
                            Task { await viewModel.reload() }
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
        } detail: {
            // Detail view - Entry editor or empty state
            if let entry = selectedEntry {
                HostEntryEditorView(entry: entry) { updatedEntry in
                    viewModel.update(updatedEntry)
                }
            } else {
                EmptyDetailView()
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            HostEntryEditorView(entry: nil) { newEntry in
                viewModel.add(newEntry)
            }
        }
        .alert(item: $viewModel.error) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            await viewModel.loadInitial()
        }
    }
    
    private var filteredEntries: [HostEntry] {
        if searchText.isEmpty {
            return viewModel.entries
        }
        return viewModel.entries.filter { entry in
            entry.ipAddress.localizedCaseInsensitiveContains(searchText) ||
            entry.hostnames.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
```

#### 4.2 Entry Row Component
```swift
// Views/HostEntryRow.swift
import SwiftUI

struct HostEntryRow: View {
    let entry: HostEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(entry.isEnabled ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.primaryHostname)
                    .font(.headline)
                    .foregroundColor(entry.isEnabled ? .primary : .secondary)
                
                Text(entry.ipAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if entry.hostnames.count > 1 {
                    Text("\(entry.hostnames.count - 1) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let comment = entry.comment {
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
        .opacity(entry.isEnabled ? 1.0 : 0.6)
    }
}
```

#### 4.3 Entry Editor View
```swift
// Views/HostEntryEditorView.swift
import SwiftUI

struct HostEntryEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditorViewModel
    
    let onSave: (HostEntry) -> Void
    
    init(entry: HostEntry?, onSave: @escaping (HostEntry) -> Void) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(entry: entry))
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            Section("IP Address") {
                TextField("e.g., 127.0.0.1", text: $viewModel.ipAddress)
                    .textFieldStyle(.roundedBorder)
                
                if let error = viewModel.ipAddressError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Section("Hostnames") {
                ForEach(viewModel.hostnames.indices, id: \.self) { index in
                    HStack {
                        TextField("e.g., localhost", text: $viewModel.hostnames[index])
                            .textFieldStyle(.roundedBorder)
                        
                        if viewModel.hostnames.count > 1 {
                            Button(action: { viewModel.removeHostname(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Button(action: viewModel.addHostname) {
                    Label("Add Hostname", systemImage: "plus.circle")
                }
            }
            
            Section("Options") {
                Toggle("Enabled", isOn: $viewModel.isEnabled)
                
                TextField("Comment (optional)", text: $viewModel.comment)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(viewModel.isNewEntry ? "Add Entry" : "Edit Entry")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let entry = viewModel.save() {
                        onSave(entry)
                        dismiss()
                    }
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}
```

---

### Phase 5: View Models & Services (Week 4-5)

#### 5.1 Main View Model
```swift
// ViewModels/HostsViewModel.swift
import SwiftUI
import Combine

@MainActor
class HostsViewModel: ObservableObject {
    @Published var entries: [HostEntry] = []
    @Published var isLoading = false
    @Published var error: IdentifiableError?
    
    private let fileService: HostsFileService
    private var cancellables = Set<AnyCancellable>()
    
    init(fileService: HostsFileService = .shared) {
        self.fileService = fileService
    }
    
    func loadInitial() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let hostsFile = try await fileService.readHostsFile()
            entries = hostsFile.entries
        } catch {
            self.error = IdentifiableError(error: error)
        }
    }
    
    func add(_ entry: HostEntry) {
        entries.append(entry)
        Task { await saveChanges() }
    }
    
    func update(_ entry: HostEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            Task { await saveChanges() }
        }
    }
    
    func delete(_ entry: HostEntry) {
        entries.removeAll { $0.id == entry.id }
        Task { await saveChanges() }
    }
    
    func toggleEnabled(_ entry: HostEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isEnabled.toggle()
            Task { await saveChanges() }
        }
    }
    
    func duplicate(_ entry: HostEntry) {
        var newEntry = entry
        newEntry.id = UUID()
        newEntry.createdAt = Date()
        entries.append(newEntry)
        Task { await saveChanges() }
    }
    
    private func saveChanges() async {
        do {
            let hostsFile = HostsFile(entries: entries, rawHeader: "")
            try await fileService.writeHostsFile(hostsFile)
        } catch {
            self.error = IdentifiableError(error: error)
        }
    }
    
    func reload() async {
        await loadInitial()
    }
}
```

#### 5.2 File I/O Service
```swift
// Services/HostsFileService.swift
import Foundation

actor HostsFileService {
    static let shared = HostsFileService()
    
    private let xpcService: XPCService
    
    init(xpcService: XPCService = .shared) {
        self.xpcService = xpcService
    }
    
    func readHostsFile() async throws -> HostsFile {
        let data = try await xpcService.readHostsFile()
        let content = String(data: data, encoding: .utf8) ?? ""
        return try HostsFile.parse(content: content)
    }
    
    func writeHostsFile(_ hostsFile: HostsFile) async throws {
        let content = hostsFile.serialize()
        let data = content.data(using: .utf8)!
        try await xpcService.writeHostsFile(data)
    }
    
    func createBackup() async throws {
        try await xpcService.backupHostsFile()
    }
    
    func restoreBackup() async throws {
        try await xpcService.restoreHostsFile()
    }
}
```

#### 5.3 XPC Client Service
```swift
// Services/XPCService.swift
import Foundation

actor XPCService {
    static let shared = XPCService()
    
    private var connection: NSXPCConnection?
    private let helperIdentifier = "com.yourcompany.hostsmanager.helper"
    
    init() {
        setupConnection()
    }
    
    private func setupConnection() {
        connection = NSXPCConnection(machServiceName: helperIdentifier)
        connection?.remoteObjectInterface = NSXPCInterface(with: HelperProtocol.self)
        connection?.resume()
    }
    
    private func getHelper() throws -> HelperProtocol {
        guard let helper = connection?.remoteObjectProxyWithErrorHandler({ error in
            print("XPC Error: \(error)")
        }) as? HelperProtocol else {
            throw XPCError.connectionFailed
        }
        return helper
    }
    
    func readHostsFile() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let helper = try getHelper()
                helper.readHostsFile { data, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let data = data {
                        continuation.resume(returning: data)
                    } else {
                        continuation.resume(throwing: XPCError.noData)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func writeHostsFile(_ data: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let helper = try getHelper()
                helper.writeHostsFile(content: data) { success, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if success {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: XPCError.writeFailed)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
```

---

### Phase 6: Testing & Validation (Week 5-6)

#### 6.1 Unit Tests
```swift
// Tests/ValidationTests.swift
import XCTest
@testable import HostsManager

class ValidationTests: XCTestCase {
    func testValidIPv4Address() throws {
        XCTAssertNoThrow(try ValidationService.validateIPAddress("127.0.0.1"))
        XCTAssertNoThrow(try ValidationService.validateIPAddress("192.168.1.1"))
    }
    
    func testInvalidIPv4Address() {
        XCTAssertThrowsError(try ValidationService.validateIPAddress("256.1.1.1"))
        XCTAssertThrowsError(try ValidationService.validateIPAddress("invalid"))
    }
    
    func testValidHostname() throws {
        XCTAssertNoThrow(try ValidationService.validateHostname("localhost"))
        XCTAssertNoThrow(try ValidationService.validateHostname("example.com"))
        XCTAssertNoThrow(try ValidationService.validateHostname("sub.domain.example.com"))
    }
    
    func testInvalidHostname() {
        XCTAssertThrowsError(try ValidationService.validateHostname("-invalid"))
        XCTAssertThrowsError(try ValidationService.validateHostname("invalid-"))
        XCTAssertThrowsError(try ValidationService.validateHostname("inv alid"))
    }
}
```

#### 6.2 Parser Tests
```swift
// Tests/ParserTests.swift
import XCTest
@testable import HostsManager

class ParserTests: XCTestCase {
    func testParseSimpleEntry() throws {
        let content = "127.0.0.1 localhost"
        let hostsFile = try HostsFile.parse(content: content)
        
        XCTAssertEqual(hostsFile.entries.count, 1)
        XCTAssertEqual(hostsFile.entries[0].ipAddress, "127.0.0.1")
        XCTAssertEqual(hostsFile.entries[0].hostnames, ["localhost"])
    }
    
    func testParseMultipleHostnames() throws {
        let content = "127.0.0.1 localhost local"
        let hostsFile = try HostsFile.parse(content: content)
        
        XCTAssertEqual(hostsFile.entries[0].hostnames.count, 2)
    }
    
    func testParseDisabledEntry() throws {
        let content = "# 127.0.0.1 localhost"
        let hostsFile = try HostsFile.parse(content: content)
        
        XCTAssertEqual(hostsFile.entries.count, 1)
        XCTAssertFalse(hostsFile.entries[0].isEnabled)
    }
}
```

#### 6.3 Integration Testing Strategy
- [ ] Test helper tool installation on fresh system
- [ ] Test privilege escalation flow
- [ ] Test read/write operations on /etc/hosts
- [ ] Test DNS cache flushing
- [ ] Test Settings app integration
- [ ] Test with various hosts file formats
- [ ] Test error handling for permission denied
- [ ] Test backup and restore functionality

---

## 🔐 Security Considerations

### 1. Code Signing
```bash
# Sign all components with the same Team ID
codesign --sign "Developer ID Application" \
  --options runtime \
  --entitlements HostsManager.entitlements \
  HostsManager.app

codesign --sign "Developer ID Application" \
  --options runtime \
  --entitlements Helper.entitlements \
  HostsManagerHelper
```

### 2. Notarization
```bash
# Create signed archive
ditto -c -k --keepParent HostsManager.app HostsManager.zip

# Submit for notarization
xcrun notarytool submit HostsManager.zip \
  --apple-id "your@email.com" \
  --team-id "TEAMID" \
  --password "@keychain:AC_PASSWORD" \
  --wait

# Staple the notarization ticket
xcrun stapler staple HostsManager.app
```

### 3. Sandboxing Strategy
- **Main App**: Sandboxed with limited entitlements
- **Settings Extension**: Sandboxed, communicates via XPC
- **Helper Tool**: NOT sandboxed (requires root access to /etc/hosts)

### 4. Privilege Separation
- Extension never directly accesses /etc/hosts
- All privileged operations go through helper tool
- Helper tool validates all requests
- Use secure XPC communication

---

## 📚 Reference Documentation

### Apple Documentation
1. **SettingsKit Framework**
   - [Creating Settings Extensions](https://developer.apple.com/documentation/settingskit)
   - WWDC 2024: "What's new in macOS Sequoia"

2. **SMAppService**
   - [Installing and Managing Privileged Helper Tools](https://developer.apple.com/documentation/servicemanagement/smappservice)
   - Migration from SMJobBless

3. **XPC Services**
   - [Creating XPC Services](https://developer.apple.com/documentation/xpc)
   - [NSXPCConnection](https://developer.apple.com/documentation/foundation/nsxpcconnection)

4. **SwiftUI for macOS**
   - [SwiftUI on macOS](https://developer.apple.com/documentation/swiftui)
   - [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview)

### Hosts File Specification
- RFC 952: DOD Internet Host Table Specification
- [Hosts file format](https://en.wikipedia.org/wiki/Hosts_(file))
- Standard location: `/etc/hosts`

### Swift Concurrency
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- async/await patterns
- Actor isolation

---

## 🎨 Design Guidelines

### Visual Design
- Follow macOS Sequoia design language
- Use SF Symbols for icons
- Respect system accent color
- Support light/dark mode automatically
- Use native SwiftUI components

### User Experience
- Clear error messages
- Confirmation dialogs for destructive actions
- Live validation feedback
- Keyboard shortcuts for power users
- Accessibility support (VoiceOver, keyboard navigation)

### Performance
- Lazy loading for large hosts files
- Debounced search
- Background parsing
- Minimal XPC calls
- Efficient file I/O

---

## 🚀 Deployment Strategy

### Beta Testing
1. Internal testing on development machines
2. TestFlight distribution (if applicable)
3. Limited beta with power users
4. Feedback collection and iteration

### Release Checklist
- [ ] All unit tests passing
- [ ] Integration tests completed
- [ ] Code signed with Developer ID
- [ ] Notarized by Apple
- [ ] Documentation complete
- [ ] README updated
- [ ] Version number bumped
- [ ] Release notes prepared
- [ ] GitHub release created

### Distribution
- Direct download from website
- GitHub Releases
- Consider Homebrew cask
- Optional: Mac App Store (requires additional sandbox restrictions)

---

## 📝 Migration Notes

### For Existing Users
If upgrading from legacy preference pane:
1. Uninstall old preference pane
2. Install new Settings extension
3. Hosts file entries are preserved (no migration needed)
4. Re-grant privileges on first launch

### Breaking Changes
- Legacy `.prefPane` bundle completely replaced
- New bundle identifier
- New helper tool installation required
- UI/UX changes to match Settings app

---

## 🔄 Future Enhancements

### Version 2.1
- [ ] iCloud sync for hosts configurations
- [ ] Multiple profiles (work, home, etc.)
- [ ] Import from popular blocking lists
- [ ] Regular expression search
- [ ] Syntax highlighting

### Version 2.2
- [ ] Network debugging tools
- [ ] DNS query tester
- [ ] Hosts file conflict detection
- [ ] Auto-update functionality

### Version 3.0
- [ ] Integration with system firewall
- [ ] Network monitoring
- [ ] Traffic statistics
- [ ] Advanced blocking rules

---

## 📞 Support & Resources

### Getting Help
- GitHub Issues: Report bugs and feature requests
- Documentation: See README.md
- Community: Discussions tab

### Contributing
- Fork the repository
- Create feature branch
- Submit pull request
- Follow Swift style guide

---

## ✅ Implementation Checklist

### Week 1: Foundation
- [ ] Create Xcode project structure
- [ ] Set up Settings Extension target
- [ ] Configure bundle identifiers
- [ ] Create data models (HostEntry, HostsFile)
- [ ] Implement hosts file parser
- [ ] Create validation service

### Week 2: Privileged Operations
- [ ] Define XPC protocol
- [ ] Implement helper tool
- [ ] Configure SMAppService
- [ ] Create launchd plist
- [ ] Implement helper installer
- [ ] Test privilege escalation

### Week 3-4: User Interface
- [ ] Create HostsListView
- [ ] Create HostEntryEditorView
- [ ] Create HostEntryRow component
- [ ] Implement search functionality
- [ ] Add import/export UI
- [ ] Create about section

### Week 4-5: Business Logic
- [ ] Implement HostsViewModel
- [ ] Implement EditorViewModel
- [ ] Create HostsFileService
- [ ] Implement XPCService client
- [ ] Add error handling
- [ ] Implement backup/restore

### Week 5-6: Testing & Polish
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Test on multiple macOS versions
- [ ] Fix bugs and issues
- [ ] Optimize performance
- [ ] Update documentation

### Week 6: Release Preparation
- [ ] Code signing
- [ ] Notarization
- [ ] Create installer
- [ ] Write release notes
- [ ] Update README
- [ ] Tag release version

---

## 📊 Success Metrics

### Technical Goals
- ✅ Successfully installs on macOS Sequoia
- ✅ Helper tool installs without errors
- ✅ Can read/write /etc/hosts reliably
- ✅ DNS cache flushes correctly
- ✅ Settings app integration works perfectly
- ✅ No memory leaks or performance issues

### User Experience Goals
- ✅ Intuitive UI matching macOS conventions
- ✅ Fast response times (<100ms for UI interactions)
- ✅ Clear error messages
- ✅ Reliable privilege escalation
- ✅ Data integrity (no corruption of hosts file)

---

## 🎯 Project Timeline

**Total Duration:** 6 weeks

```
Week 1: [████████░░░░░░░░░░░░░░░░] Foundation
Week 2: [████████░░░░░░░░░░░░░░░░] Privileged Ops
Week 3: [████████░░░░░░░░░░░░░░░░] UI Layer
Week 4: [████████░░░░░░░░░░░░░░░░] Business Logic
Week 5: [████████░░░░░░░░░░░░░░░░] Testing
Week 6: [████████░░░░░░░░░░░░░░░░] Release Prep
```

**Target Release Date:** March 23, 2026

---

## 💡 Key Takeaways

1. **Modern Architecture**: Full SwiftUI, no XIBs or Storyboards
2. **Native Integration**: Settings Extension for seamless macOS experience
3. **Security First**: Proper privilege separation with SMAppService
4. **Swift Concurrency**: async/await throughout the codebase
5. **Maintainability**: Clean architecture, well-tested, documented

---

## 📄 License & Credits

**License:** MIT License (to be added)

**Original Project:** hosts-prefpane  
**Repository:** https://github.com/gomin2013/hosts-prefpane  
**Branch:** feature-sequoia  
**Last Commit:** "Cleaned previous resources."

---

**Document Version:** 1.0  
**Last Updated:** February 9, 2026  
**Maintained by:** Development Team  
**Status:** ✅ Ready for Implementation

---

## 🚦 Getting Started

To begin implementation, start with Phase 1 and work sequentially through each phase. Refer to the implementation checklist and mark off items as you complete them.

**Next Action:** Create Xcode project structure following Phase 1 guidelines.

Good luck! 🎉

