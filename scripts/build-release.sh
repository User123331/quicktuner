#!/bin/bash
# Build QuickTuner release DMGs for arm64 (Apple Silicon) and x86_64 (Intel)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

APP_NAME="QuickTuner"
BUNDLE_ID="com.billyendson.quicktuner"
MIN_MACOS="15.0"
VERSION=$(plutil -extract CFBundleShortVersionString raw Source/Info.plist)
# Use SIGNING_IDENTITY env var if set, otherwise auto-detect from keychain
SIGNING_IDENTITY="${SIGNING_IDENTITY:-$(security find-identity -v -p codesigning | grep -o '"[^"]*"' | head -1 | tr -d '"')}"

echo "Building QuickTuner v${VERSION} for arm64 + x86_64"
echo "------------------------------------------------------"

rm -rf dist
mkdir -p dist

build_arch() {
    local ARCH=$1
    local APP_DIR="dist/${APP_NAME}-${ARCH}.app"
    local DMG_NAME="${APP_NAME}-v${VERSION}-${ARCH}.dmg"

    echo ""
    echo "▶ Building ${ARCH}..."

    xcodebuild \
        -scheme "$APP_NAME" \
        -configuration Release \
        -destination "platform=macOS,arch=${ARCH}" \
        -derivedDataPath ".build/${ARCH}" \
        build 2>&1 | grep -E "^(error:|warning:|Build succeeded|Build FAILED|CompileSwift|Ld )" || true

    local BUILD_PRODUCTS=".build/${ARCH}/Build/Products/Release"

    if [ ! -f "$BUILD_PRODUCTS/$APP_NAME" ]; then
        echo "Error: executable not found at $BUILD_PRODUCTS/$APP_NAME"
        exit 1
    fi

    echo "  Assembling .app bundle..."
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"

    # Executable
    cp "$BUILD_PRODUCTS/$APP_NAME" "$APP_DIR/Contents/MacOS/"
    chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"

    # Info.plist — substitute build-setting variables
    sed \
        -e "s|\$(EXECUTABLE_NAME)|${APP_NAME}|g" \
        -e "s|\$(PRODUCT_BUNDLE_IDENTIFIER)|${BUNDLE_ID}|g" \
        -e "s|\$(PRODUCT_NAME)|${APP_NAME}|g" \
        Source/Info.plist > "$APP_DIR/Contents/Info.plist"

    # Compile asset catalog
    echo "  Compiling asset catalog..."
    local PARTIAL_PLIST
    PARTIAL_PLIST=$(mktemp /tmp/actool_info_XXXXXX.plist)
    xcrun actool \
        --output-format human-readable-text \
        --notices --warnings \
        --output-partial-info-plist "$PARTIAL_PLIST" \
        --app-icon AppIcon \
        --compress-pngs \
        --target-device mac \
        --minimum-deployment-target "$MIN_MACOS" \
        --platform macosx \
        --compile "$APP_DIR/Contents/Resources" \
        Source/Resources/Assets.xcassets > /dev/null 2>&1 || {
            echo "  actool failed, copying pre-built resources from repo..."
            cp "QuickTuner.app/Contents/Resources/Assets.car" "$APP_DIR/Contents/Resources/" 2>/dev/null || true
            cp "QuickTuner.app/Contents/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/" 2>/dev/null || true
        }
    rm -f "$PARTIAL_PLIST"

    # Ensure icns exists (actool may not produce it on all macOS versions)
    if [ ! -f "$APP_DIR/Contents/Resources/AppIcon.icns" ]; then
        cp "QuickTuner.app/Contents/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/" 2>/dev/null || true
    fi

    # Entitlements
    cp Source/QuickTuner.entitlements "$APP_DIR/Contents/Resources/"

    # PkgInfo (required by macOS app loader)
    echo -n "APPL????" > "$APP_DIR/Contents/PkgInfo"

    # Sign with certificate
    echo "  Signing with: ${SIGNING_IDENTITY}..."
    codesign --force --deep --sign "${SIGNING_IDENTITY}" \
        --entitlements Source/QuickTuner.entitlements \
        --options runtime \
        "$APP_DIR"

    # Create DMG
    echo "  Creating ${DMG_NAME}..."
    local STAGING="dist/staging-${ARCH}"
    mkdir -p "$STAGING"
    cp -r "$APP_DIR" "$STAGING/"
    ln -sf /Applications "$STAGING/Applications"

    hdiutil create \
        -volname "${APP_NAME} ${VERSION}" \
        -srcfolder "$STAGING" \
        -ov \
        -format UDZO \
        "dist/${DMG_NAME}" > /dev/null

    rm -rf "$STAGING"
    echo "  ✓ dist/${DMG_NAME}"
}

build_arch "arm64"
build_arch "x86_64"

echo ""
echo "------------------------------------------------------"
echo "Release artifacts:"
ls -lh dist/*.dmg
