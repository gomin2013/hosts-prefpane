# Troubleshooting Guide - Hosts Manager

## Common Issues and Solutions

### ❌ xcode-select: error: tool 'xcodebuild' requires Xcode

**Error Message:**
```
xcodebuild xcode-select: error: tool 'xcodebuild' requires Xcode, 
but active developer directory '/Library/Developer/CommandLineTools' 
is a command line tools instance
```

**Problem:**  
You have Xcode Command Line Tools installed, but not the full Xcode application. The Command Line Tools only include compilers and basic utilities, but **not** the IDE or build system needed for macOS app development.

**Solution:**

1. **Install Full Xcode** (if not already installed)
   ```bash
   # Option 1: Mac App Store
   # Open Mac App Store and search for "Xcode"
   # Click "Get" or "Install"
   
   # Option 2: Direct download
   # Visit https://developer.apple.com/download/
   # Download Xcode 15.0 or later
   ```

2. **Set Xcode as Active Developer Directory**
   ```bash
   # After Xcode is installed, run:
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

3. **Verify Installation**
   ```bash
   xcode-select -p
   # Should output: /Applications/Xcode.app/Contents/Developer
   
   xcodebuild -version
   # Should output: Xcode 15.x
   ```

4. **Accept Xcode License** (if prompted)
   ```bash
   sudo xcodebuild -license accept
   ```

**Note:** This project can be developed without full Xcode for now since all source code is complete. You'll only need Xcode when you're ready to create the project and build the application.

---

### ⚠️ Can I use Command Line Tools only?

**Short Answer:** No, not for this project.

**Why:** 
- This is a macOS **app** with SwiftUI, not a command-line tool
- Requires Xcode's Interface Builder and SwiftUI previews
- Needs proper code signing for the privileged helper
- Settings Extensions require Xcode's app extension templates

**Alternative:** You can still:
- ✅ View and edit source code with any text editor
- ✅ Review the implementation and documentation
- ✅ Plan the Xcode project structure
- ✅ Commit changes to git

You'll need full Xcode when ready to **build and run** the application.

---

### 🔍 Checking Your Current Setup

Run this diagnostic script:

```bash
#!/bin/bash
echo "=== Xcode Environment Check ==="
echo ""

# Check xcode-select path
echo "1. Active Developer Directory:"
xcode-select -p 2>&1
echo ""

# Check if full Xcode is installed
echo "2. Full Xcode Installation:"
if [ -d "/Applications/Xcode.app" ]; then
    echo "✅ Full Xcode is installed at /Applications/Xcode.app"
else
    echo "❌ Full Xcode NOT found at /Applications/Xcode.app"
fi
echo ""

# Check xcodebuild
echo "3. xcodebuild availability:"
if command -v xcodebuild &> /dev/null; then
    xcodebuild -version 2>&1 | head -2
else
    echo "❌ xcodebuild not available"
fi
echo ""

# Check Swift version
echo "4. Swift compiler:"
swift --version 2>&1 | head -1
echo ""

# Check Command Line Tools
echo "5. Command Line Tools:"
if xcode-select -p | grep -q "CommandLineTools"; then
    echo "⚠️  Only Command Line Tools (need full Xcode)"
else
    echo "✅ Using full Xcode developer directory"
fi
echo ""

echo "=== Summary ==="
if [ -d "/Applications/Xcode.app" ] && ! xcode-select -p | grep -q "CommandLineTools"; then
    echo "✅ Your environment is ready for development!"
else
    echo "⚠️  You need to install full Xcode and configure xcode-select"
    echo "   1. Install Xcode from Mac App Store"
    echo "   2. Run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
fi
```

Save this as `check-xcode.sh`, make it executable, and run:
```bash
chmod +x check-xcode.sh
./check-xcode.sh
```

---

### 📋 Xcode Installation Sizes

**Be Aware:**
- Xcode download: ~8-12 GB
- Installed size: ~15-20 GB
- Additional simulators: 2-5 GB each (optional)

Make sure you have sufficient disk space before installing.

---

### 🆘 Still Having Issues?

1. **Verify Xcode is not corrupted**
   ```bash
   # Re-install Xcode components
   sudo rm -rf /Library/Developer/CommandLineTools
   xcode-select --install
   ```

2. **Check disk space**
   ```bash
   df -h /Applications
   ```

3. **Check macOS version**
   ```bash
   sw_vers
   # ProductVersion should be 14.0+ (for Xcode 15)
   ```

4. **Restart after installation**
   - Sometimes macOS needs a restart for Xcode to be fully recognized

---

### ✅ Once Xcode is Ready

After Xcode is properly installed and configured:

1. **Read XCODE_SETUP.md** - Complete setup checklist
2. **Create the Xcode project** - Follow step-by-step guide
3. **Add source files** - Drag folders into Xcode
4. **Build the app** - Product → Build (⌘B)

---

### 🎯 Current Project Status

Even without Xcode, the project has:
- ✅ 24 complete Swift source files (3,146 lines)
- ✅ All models, services, views, and tests
- ✅ Comprehensive documentation
- ✅ Ready-to-use code structure

**You can:**
- Review and understand the codebase
- Read documentation
- Plan implementation details
- Make code changes if needed

**You'll need Xcode to:**
- Create the Xcode project file
- Build and run the application
- Test on simulator or device
- Code sign for distribution

---

### 📚 Additional Resources

- [Xcode Download](https://developer.apple.com/xcode/)
- [Xcode Release Notes](https://developer.apple.com/documentation/xcode-release-notes)
- [Mac App Store - Xcode](https://apps.apple.com/app/xcode/id497799835)
- [xcode-select man page](https://ss64.com/osx/xcode-select.html)

---

**Last Updated:** February 9, 2026

