#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# KnoxStudio Changelog Generator
#
# Generates CHANGELOG.md from conventional commit messages.
# Supports commit types: feat, fix, docs, style, refactor, perf, test, build, ci, chore
#
# Usage: ./scripts/generate_changelog.sh [--since TAG] [--output FILE]
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ── Configuration ─────────────────────────────────────────────────────────────
APP_NAME="KnoxStudio"
VERSION=$(grep '^version = ' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
OUTPUT_FILE="$ROOT_DIR/CHANGELOG.md"
SINCE_TAG=""
RELEASE_DATE=$(date +%Y-%m-%d)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --since)
            SINCE_TAG="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# If no tag specified, try to find the previous one
if [[ -z "$SINCE_TAG" ]]; then
    SINCE_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
fi

# ── Commit Type Mappings ──────────────────────────────────────────────────────
declare -A TYPE_HEADERS=(
    ["feat"]="Features"
    ["fix"]="Bug Fixes"
    ["docs"]="Documentation"
    ["style"]="Styling"
    ["refactor"]="Code Refactoring"
    ["perf"]="Performance Improvements"
    ["test"]="Tests"
    ["build"]="Build System"
    ["ci"]="CI/CD"
    ["chore"]="Maintenance"
    ["breaking"]="Breaking Changes"
)

declare -A TYPE_ORDER=(
    ["breaking"]=1
    ["feat"]=2
    ["fix"]=3
    ["perf"]=4
    ["refactor"]=5
    ["docs"]=6
    ["test"]=7
    ["build"]=8
    ["ci"]=9
    ["style"]=10
    ["chore"]=11
)

# ── Helper Functions ──────────────────────────────────────────────────────────
get_commits() {
    local range=""
    if [[ -n "$SINCE_TAG" ]]; then
        range="$SINCE_TAG..HEAD"
    fi
    
    git log $range --pretty=format:"%H|%s|%an" --no-merges 2>/dev/null || echo ""
}

parse_commit_type() {
    local subject="$1"
    
    # Check for breaking change indicator
    if [[ "$subject" == *"!"* ]] || [[ "$subject" =~ BREAKING[[:space:]]CHANGE ]]; then
        echo "breaking"
        return
    fi
    
    # Extract conventional commit type
    if [[ "$subject" =~ ^([a-z]+)(\([^)]+\))?:\ .+ ]]; then
        local type="${BASH_REMATCH[1]}"
        if [[ -n "${TYPE_HEADERS[$type]:-}" ]]; then
            echo "$type"
            return
        fi
    fi
    
    echo "chore"
}

parse_commit_scope() {
    local subject="$1"
    
    if [[ "$subject" =~ ^[a-z]+\(([^)]+)\):\ .+ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

parse_commit_message() {
    local subject="$1"
    
    # Remove type prefix
    local msg="$subject"
    msg=$(echo "$msg" | sed -E 's/^[a-z]+(\([^)]+\))?!?:[[:space:]]*//')
    
    # Capitalize first letter
    msg="$(echo "${msg:0:1}" | tr '[:lower:]' '[:upper:]')${msg:1}"
    
    echo "$msg"
}

# ── Generate Changelog ────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════"
echo "  Generating Changelog"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Version:    $VERSION"
echo "  Since:      ${SINCE_TAG:-"(all commits)"}"
echo "  Output:     $OUTPUT_FILE"
echo ""

# Collect commits by type
declare -A COMMITS_BY_TYPE

while IFS='|' read -r hash subject author; do
    [[ -z "$hash" ]] && continue
    
    type=$(parse_commit_type "$subject")
    scope=$(parse_commit_scope "$subject")
    message=$(parse_commit_message "$subject")
    
    # Format the entry
    short_hash="${hash:0:7}"
    if [[ -n "$scope" ]]; then
        entry="- **$scope:** $message ($short_hash)"
    else
        entry="- $message ($short_hash)"
    fi
    
    # Append to type array
    COMMITS_BY_TYPE[$type]+="$entry"$'\n'
    
done <<< "$(get_commits)"

# Generate the changelog
{
    echo "# Changelog"
    echo ""
    echo "All notable changes to $APP_NAME will be documented in this file."
    echo ""
    echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
    echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
    echo ""
    echo "## [$VERSION] - $RELEASE_DATE"
    echo ""
    
    # Output sections in order
    for type in breaking feat fix perf refactor docs test build ci style chore; do
        if [[ -n "${COMMITS_BY_TYPE[$type]:-}" ]]; then
            header="${TYPE_HEADERS[$type]}"
            echo "### $header"
            echo ""
            echo -n "${COMMITS_BY_TYPE[$type]}"
            echo ""
        fi
    done
    
    # Add previous changelog content if it exists
    if [[ -f "$OUTPUT_FILE" ]]; then
        echo ""
        echo "---"
        echo ""
        # Skip the header from the old changelog
        tail -n +7 "$OUTPUT_FILE" 2>/dev/null | grep -v "^# Changelog" | grep -v "^All notable" | grep -v "^The format" || true
    fi
    
} > "$OUTPUT_FILE.new"

mv "$OUTPUT_FILE.new" "$OUTPUT_FILE"

# Summary
TOTAL_COMMITS=$(get_commits | wc -l | tr -d ' ')
echo "▸ Processed $TOTAL_COMMITS commits"
echo ""

# Show section summary
echo "  Sections:"
for type in breaking feat fix perf refactor docs test build ci style chore; do
    if [[ -n "${COMMITS_BY_TYPE[$type]:-}" ]]; then
        count=$(echo -n "${COMMITS_BY_TYPE[$type]}" | grep -c "^-" || echo "0")
        header="${TYPE_HEADERS[$type]}"
        echo "    - $header: $count"
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✓ Changelog generated: $OUTPUT_FILE"
echo "═══════════════════════════════════════════════════════════════"
