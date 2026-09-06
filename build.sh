#!/usr/bin/env bash
# ==============================================================================
# WinDownload - Single-Run Build and Test Script for macOS
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} $1" >&2
}

print_header() {
    echo -e "${BLUE}${BOLD}"
    echo "========================================================"
    echo "          WinDownload - macOS Build Pipeline            "
    echo "========================================================"
    echo -e "${NC}"
}

usage() {
    echo "Usage: ./build.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -r, --run       Build and immediately launch WinDownload.app"
    echo "  -d, --debug     Build in Debug configuration (default: Release)"
    echo "  -t, --test      Run unit tests before building"
    echo "  -m, --dmg       Package WinDownload.app into a distributable .dmg disk image"
    echo "  -s, --spm       Force build using Swift Package Manager instead of xcodebuild"
    echo "  -c, --clean     Clean previous build artifacts before building"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh            # Standard Release build into build/WinDownload.app"
    echo "  ./build.sh --dmg      # Build and create build/WinDownload.dmg"
    echo "  ./build.sh --run      # Build and open the app immediately"
    echo "  ./build.sh --test     # Run tests and build"
    exit 0
}

# Defaults
CONFIGURATION="Release"
AUTO_RUN=false
RUN_TESTS=false
USE_SPM=false
DO_CLEAN=false
CREATE_DMG=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -r|--run)
            AUTO_RUN=true
            shift
            ;;
        -d|--debug)
            CONFIGURATION="Debug"
            shift
            ;;
        -t|--test)
            RUN_TESTS=true
            shift
            ;;
        -m|--dmg)
            CREATE_DMG=true
            shift
            ;;
        -s|--spm)
            USE_SPM=true
            shift
            ;;
        -c|--clean)
            DO_CLEAN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            error "Unknown option: $1"
            echo "Run ./build.sh --help for available options."
            exit 1
            ;;
    esac
done

print_header

# 1. Environment verification
OS_NAME="$(uname -s)"
if [[ "$OS_NAME" != "Darwin" ]]; then
    warn "You are currently running on $OS_NAME (not macOS)."
    info "WinDownload is a native macOS application designed to compile on a Mac using Xcode or the Swift toolchain."
    exit 0
fi

# Verify developer tools
HAS_XCODEBUILD=false
if command -v xcodebuild >/dev/null 2>&1; then
    HAS_XCODEBUILD=true
fi

HAS_SWIFT=false
if command -v swift >/dev/null 2>&1; then
    HAS_SWIFT=true
fi

if [[ "$HAS_XCODEBUILD" = false && "$HAS_SWIFT" = false ]]; then
    error "Neither xcodebuild nor swift was found on this Mac."
    error "Please install Xcode from the App Store or install Command Line Tools via:"
    error "    xcode-select --install"
    exit 1
fi

BUILD_DIR="$SCRIPT_DIR/build"
OUTPUT_APP="$BUILD_DIR/WinDownload.app"

# Clean if requested
if [[ "$DO_CLEAN" = true ]]; then
    info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    rm -rf .build
    success "Build directory cleaned."
fi

mkdir -p "$BUILD_DIR"

# 2. Run Tests if requested
if [[ "$RUN_TESTS" = true ]]; then
    info "Running unit tests..."
    if [[ "$HAS_SWIFT" = true ]]; then
        swift test
        success "All unit tests passed successfully!"
    else
        warn "swift test not available; skipping unit tests."
    fi
fi

# 3. Build Application
info "Building WinDownload (Configuration: $CONFIGURATION)..."

if [[ "$HAS_XCODEBUILD" = true && "$USE_SPM" = false ]]; then
    info "Compiling with xcodebuild using WinDownload.xcodeproj..."

    DERIVED_DATA="$BUILD_DIR/DerivedData"

    xcodebuild -project WinDownload.xcodeproj \
               -scheme WinDownload \
               -configuration "$CONFIGURATION" \
               -derivedDataPath "$DERIVED_DATA" \
               CODE_SIGN_IDENTITY="" \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO \
               COMPILER_INDEX_STORE_ENABLE=NO \
               -quiet

    BUILT_PRODUCT="$DERIVED_DATA/Build/Products/$CONFIGURATION/WinDownload.app"

    if [[ ! -d "$BUILT_PRODUCT" ]]; then
        error "Build completed but $BUILT_PRODUCT was not found."
        exit 1
    fi

    rm -rf "$OUTPUT_APP"
    cp -R "$BUILT_PRODUCT" "$OUTPUT_APP"

else
    info "Compiling with Swift Package Manager (swift build)..."

    SWIFT_BUILD_FLAGS=("-c" "$(echo "$CONFIGURATION" | tr '[:upper:]' '[:lower:]')")
    swift build "${SWIFT_BUILD_FLAGS[@]}"

    BIN_PATH="$(swift build "${SWIFT_BUILD_FLAGS[@]}" --show-bin-path)/WinDownload"

    if [[ ! -f "$BIN_PATH" ]]; then
        error "Binary not found at $BIN_PATH"
        exit 1
    fi

    info "Packaging standalone .app bundle..."
    rm -rf "$OUTPUT_APP"
    mkdir -p "$OUTPUT_APP/Contents/MacOS"
    mkdir -p "$OUTPUT_APP/Contents/Resources"

    cp "$BIN_PATH" "$OUTPUT_APP/Contents/MacOS/WinDownload"
    cp "WinDownload/App/Info.plist" "$OUTPUT_APP/Contents/Info.plist"
    echo -n "APPL????" > "$OUTPUT_APP/Contents/PkgInfo"
fi

# 4. Ad-hoc Code Signing
if command -v codesign >/dev/null 2>&1; then
    info "Applying ad-hoc code signature..."
    codesign --force --deep --sign - "$OUTPUT_APP" >/dev/null 2>&1 || true
    success "Signed bundle for local execution."
fi

# 5. Package into DMG if requested
if [[ "$CREATE_DMG" = true ]]; then
    info "Packaging WinDownload into disk image (.dmg)..."
    DMG_PATH="$BUILD_DIR/WinDownload.dmg"
    DMG_TEMP_DIR=$(mktemp -d /tmp/dmg-pack-XXXXXX)
    cp -R "$OUTPUT_APP" "$DMG_TEMP_DIR/"
    ln -s /Applications "$DMG_TEMP_DIR/Applications"
    hdiutil create -volname "WinDownload" -srcfolder "$DMG_TEMP_DIR" -ov -format UDZO "$DMG_PATH" -quiet
    rm -rf "$DMG_TEMP_DIR"
    shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"
    success "DMG created at: $DMG_PATH"
fi

echo ""
success "Build completed successfully!"
echo -e "${BOLD}Application Bundle:${NC} $OUTPUT_APP"
if [[ "$CREATE_DMG" = true ]]; then
    echo -e "${BOLD}Disk Image (.dmg):${NC} $BUILD_DIR/WinDownload.dmg"
fi
echo ""

# 6. Launch or instructions
if [[ "$AUTO_RUN" = true ]]; then
    info "Launching WinDownload.app..."
    open "$OUTPUT_APP"
else
    echo "To run the application, execute:"
    echo -e "    ${GREEN}${BOLD}open \"$OUTPUT_APP\"${NC}"
    echo ""
    echo "Or open the project directly in Xcode:"
    echo -e "    ${BLUE}${BOLD}open WinDownload.xcodeproj${NC}"
fi
