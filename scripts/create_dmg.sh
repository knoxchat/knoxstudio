#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# KnoxStudio DMG Creator with Custom Background
#
# Creates a professional DMG installer with:
# - Custom background image
# - Icon positioning (App on left, Applications alias on right)
# - Window size and position settings
# - Retina-ready graphics
#
# Usage: ./scripts/create_dmg.sh [--no-background]
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ── Configuration ─────────────────────────────────────────────────────────────
APP_NAME="KnoxStudio"
VERSION=$(grep '^version = ' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
APP_BUNDLE="$ROOT_DIR/target/$APP_NAME.app"
DMG_TEMP="$ROOT_DIR/target/dmg-temp"
DMG_FINAL="$ROOT_DIR/target/$APP_NAME-$VERSION.dmg"
DMG_VOLUME_NAME="$APP_NAME $VERSION"

# DMG window settings
WINDOW_WIDTH=640
WINDOW_HEIGHT=480
ICON_SIZE=128
APP_ICON_X=160
APP_ICON_Y=200
APPS_ICON_X=480
APPS_ICON_Y=200

# Background image (optional)
BACKGROUND_IMAGE="$ROOT_DIR/assets/dmg-background.png"
USE_BACKGROUND=true

if [[ "${1:-}" == "--no-background" ]]; then
    USE_BACKGROUND=false
fi

# ── Validation ────────────────────────────────────────────────────────────────
if [[ ! -d "$APP_BUNDLE" ]]; then
    echo "Error: App bundle not found at $APP_BUNDLE"
    echo "Run 'make bundle' first."
    exit 1
fi

# ── Create background if needed ───────────────────────────────────────────────
create_background() {
    if [[ -f "$BACKGROUND_IMAGE" ]]; then
        echo "  Using existing background: $BACKGROUND_IMAGE"
        return 0
    fi
    
    echo "  Generating default background..."
    
    mkdir -p "$(dirname "$BACKGROUND_IMAGE")"
    
    # Create a simple gradient background using Python/PIL or sips
    if command -v python3 &> /dev/null; then
        python3 << 'PYTHON_SCRIPT'
try:
    from PIL import Image, ImageDraw, ImageFont
    
    # Create gradient background (Retina: 2x resolution)
    width, height = 1280, 960
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    # Gradient from dark blue to lighter blue
    for y in range(height):
        r = int(25 + (35 - 25) * y / height)
        g = int(35 + (55 - 35) * y / height)
        b = int(55 + (85 - 55) * y / height)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Add subtle text
    try:
        # Try to use a system font
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
    except:
        font = ImageFont.load_default()
    
    # Draw arrow hint
    draw.text((width // 2 - 50, height - 100), "← Drag to Applications →", 
              fill=(100, 120, 150), font=font)
    
    img.save('assets/dmg-background.png', 'PNG')
    print("  Created: assets/dmg-background.png")
except ImportError:
    print("  PIL not available, skipping background generation")
    exit(1)
PYTHON_SCRIPT
    else
        # Create a simple solid color PNG using sips
        echo "  Creating simple background..."
        mkdir -p "$ROOT_DIR/assets"
        # Create a 1x1 pixel and scale it
        printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\x0f\x00\x00\x01\x01\x00\x05\x18\xd8N\x00\x00\x00\x00IEND\xaeB`\x82' > "$BACKGROUND_IMAGE.tmp"
        sips -z 960 1280 "$BACKGROUND_IMAGE.tmp" --out "$BACKGROUND_IMAGE" 2>/dev/null || {
            rm -f "$BACKGROUND_IMAGE.tmp"
            USE_BACKGROUND=false
            return 1
        }
        rm -f "$BACKGROUND_IMAGE.tmp"
    fi
}

# ── Create DMG ────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════"
echo "  Creating $APP_NAME $VERSION DMG"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Clean up
rm -rf "$DMG_TEMP"
rm -f "$DMG_FINAL"
mkdir -p "$DMG_TEMP"

# Copy app bundle
echo "▸ Copying app bundle..."
cp -R "$APP_BUNDLE" "$DMG_TEMP/"

# Create Applications symlink
echo "▸ Creating Applications symlink..."
ln -s /Applications "$DMG_TEMP/Applications"

# Copy background if using custom background
if [[ "$USE_BACKGROUND" == "true" ]]; then
    echo "▸ Setting up background..."
    if create_background; then
        mkdir -p "$DMG_TEMP/.background"
        cp "$BACKGROUND_IMAGE" "$DMG_TEMP/.background/background.png"
    else
        USE_BACKGROUND=false
    fi
fi

# Create temporary DMG (read-write)
echo "▸ Creating temporary DMG..."
hdiutil create \
    -volname "$DMG_VOLUME_NAME" \
    -srcfolder "$DMG_TEMP" \
    -ov \
    -format UDRW \
    "$DMG_TEMP/temp.dmg"

# Mount the DMG
echo "▸ Mounting DMG for customization..."
MOUNT_OUTPUT=$(hdiutil attach "$DMG_TEMP/temp.dmg" -readwrite -noverify)
DEVICE=$(echo "$MOUNT_OUTPUT" | grep "/Volumes/" | head -1 | awk '{print $1}')
MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep "/Volumes/" | head -1 | awk '{print $3}')

if [[ -z "$MOUNT_POINT" ]]; then
    MOUNT_POINT="/Volumes/$DMG_VOLUME_NAME"
fi

echo "  Mounted at: $MOUNT_POINT"

# Wait for mount
sleep 2

# Apply Finder settings using AppleScript
echo "▸ Configuring Finder window..."
osascript << APPLESCRIPT
tell application "Finder"
    tell disk "$DMG_VOLUME_NAME"
        open
        delay 1
        
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {100, 100, $((100 + WINDOW_WIDTH)), $((100 + WINDOW_HEIGHT))}
        
        set theViewOptions to icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to $ICON_SIZE
APPLESCRIPT

if [[ "$USE_BACKGROUND" == "true" ]] && [[ -f "$MOUNT_POINT/.background/background.png" ]]; then
    osascript << APPLESCRIPT
tell application "Finder"
    tell disk "$DMG_VOLUME_NAME"
        set background picture of theViewOptions to file ".background:background.png"
    end tell
end tell
APPLESCRIPT
fi

osascript << APPLESCRIPT
tell application "Finder"
    tell disk "$DMG_VOLUME_NAME"
        -- Position icons
        set position of item "$APP_NAME.app" of container window to {$APP_ICON_X, $APP_ICON_Y}
        set position of item "Applications" of container window to {$APPS_ICON_X, $APPS_ICON_Y}
        
        -- Hide hidden files
        try
            set position of item ".background" of container window to {1000, 1000}
        end try
        try
            set position of item ".fseventsd" of container window to {1000, 1000}
        end try
        
        close
        open
        delay 1
        close
    end tell
end tell
APPLESCRIPT

# Sync and unmount
echo "▸ Finalizing..."
sync
hdiutil detach "$DEVICE" -quiet || hdiutil detach "$DEVICE" -force

# Convert to compressed, read-only DMG
echo "▸ Compressing DMG..."
hdiutil convert "$DMG_TEMP/temp.dmg" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$DMG_FINAL"

# Clean up
rm -rf "$DMG_TEMP"

# Verify
echo "▸ Verifying DMG..."
hdiutil verify "$DMG_FINAL" > /dev/null

# Show result
DMG_SIZE=$(du -h "$DMG_FINAL" | cut -f1)

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✓ DMG created successfully"
echo ""
echo "  File: $DMG_FINAL"
echo "  Size: $DMG_SIZE"
echo "═══════════════════════════════════════════════════════════════"
