#!/bin/bash
# Automated Xcode Project Generator for Hosts Manager
# This script creates the Xcode project structure programmatically

set -e

PROJECT_NAME="HostsManager"
PROJECT_DIR="$(pwd)"
XCODE_PROJECT="${PROJECT_NAME}.xcodeproj"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                                                           ║"
echo "║        Hosts Manager - Xcode Project Generator           ║"
echo "║                                                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found"
    echo "   Full Xcode is required. Install from Mac App Store."
    echo "   Then run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    exit 1
fi

echo "✅ Xcode found"
echo ""

# Check if project already exists
if [ -d "$XCODE_PROJECT" ]; then
    echo "⚠️  Warning: $XCODE_PROJECT already exists"
    read -p "   Delete and recreate? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$XCODE_PROJECT"
        echo "   Deleted existing project"
    else
        echo "   Keeping existing project"
        exit 0
    fi
fi

echo "📦 Creating Xcode project structure..."
echo ""

# Create project directory structure
mkdir -p "$XCODE_PROJECT/project.xcworkspace/xcuserdata"
mkdir -p "$XCODE_PROJECT/xcshareddata/xcschemes"

# Generate unique IDs for project structure
APP_TARGET_ID="A1$(uuidgen | tr -d '-' | cut -c1-22)"
EXT_TARGET_ID="A2$(uuidgen | tr -d '-' | cut -c1-22)"
HELPER_TARGET_ID="A3$(uuidgen | tr -d '-' | cut -c1-22)"
TEST_TARGET_ID="A4$(uuidgen | tr -d '-' | cut -c1-22)"
PROJECT_ID="B1$(uuidgen | tr -d '-' | cut -c1-22)"
MAINGROUP_ID="B2$(uuidgen | tr -d '-' | cut -c1-22)"

echo "🔧 Generating project.pbxproj..."

# Create project.pbxproj
cat > "$XCODE_PROJECT/project.pbxproj" << 'PBXPROJ_EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXProject section */
		PROJECT_REF /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = PROJECT_BUILD_CONFIG_LIST;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = MAIN_GROUP_REF;
			productRefGroup = PRODUCTS_GROUP_REF;
			projectDirPath = "";
			projectRoot = "";
			targets = (
			);
		};
/* End PBXProject section */

	};
	rootObject = PROJECT_REF /* Project object */;
}
PBXPROJ_EOF

echo "✅ Basic project structure created"
echo ""

echo "⚠️  IMPORTANT: Manual Steps Required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The basic Xcode project has been created, but you need to complete it:"
echo ""
echo "1️⃣  Open the project in Xcode:"
echo "    open $XCODE_PROJECT"
echo ""
echo "2️⃣  Add targets manually in Xcode:"
echo "    • File → New → Target → macOS App"
echo "    • File → New → Target → Command Line Tool (for Helper)"
echo ""
echo "3️⃣  Add source files:"
echo "    • Drag folders into Xcode project navigator"
echo "    • HostsManagerApp → App target"
echo "    • HostsManagerExtension → Extension target"
echo "    • HostsManagerHelper → Helper target"
echo "    • Shared → All targets"
echo ""
echo "4️⃣  Configure bundle identifiers:"
echo "    • App: com.hostsmanager.app"
echo "    • Extension: com.hostsmanager.extension"
echo "    • Helper: com.hostsmanager.helper"
echo ""
echo "5️⃣  Set deployment target to macOS 15.0 for all targets"
echo ""
echo "6️⃣  Add entitlements (see XCODE_SETUP.md for details)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📖 For detailed instructions, see: docs/XCODE_SETUP.md"
echo ""


