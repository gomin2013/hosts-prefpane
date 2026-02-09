# Xcode Project Setup Checklist

Complete this checklist to set up the Xcode project for Hosts Manager.

## ☐ Step 1: Create New Project

- [ ] Open Xcode
- [ ] File → New → Project
- [ ] Choose **macOS** → **App**
- [ ] Settings:
  - [ ] Product Name: `HostsManager`
  - [ ] Team: Your development team
  - [ ] Organization Identifier: `com.yourcompany`
  - [ ] Bundle Identifier: `com.yourcompany.HostsManager`
  - [ ] Interface: **SwiftUI**
  - [ ] Language: **Swift**
  - [ ] Storage: None
  - [ ] Testing: Include Tests
- [ ] Click Create and save to project folder

## ☐ Step 2: Configure Main Target

### 2.1 General Settings
- [ ] Open target settings for `HostsManager`
- [ ] Set **Minimum Deployments**: macOS 15.0
- [ ] Set **Display Name**: Hosts Manager
- [ ] Bundle Identifier: `com.hostsmanager.app`

### 2.2 Signing & Capabilities
- [ ] Enable **App Sandbox**
- [ ] Add capability: **File Access** → **User Selected Files** (Read/Write)
- [ ] Team: Your development team

### 2.3 Build Settings
- [ ] Swift Language Version: Swift 5.9
- [ ] Deployment Target: macOS 15.0

## ☐ Step 3: Add Extension Target

- [ ] File → New → Target
- [ ] Choose **macOS** → **App Extension** → **Generic Extension**
- [ ] Settings:
  - [ ] Product Name: `HostsManagerExtension`
  - [ ] Bundle Identifier: `com.hostsmanager.extension`
  - [ ] Embed in Application: HostsManager
- [ ] Click Finish

### 3.1 Configure Extension
- [ ] Open extension target settings
- [ ] General → Minimum Deployments: macOS 15.0
- [ ] Signing: Same team as main app
- [ ] Enable App Sandbox

## ☐ Step 4: Add Helper Tool Target

- [ ] File → New → Target
- [ ] Choose **macOS** → **Command Line Tool**
- [ ] Settings:
  - [ ] Product Name: `HostsManagerHelper`
  - [ ] Bundle Identifier: `com.hostsmanager.helper`
  - [ ] Do NOT embed (helper is separate)
- [ ] Click Finish

### 4.1 Configure Helper
- [ ] Open helper target settings
- [ ] General → Minimum Deployments: macOS 15.0
- [ ] Signing: Same team (important!)
- [ ] **Do NOT enable App Sandbox** (needs full file access)

## ☐ Step 5: Add Source Files

### 5.1 Add Main App Files
- [ ] Drag `HostsManagerApp/` folder to project
- [ ] Target Membership: ☑ HostsManager
- [ ] Create groups

### 5.2 Add Extension Files
- [ ] Drag `HostsManagerExtension/` folder to project
- [ ] Target Membership: ☑ HostsManagerExtension
- [ ] Create groups

### 5.3 Add Helper Files
- [ ] Drag `HostsManagerHelper/` folder to project
- [ ] Target Membership: ☑ HostsManagerHelper
- [ ] Create groups

### 5.4 Add Shared Files
- [ ] Drag `Shared/` folder to project
- [ ] Target Membership: ☑ All three targets
- [ ] Create groups

### 5.5 Add Test Files
- [ ] Drag `Tests/` folder to project
- [ ] Target Membership: ☑ HostsManagerTests
- [ ] Create groups

## ☐ Step 6: Configure Info.plist

### 6.1 Main App Info.plist
Add these keys:
```xml
<key>NSHumanReadableCopyright</key>
<string>Copyright © 2026. All rights reserved.</string>
```

### 6.2 Extension Info.plist
Add these keys:
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.preferences.extension</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).HostsManagerExtension</string>
</dict>
```

### 6.3 Helper Info.plist
Add these keys:
```xml
<key>SMAuthorizedClients</key>
<array>
    <string>identifier "com.hostsmanager.app" and anchor apple generic and certificate leaf[subject.CN] = "YOUR_CERT_NAME"</string>
</array>
```

## ☐ Step 7: Configure Entitlements

### 7.1 App Entitlements (HostsManager.entitlements)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

### 7.2 Extension Entitlements (HostsManagerExtension.entitlements)
Same as app entitlements

### 7.3 Helper Entitlements (HostsManagerHelper.entitlements)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
</dict>
</plist>
```

## ☐ Step 8: Fix File References

- [ ] Update bundle identifier references in Constants.swift if needed
- [ ] Ensure all imports resolve correctly
- [ ] Fix any "Cannot find type" errors

## ☐ Step 9: Build Each Target

- [ ] Select `HostsManager` scheme
- [ ] Product → Build (⌘B)
- [ ] Check for errors

- [ ] Select `HostsManagerExtension` scheme
- [ ] Product → Build (⌘B)
- [ ] Check for errors

- [ ] Select `HostsManagerHelper` scheme
- [ ] Product → Build (⌘B)
- [ ] Check for errors

- [ ] Select `HostsManagerTests` scheme
- [ ] Product → Test (⌘U)
- [ ] Verify tests pass

## ☐ Step 10: Configure Schemes

### 10.1 Main App Scheme
- [ ] Edit scheme for HostsManager
- [ ] Run → Options → Document Versions: Enabled
- [ ] Test → Add test target: HostsManagerTests

### 10.2 Set Build Order
- [ ] Helper builds first
- [ ] Extension builds second
- [ ] App builds last

## ☐ Step 11: Test Run

- [ ] Select HostsManager scheme
- [ ] Click Run (⌘R)
- [ ] Verify app launches
- [ ] Check console for errors
- [ ] Test basic functionality

## ☐ Step 12: SwiftUI Previews

- [ ] Open any View file
- [ ] Click Resume button in preview canvas
- [ ] Verify preview renders correctly
- [ ] Test with different sample data

## ☐ Step 13: Helper Tool Integration

- [ ] Build the helper tool
- [ ] Manually install to `/Library/PrivilegedHelperTools/` for testing
- [ ] Test XPC connection
- [ ] Verify file operations work

## ☐ Step 14: Code Signing

- [ ] Select all targets
- [ ] Signing & Capabilities → Automatically manage signing
- [ ] Or configure manual signing with same team ID

## ☐ Step 15: Final Checks

- [ ] All targets build without errors
- [ ] All tests pass
- [ ] No SwiftUI preview errors
- [ ] App runs and launches UI
- [ ] XPC connection works (if helper installed)
- [ ] File operations work (with helper)

---

## Common Issues & Solutions

### Issue: Cannot find type 'HostEntry'
**Solution:** Ensure Shared files are added to all targets that need them

### Issue: Module 'Network' not found
**Solution:** Add Network.framework to Link Binary With Libraries

### Issue: Helper connection fails
**Solution:** 
1. Check helper is signed with same team ID
2. Verify helper is installed in correct location
3. Check helper's Info.plist SMAuthorizedClients

### Issue: App Sandbox errors
**Solution:** Helper should NOT have sandbox enabled

### Issue: Build fails with "No such module 'Combine'"
**Solution:** Ensure deployment target is macOS 15.0+

---

## Verification Commands

```bash
# Check if helper is installed
ls -la /Library/PrivilegedHelperTools/

# Check helper signature
codesign -dvvv /Library/PrivilegedHelperTools/com.hostsmanager.helper

# View helper logs
tail -f /var/log/hostsmanager-helper.log

# Run tests from command line
xcodebuild test -scheme HostsManager
```

---

## ✅ Completion

Once all checkboxes are marked:
- [ ] Project builds successfully
- [ ] Tests pass
- [ ] App runs without errors
- [ ] Documentation is updated
- [ ] Commit changes to git

**Status:** □ Not Started | □ In Progress | □ Complete

Last updated: February 9, 2026

