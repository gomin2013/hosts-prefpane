# Hosts Manager for macOS Sequoia

A modern macOS Settings extension for managing the `/etc/hosts` file, built entirely with SwiftUI for macOS Sequoia (15.0+).

## Features

- 🎨 **Native SwiftUI Interface** — Integrates seamlessly with System Settings
- 🔒 **Secure Privilege Escalation** — Uses `SMAppService` for safe root access
- ✏️ **Full CRUD Operations** — Add, edit, delete, and toggle host entries
- ✅ **Smart Validation** — Validates IPv4/IPv6 addresses and hostnames (RFC 1123)
- 📤 **Import/Export** — Backup and restore your hosts configuration
- 🔍 **Search & Filter** — Quickly find entries with built-in search
- 💬 **Comments Support** — Attach notes to individual host entries
- 🔄 **Auto DNS Flush** — Flushes DNS cache automatically after changes

## Requirements

- macOS Sequoia 15.0 or later
- Xcode 16.0 or later
- Swift 5.9+

## Architecture

Three-tier architecture with strict privilege separation:

1. **Settings Extension** (`HostsManagerExtension`) — SwiftUI interface inside System Settings
2. **Privileged Helper Tool** (`HostsManagerHelper`) — XPC service that performs root file operations
3. **Host App** (`HostsManagerApp`) — Container app that registers the helper via `SMAppService`
4. **Shared** — Models, protocols, and utilities shared across all targets

```
┌──────────────────────────────────────────┐
│  System Settings.app                     │
│  ┌────────────────────────────────────┐  │
│  │  HostsManagerExtension             │  │
│  │  (SwiftUI Views + ViewModels)      │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
           ↕ XPC (NSXPCConnection)
┌──────────────────────────────────────────┐
│  HostsManagerHelper (launchd daemon)     │
│  Root access → reads/writes /etc/hosts   │
└──────────────────────────────────────────┘
```

## Project Structure

```
hosts-prefpane/
├── HostsManager.xcodeproj/       # Xcode project (3 targets + tests)
├── HostsManagerApp/              # Container app + SMAppService registration
├── HostsManagerExtension/        # Settings extension (UI + logic)
│   ├── Models/                   # HostEntry, HostsFile, ValidationError
│   ├── Services/                 # HostsFileService, ValidationService, XPCService
│   ├── ViewModels/               # HostsViewModel, EditorViewModel
│   └── Views/                    # SwiftUI views
├── HostsManagerHelper/           # Privileged XPC daemon
├── Shared/                       # Constants, Logger, protocols, extensions
│   ├── Extensions/
│   └── Utilities/
└── Tests/                        # Unit tests (Validation, Parser)
```

## Getting Started

### Build

```bash
open HostsManager.xcodeproj
```

Select the `HostsManagerApp` scheme → **Product → Build** (⌘B).

Or via command line:

```bash
xcodebuild -project HostsManager.xcodeproj \
           -scheme HostsManagerApp \
           -configuration Debug \
           build
```

### Test

```bash
xcodebuild test -project HostsManager.xcodeproj \
                -scheme HostsManagerApp
```

Or in Xcode: **Product → Test** (⌘U).

## Security

Elevated privileges are required to modify `/etc/hosts`. Mitigations include:

- ✅ Privileged operations isolated in a separate helper binary
- ✅ XPC communication with strict protocol validation (`HelperProtocol`)
- ✅ Helper managed by `SMAppService` — no shell scripts or `AuthorizationExecuteWithPrivileges`
- ✅ Automatic backup created before every write operation
- ✅ Full input validation for IP addresses and hostnames

## Development Status

_Last updated: March 1, 2026_

| Phase | Description | Status |
|-------|-------------|--------|
| 1–4 | Source code (models, services, views, helper) | ✅ Complete |
| 5 | Configuration (Info.plist, entitlements, Package.swift) | ✅ Complete |
| 6 | Xcode project setup & target configuration | ✅ Complete |
| 7 | Testing (unit + integration) | 🔲 Pending |
| 8 | Polish & UI refinement | 🔲 Pending |
| 9 | Distribution (signing, notarization, installer) | 🔲 Pending |

## Roadmap

- [x] Phase 1: Project structure and infrastructure
- [x] Phase 2: Data models and business logic
- [x] Phase 3: Privileged helper tool with XPC
- [x] Phase 4: SwiftUI interface
- [x] Phase 5: Configuration files
- [x] Phase 6: Xcode project setup
- [ ] Phase 7: Testing and compilation verification
- [ ] Phase 8: Polish, accessibility, and performance
- [ ] Phase 9: Code signing, notarization, and distribution

## License

MIT License — see LICENSE file for details.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## Support

For issues or questions, please open an issue on GitHub.

---

> This project targets macOS Sequoia (15.0+) and uses the modern Settings Extension API, replacing the legacy `.prefPane` bundle format.
