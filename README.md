# Hosts Manager for macOS Sequoia

A modern macOS Settings extension for managing the `/etc/hosts` file, built entirely with SwiftUI for macOS Sequoia (15.0+).

## Features

- 🎨 **Native SwiftUI Interface** - Modern, clean UI that integrates seamlessly with macOS Settings
- 🔒 **Secure Privilege Escalation** - Uses `SMAppService` for secure root access
- ✏️ **Full CRUD Operations** - Add, edit, delete, and toggle host entries
- ✅ **Smart Validation** - Validates IP addresses (IPv4/IPv6) and hostnames (RFC 1123)
- 📤 **Import/Export** - Backup and restore your hosts configuration
- 🔍 **Search & Filter** - Quickly find entries with built-in search
- 💬 **Comments Support** - Add notes to your host entries
- 🔄 **Auto DNS Flush** - Automatically flushes DNS cache after changes

## Requirements

- macOS Sequoia 15.0 or later
- Xcode 15.0 or later
- Swift 5.9+

## Architecture

This project uses a three-tier architecture:

1. **Settings Extension** (`HostsManagerExtension`) - SwiftUI interface that appears in System Settings
2. **Helper Tool** (`HostsManagerHelper`) - Privileged XPC service that performs root file operations
3. **Shared Code** - Models, protocols, and utilities shared between components

```
┌──────────────────────────────────────────┐
│  Settings.app                            │
│  ┌────────────────────────────────────┐  │
│  │  Hosts Manager Extension           │  │
│  │  (SwiftUI Views + ViewModels)      │  │
│  └────────────────────────────────────┘  │
└──────────────────────────────────────────┘
           ↕ XPC Communication
┌──────────────────────────────────────────┐
│  Privileged Helper Tool                  │
│  (Root access to /etc/hosts)             │
└──────────────────────────────────────────┘
```

## Project Structure

```
hosts-prefpane/
├── HostsManagerApp/              # Main app container
├── HostsManagerExtension/        # Settings extension (UI)
├── HostsManagerHelper/           # Privileged helper tool
├── Shared/                       # Shared models & utilities
└── Tests/                        # Unit tests
```

## Installation

1. Clone the repository
2. Open `HostsManager.xcodeproj` in Xcode
3. Build and run the project
4. The extension will appear in System Settings

## Development

### Current Status (February 28, 2026)

✅ **All source code is complete** (24 Swift files, 3,146 lines)  
✅ **Configuration files created** (Info.plist, entitlements, Package.swift)  
✅ **Code fixes applied** (String+Validation, Logger, View+Extensions)  
⚠️ **Xcode project needs to be created** (follow XCODE_SETUP.md)  
⚠️ **Full Xcode required** (Command Line Tools insufficient)

**Quick Status Check:** Run `./next-steps.sh` for detailed status  
**Implementation Progress:** ~70% complete (code done, needs Xcode project)

### Building (after Xcode project is set up)

In Xcode:
1. Select the `HostsManagerApp` scheme
2. Product → Build (⌘B)

Or via command line:
```bash
xcodebuild -project HostsManager.xcodeproj \
           -scheme HostsManagerApp \
           -configuration Debug \
           build
```

### Testing

In Xcode:
1. Select the `HostsManagerTests` scheme
2. Product → Test (⌘U)

Or via command line:
```bash
xcodebuild test -project HostsManager.xcodeproj \
                -scheme HostsManagerApp
```

### Quick Start for Development

1. **Read QUICKSTART.md** - Understand what's been built
2. **Follow XCODE_SETUP.md** - Step-by-step Xcode project creation
3. **Review IMPLEMENTATION.md** - Technical architecture details

## Security

This application requires elevated privileges to modify `/etc/hosts`. Security measures include:

- ✅ Privileged operations isolated in separate helper tool
- ✅ XPC communication with strict protocol validation
- ✅ Helper tool managed by `SMAppService` (no shell scripts)
- ✅ Automatic backup before any write operation
- ✅ Input validation for all IP addresses and hostnames

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Roadmap

- [x] Phase 1: Project setup and infrastructure
- [x] Phase 2: Data models and business logic
- [x] Phase 3: Privileged helper tool with XPC
- [x] Phase 4: SwiftUI interface
- [ ] Phase 5: Testing and polish
- [ ] Phase 6: Distribution preparation

## Support

For issues, questions, or contributions, please open an issue on GitHub.

---

**Note:** This project is designed for macOS Sequoia and later. It replaces the legacy `.prefPane` bundle format with modern Settings Extensions.

