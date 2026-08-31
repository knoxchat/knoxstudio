#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Generate latest.json for in-app auto-update.
#
# This file is a GitHub *Release asset*, like the .dmg — not a file in the
# knoxchat/knoxstudio git repo. After ./build_dmg.sh, attach it on the same
# release as KnoxStudio-VERSION.dmg. The app then fetches:
#
#   https://github.com/knoxchat/knoxstudio/releases/latest/download/latest.json
#
# Usage:
#   ./build_dmg.sh                          # generates target/latest.json
#   ./scripts/generate_update_feed.sh [path/to/KnoxStudio-VERSION.dmg]
#   make update-feed
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

VERSION=$(grep '^version = ' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
DMG_PATH="${1:-$ROOT_DIR/target/KnoxStudio-${VERSION}.dmg}"
OUT_PATH="${2:-$ROOT_DIR/target/latest.json}"
REPO="knoxchat/knoxstudio"

if [[ ! -f "$DMG_PATH" ]]; then
    echo "Error: DMG not found at $DMG_PATH" >&2
    echo "Run './build_dmg.sh' first." >&2
    exit 1
fi

DMG_NAME="$(basename "$DMG_PATH")"
SHA256=$(shasum -a 256 "$DMG_PATH" | awk '{print $1}')
SIZE=$(stat -f%z "$DMG_PATH" 2>/dev/null || stat -c%s "$DMG_PATH")
HTML_URL="https://github.com/${REPO}/releases/tag/v${VERSION}"
DMG_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${DMG_NAME}"

CHANGELOG="$ROOT_DIR/CHANGELOG.md"
NOTES=""
if [[ -f "$CHANGELOG" ]]; then
    NOTES=$(python3 - "$CHANGELOG" "$VERSION" <<'PY'
import re, sys
path, version = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
pattern = rf"^## \[{re.escape(version)}\][^\n]*\n(.*?)(?=^## \[|\Z)"
m = re.search(pattern, text, re.M | re.S)
print(m.group(1).strip() if m else "")
PY
)
fi

mkdir -p "$(dirname "$OUT_PATH")"

python3 - "$OUT_PATH" "$VERSION" "$NOTES" "$HTML_URL" "$DMG_URL" "$SHA256" "$SIZE" <<'PY'
import json, sys
out, version, notes, html_url, dmg_url, sha256, size = sys.argv[1:]
feed = {
    "version": version,
    "notes": notes,
    "html_url": html_url,
    "dmg": {
        "url": dmg_url,
        "sha256": sha256,
        "size": int(size),
    },
}
with open(out, "w", encoding="utf-8") as f:
    json.dump(feed, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY

echo "═══════════════════════════════════════════════════════════════"
echo "  ✓ Update feed written"
echo ""
echo "  File:   $OUT_PATH"
echo "  Version $VERSION"
echo "  SHA256  $SHA256"
echo "  Size    $SIZE bytes"
if [[ "${UPDATE_FEED_QUIET:-}" != "1" ]]; then
    echo ""
    echo "  Attach BOTH as GitHub Release assets (not git commits):"
    echo "    $DMG_PATH"
    echo "    $OUT_PATH"
    echo ""
    echo "  gh release upload v${VERSION} \\"
    echo "    \"$DMG_PATH\" \"$OUT_PATH\" \\"
    echo "    --repo knoxchat/knoxstudio --clobber"
fi
echo "═══════════════════════════════════════════════════════════════"
