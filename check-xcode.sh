#!/bin/bash
# Xcode Environment Diagnostic Script
# Checks if the development environment is ready for building macOS apps

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║        Xcode Environment Diagnostic Tool                  ║"
echo "║        Hosts Manager Project                              ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Status indicators
CHECK_MARK="${GREEN}✅${NC}"
CROSS_MARK="${RED}❌${NC}"
WARNING="${YELLOW}⚠️${NC}"

errors=0
warnings=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Checking Active Developer Directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DEV_DIR=$(xcode-select -p 2>&1)
echo "   Path: $DEV_DIR"

if echo "$DEV_DIR" | grep -q "CommandLineTools"; then
    echo -e "   $CROSS_MARK Using Command Line Tools only"
    echo "   This is NOT sufficient for macOS app development"
    ((errors++))
elif [ -d "$DEV_DIR" ]; then
    echo -e "   $CHECK_MARK Using full Xcode"
else
    echo -e "   $CROSS_MARK Developer directory not found"
    ((errors++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Checking for Full Xcode Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "/Applications/Xcode.app" ]; then
    echo -e "   $CHECK_MARK Full Xcode found at /Applications/Xcode.app"

    # Get Xcode version from Info.plist
    XCODE_VERSION=$(defaults read /Applications/Xcode.app/Contents/Info CFBundleShortVersionString 2>/dev/null)
    if [ -n "$XCODE_VERSION" ]; then
        echo "   Version: $XCODE_VERSION"
    fi
else
    echo -e "   $CROSS_MARK Full Xcode NOT found at /Applications/Xcode.app"
    echo "   Install from: Mac App Store → Xcode"
    ((errors++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Checking xcodebuild Availability"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v xcodebuild &> /dev/null; then
    XCODE_BUILD_VERSION=$(xcodebuild -version 2>&1 | head -1)
    echo "   $XCODE_BUILD_VERSION"

    if xcodebuild -version 2>&1 | grep -q "error"; then
        echo -e "   $CROSS_MARK xcodebuild has errors"
        xcodebuild -version 2>&1 | tail -n +2
        ((errors++))
    else
        echo -e "   $CHECK_MARK xcodebuild is working"
    fi
else
    echo -e "   $CROSS_MARK xcodebuild not found"
    ((errors++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. Checking Swift Compiler"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v swift &> /dev/null; then
    SWIFT_VERSION=$(swift --version 2>&1 | head -1)
    echo "   $SWIFT_VERSION"

    # Extract version number
    SWIFT_VER=$(echo "$SWIFT_VERSION" | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [ -n "$SWIFT_VER" ]; then
        echo -e "   $CHECK_MARK Swift compiler available"

        # Check if version is 5.9 or higher (required for this project)
        if awk -v ver="$SWIFT_VER" 'BEGIN{exit(ver<5.9)}'; then
            echo "   Version $SWIFT_VER meets requirements (≥5.9)"
        else
            echo -e "   $WARNING Version $SWIFT_VER is below recommended (5.9+)"
            ((warnings++))
        fi
    fi
else
    echo -e "   $CROSS_MARK Swift compiler not found"
    ((errors++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. Checking macOS Version"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MACOS_VERSION=$(sw_vers -productVersion)
echo "   macOS Version: $MACOS_VERSION"

# Extract major version
MACOS_MAJOR=$(echo "$MACOS_VERSION" | cut -d. -f1)
if [ "$MACOS_MAJOR" -ge 14 ]; then
    echo -e "   $CHECK_MARK macOS version is compatible with Xcode 15+"
else
    echo -e "   $WARNING macOS version may not support latest Xcode"
    echo "   Recommended: macOS 14.0 (Sonoma) or later"
    ((warnings++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Checking Disk Space"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check available space on /Applications volume
AVAILABLE=$(df -h /Applications | awk 'NR==2 {print $4}')
echo "   Available space on /Applications: $AVAILABLE"

# Get numeric value in GB
AVAILABLE_GB=$(df -g /Applications | awk 'NR==2 {print $4}')
if [ "$AVAILABLE_GB" -lt 20 ]; then
    echo -e "   $WARNING Low disk space (Xcode needs ~20GB)"
    echo "   Consider freeing up space before installing Xcode"
    ((warnings++))
else
    echo -e "   $CHECK_MARK Sufficient disk space for Xcode"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. Checking Project Files"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -d "HostsManagerApp" ] && [ -d "HostsManagerExtension" ]; then
    echo -e "   $CHECK_MARK Project source files found"

    SWIFT_FILES=$(find . -name "*.swift" -not -path "./.build/*" | wc -l | tr -d ' ')
    echo "   Swift files: $SWIFT_FILES"
else
    echo -e "   $WARNING Project source files not found in current directory"
    echo "   Are you in the project root?"
    ((warnings++))
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "${GREEN}✅ SUCCESS!${NC} Your environment is ready for development!"
    echo ""
    echo "Next steps:"
    echo "  1. Read XCODE_SETUP.md"
    echo "  2. Create Xcode project"
    echo "  3. Build and test"
elif [ $errors -eq 0 ]; then
    echo -e "${YELLOW}⚠️  WARNINGS FOUND${NC} ($warnings warning(s))"
    echo ""
    echo "Your environment should work, but review the warnings above."
else
    echo -e "${RED}❌ ERRORS FOUND${NC} ($errors error(s), $warnings warning(s))"
    echo ""
    echo "Your environment is NOT ready. Please address the errors above."
    echo ""

    if echo "$DEV_DIR" | grep -q "CommandLineTools"; then
        echo "PRIMARY ISSUE: Command Line Tools only"
        echo ""
        echo "SOLUTION:"
        echo "  1. Install Xcode from Mac App Store"
        echo "  2. Run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
        echo "  3. Run this diagnostic again"
        echo ""
        echo "For detailed help, see: TROUBLESHOOTING.md"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit $errors

