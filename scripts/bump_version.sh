#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# KnoxStudio Version Bumping Script
#
# Updates version in: Cargo.toml, Info.plist, CHANGELOG.md
# Creates git tag and prepares release notes
#
# Usage: ./scripts/bump_version.sh <major|minor|patch|VERSION>
#   Examples:
#     ./scripts/bump_version.sh patch     # 1.1.0 → 1.1.1
#     ./scripts/bump_version.sh minor     # 1.1.0 → 1.2.0
#     ./scripts/bump_version.sh major     # 1.1.0 → 2.0.0
#     ./scripts/bump_version.sh 2.0.0     # Set exact version
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ── Configuration ─────────────────────────────────────────────────────────────
CARGO_TOML="$ROOT_DIR/Cargo.toml"
INFO_PLIST="$ROOT_DIR/Info.plist"
CHANGELOG="$ROOT_DIR/CHANGELOG.md"
MAKEFILE="$ROOT_DIR/Makefile"
BUILD_DMG="$ROOT_DIR/build_dmg.sh"

# ── Helper Functions ──────────────────────────────────────────────────────────
get_current_version() {
    grep '^version = ' "$CARGO_TOML" | head -1 | sed 's/version = "\(.*\)"/\1/'
}

parse_version() {
    local version="$1"
    echo "$version" | awk -F. '{print $1, $2, $3}'
}

bump_version() {
    local current="$1"
    local bump_type="$2"
    
    read -r major minor patch <<< "$(parse_version "$current")"
    
    case "$bump_type" in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "$major.$((minor + 1)).0"
            ;;
        patch)
            echo "$major.$minor.$((patch + 1))"
            ;;
        *)
            # Assume it's an exact version
            echo "$bump_type"
            ;;
    esac
}

validate_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid version format '$version'. Expected X.Y.Z" >&2
        exit 1
    fi
}

update_cargo_toml() {
    local new_version="$1"
    sed -i '' "s/^version = \".*\"/version = \"$new_version\"/" "$CARGO_TOML"
    echo "  Updated Cargo.toml"
}

update_info_plist() {
    local new_version="$1"
    if [[ -f "$INFO_PLIST" ]]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $new_version" "$INFO_PLIST" 2>/dev/null || true
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_version" "$INFO_PLIST" 2>/dev/null || true
        echo "  Updated Info.plist"
    fi
}

update_makefile() {
    local new_version="$1"
    if [[ -f "$MAKEFILE" ]]; then
        sed -i '' "s/^VERSION := .*/VERSION := $new_version/" "$MAKEFILE"
        echo "  Updated Makefile"
    fi
}

update_build_dmg() {
    local new_version="$1"
    if [[ -f "$BUILD_DMG" ]]; then
        sed -i '' "s/^VERSION=\".*\"/VERSION=\"$new_version\"/" "$BUILD_DMG"
        echo "  Updated build_dmg.sh"
    fi
}

update_changelog() {
    local new_version="$1"
    local release_date
    release_date=$(date +%Y-%m-%d)
    
    if [[ -f "$CHANGELOG" ]]; then
        # Create new section at the top (after header)
        local temp_file
        temp_file=$(mktemp)
        
        {
            echo "# Changelog"
            echo ""
            echo "All notable changes to KnoxStudio will be documented in this file."
            echo ""
            echo "## [$new_version] - $release_date"
            echo ""
            echo "### Added"
            echo "- "
            echo ""
            echo "### Changed"
            echo "- "
            echo ""
            echo "### Fixed"
            echo "- "
            echo ""
            # Append existing content (skip the header if present)
            if grep -q "^## \[" "$CHANGELOG"; then
                sed -n '/^## \[/,$p' "$CHANGELOG"
            fi
        } > "$temp_file"
        
        mv "$temp_file" "$CHANGELOG"
        echo "  Updated CHANGELOG.md with new section"
    else
        # Create new CHANGELOG.md
        cat > "$CHANGELOG" << EOF
# Changelog

All notable changes to KnoxStudio will be documented in this file.

## [$new_version] - $release_date

### Added
- 

### Changed
- 

### Fixed
- 

EOF
        echo "  Created CHANGELOG.md"
    fi
}

create_git_tag() {
    local new_version="$1"
    local tag_name="v$new_version"
    
    read -p "Create git tag '$tag_name'? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add "$CARGO_TOML" "$MAKEFILE"
        [[ -f "$INFO_PLIST" ]] && git add "$INFO_PLIST"
        [[ -f "$BUILD_DMG" ]] && git add "$BUILD_DMG"
        [[ -f "$CHANGELOG" ]] && git add "$CHANGELOG"
        
        git commit -m "chore: bump version to $new_version"
        git tag -a "$tag_name" -m "Release $new_version"
        echo "  Created git tag: $tag_name"
        echo ""
        echo "  To push: git push origin main --tags"
    else
        echo "  Skipped git tag creation"
        echo "  Files have been updated. Commit manually when ready."
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <major|minor|patch|VERSION>"
    echo ""
    echo "Examples:"
    echo "  $0 patch     # Bump patch version"
    echo "  $0 minor     # Bump minor version"
    echo "  $0 major     # Bump major version"
    echo "  $0 2.0.0     # Set exact version"
    exit 1
fi

BUMP_TYPE="$1"
CURRENT_VERSION=$(get_current_version)
NEW_VERSION=$(bump_version "$CURRENT_VERSION" "$BUMP_TYPE")

validate_version "$NEW_VERSION"

echo "═══════════════════════════════════════════════════════════════"
echo "  KnoxStudio Version Bump"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Current version: $CURRENT_VERSION"
echo "  New version:     $NEW_VERSION"
echo ""

read -p "Proceed with version bump? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "▸ Updating version in files..."

update_cargo_toml "$NEW_VERSION"
update_info_plist "$NEW_VERSION"
update_makefile "$NEW_VERSION"
update_build_dmg "$NEW_VERSION"
update_changelog "$NEW_VERSION"

echo ""
echo "▸ Version files updated successfully!"
echo ""

create_git_tag "$NEW_VERSION"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✓ Version bumped to $NEW_VERSION"
echo "═══════════════════════════════════════════════════════════════"
