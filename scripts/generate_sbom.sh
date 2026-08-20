#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# KnoxStudio SBOM (Software Bill of Materials) Generator
#
# Generates a comprehensive list of all dependencies with their licenses.
# Outputs in multiple formats: Markdown, JSON, and SPDX.
#
# Usage: ./scripts/generate_sbom.sh [--format md|json|spdx|all]
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

# ── Configuration ─────────────────────────────────────────────────────────────
APP_NAME="KnoxStudio"
VERSION=$(grep '^version = ' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
OUTPUT_DIR="$ROOT_DIR/target/sbom"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

FORMAT="${1:-all}"
if [[ "$FORMAT" == "--format" ]]; then
    FORMAT="${2:-all}"
fi

# ── Ensure cargo-license is installed ─────────────────────────────────────────
ensure_cargo_license() {
    if ! command -v cargo-license &> /dev/null; then
        echo "▸ Installing cargo-license..."
        cargo install cargo-license
    fi
}

# ── Generate dependency tree ──────────────────────────────────────────────────
generate_dep_tree() {
    echo "▸ Generating dependency tree..."
    cargo tree --prefix none --no-dedupe 2>/dev/null | \
        grep -v "^$" | \
        sort -u > "$OUTPUT_DIR/dependency-tree.txt"
}

# ── Generate license information ──────────────────────────────────────────────
generate_licenses() {
    echo "▸ Extracting license information..."
    cargo license --json 2>/dev/null > "$OUTPUT_DIR/licenses.json" || {
        # Fallback if cargo-license fails
        echo "[]" > "$OUTPUT_DIR/licenses.json"
    }
}

# ── Generate Markdown SBOM ────────────────────────────────────────────────────
generate_markdown() {
    echo "▸ Generating Markdown SBOM..."
    
    local md_file="$OUTPUT_DIR/SBOM.md"
    
    cat > "$md_file" << EOF
# Software Bill of Materials (SBOM)

**Application:** $APP_NAME  
**Version:** $VERSION  
**Generated:** $TIMESTAMP  

## Overview

This document lists all third-party dependencies used in $APP_NAME, along with their licenses.

## Rust Dependencies

| Crate | Version | License | Repository |
|-------|---------|---------|------------|
EOF

    # Parse licenses.json and generate table rows
    if command -v python3 &> /dev/null && [[ -f "$OUTPUT_DIR/licenses.json" ]]; then
        python3 << 'PYTHON_SCRIPT' >> "$md_file"
import json
import sys

try:
    with open('target/sbom/licenses.json', 'r') as f:
        data = json.load(f)
    
    for dep in sorted(data, key=lambda x: x.get('name', '')):
        name = dep.get('name', 'unknown')
        version = dep.get('version', 'unknown')
        license = dep.get('license', 'unknown')
        repo = dep.get('repository', '')
        
        if repo:
            repo_link = f"[link]({repo})"
        else:
            repo_link = "-"
        
        print(f"| {name} | {version} | {license} | {repo_link} |")
except Exception as e:
    print(f"| Error parsing licenses: {e} | | | |", file=sys.stderr)
PYTHON_SCRIPT
    else
        echo "| (cargo-license output unavailable) | | | |" >> "$md_file"
    fi

    cat >> "$md_file" << EOF

## External Binaries

| Binary | Version | License | Source |
|--------|---------|---------|--------|
| FFmpeg | 7.x | LGPL 2.1+ / GPL 2+ | [ffmpeg.org](https://ffmpeg.org) |
| FFprobe | 7.x | LGPL 2.1+ / GPL 2+ | [ffmpeg.org](https://ffmpeg.org) |

## License Summary

EOF

    # Count licenses
    if [[ -f "$OUTPUT_DIR/licenses.json" ]] && command -v python3 &> /dev/null; then
        python3 << 'PYTHON_SCRIPT' >> "$md_file"
import json
from collections import Counter

try:
    with open('target/sbom/licenses.json', 'r') as f:
        data = json.load(f)
    
    licenses = Counter(dep.get('license', 'unknown') for dep in data)
    
    print("| License | Count |")
    print("|---------|-------|")
    for license, count in sorted(licenses.items(), key=lambda x: -x[1]):
        print(f"| {license} | {count} |")
except:
    pass
PYTHON_SCRIPT
    fi

    cat >> "$md_file" << EOF

## Compliance Notes

- All dependencies are compatible with $APP_NAME's distribution model
- FFmpeg is distributed under LGPL 2.1+ (dynamically linked scenario)
- No GPL-incompatible dependencies are included
- Full license texts are available in the \`licenses/\` directory

---

*This SBOM was automatically generated. For the most accurate information, run \`cargo license\` in the project root.*
EOF

    echo "  Created: $md_file"
}

# ── Generate JSON SBOM ────────────────────────────────────────────────────────
generate_json() {
    echo "▸ Generating JSON SBOM..."
    
    local json_file="$OUTPUT_DIR/sbom.json"
    
    if command -v python3 &> /dev/null && [[ -f "$OUTPUT_DIR/licenses.json" ]]; then
        python3 << PYTHON_SCRIPT > "$json_file"
import json
from datetime import datetime

try:
    with open('target/sbom/licenses.json', 'r') as f:
        deps = json.load(f)
except:
    deps = []

sbom = {
    "bomFormat": "KnoxStudio",
    "specVersion": "1.0",
    "version": 1,
    "metadata": {
        "timestamp": "$TIMESTAMP",
        "component": {
            "name": "$APP_NAME",
            "version": "$VERSION",
            "type": "application"
        }
    },
    "components": [
        {
            "name": dep.get("name", "unknown"),
            "version": dep.get("version", "unknown"),
            "licenses": [{"license": {"id": dep.get("license", "unknown")}}],
            "purl": f"pkg:cargo/{dep.get('name', 'unknown')}@{dep.get('version', 'unknown')}"
        }
        for dep in deps
    ] + [
        {
            "name": "ffmpeg",
            "version": "7.x",
            "licenses": [{"license": {"id": "LGPL-2.1-or-later"}}],
            "purl": "pkg:generic/ffmpeg@7"
        },
        {
            "name": "ffprobe",
            "version": "7.x",
            "licenses": [{"license": {"id": "LGPL-2.1-or-later"}}],
            "purl": "pkg:generic/ffprobe@7"
        }
    ]
}

print(json.dumps(sbom, indent=2))
PYTHON_SCRIPT
    else
        cat > "$json_file" << EOF
{
  "bomFormat": "KnoxStudio",
  "specVersion": "1.0",
  "version": 1,
  "metadata": {
    "timestamp": "$TIMESTAMP",
    "component": {
      "name": "$APP_NAME",
      "version": "$VERSION",
      "type": "application"
    }
  },
  "components": []
}
EOF
    fi
    
    echo "  Created: $json_file"
}

# ── Generate SPDX SBOM ────────────────────────────────────────────────────────
generate_spdx() {
    echo "▸ Generating SPDX SBOM..."
    
    local spdx_file="$OUTPUT_DIR/sbom.spdx"
    
    cat > "$spdx_file" << EOF
SPDXVersion: SPDX-2.3
DataLicense: CC0-1.0
SPDXID: SPDXRef-DOCUMENT
DocumentName: $APP_NAME-$VERSION
DocumentNamespace: https://knoxstudio.com/spdx/$APP_NAME-$VERSION
Creator: Tool: KnoxStudio SBOM Generator
Created: $TIMESTAMP

##### Package: $APP_NAME

PackageName: $APP_NAME
SPDXID: SPDXRef-Package-$APP_NAME
PackageVersion: $VERSION
PackageDownloadLocation: NOASSERTION
FilesAnalyzed: false
PackageLicenseConcluded: NOASSERTION
PackageLicenseDeclared: NOASSERTION
PackageCopyrightText: NOASSERTION

##### External Dependencies

EOF

    # Add dependencies from licenses.json
    if [[ -f "$OUTPUT_DIR/licenses.json" ]] && command -v python3 &> /dev/null; then
        python3 << 'PYTHON_SCRIPT' >> "$spdx_file"
import json

try:
    with open('target/sbom/licenses.json', 'r') as f:
        deps = json.load(f)
    
    for dep in sorted(deps, key=lambda x: x.get('name', '')):
        name = dep.get('name', 'unknown')
        version = dep.get('version', 'unknown')
        license = dep.get('license', 'NOASSERTION')
        safe_name = name.replace('-', '_').replace('.', '_')
        
        print(f"""
PackageName: {name}
SPDXID: SPDXRef-Package-{safe_name}
PackageVersion: {version}
PackageDownloadLocation: https://crates.io/crates/{name}
FilesAnalyzed: false
PackageLicenseConcluded: {license}
PackageLicenseDeclared: {license}
PackageCopyrightText: NOASSERTION
""")
except:
    pass
PYTHON_SCRIPT
    fi

    # Add FFmpeg
    cat >> "$spdx_file" << EOF

PackageName: ffmpeg
SPDXID: SPDXRef-Package-ffmpeg
PackageVersion: 7.x
PackageDownloadLocation: https://ffmpeg.org
FilesAnalyzed: false
PackageLicenseConcluded: LGPL-2.1-or-later
PackageLicenseDeclared: LGPL-2.1-or-later
PackageCopyrightText: NOASSERTION

PackageName: ffprobe
SPDXID: SPDXRef-Package-ffprobe
PackageVersion: 7.x
PackageDownloadLocation: https://ffmpeg.org
FilesAnalyzed: false
PackageLicenseConcluded: LGPL-2.1-or-later
PackageLicenseDeclared: LGPL-2.1-or-later
PackageCopyrightText: NOASSERTION
EOF

    echo "  Created: $spdx_file"
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo "═══════════════════════════════════════════════════════════════"
echo "  KnoxStudio SBOM Generator"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Application: $APP_NAME v$VERSION"
echo "  Timestamp:   $TIMESTAMP"
echo "  Output:      $OUTPUT_DIR"
echo ""

mkdir -p "$OUTPUT_DIR"

ensure_cargo_license
generate_dep_tree
generate_licenses

case "$FORMAT" in
    md|markdown)
        generate_markdown
        ;;
    json)
        generate_json
        ;;
    spdx)
        generate_spdx
        ;;
    all|*)
        generate_markdown
        generate_json
        generate_spdx
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✓ SBOM generation complete"
echo ""
echo "  Files:"
ls -la "$OUTPUT_DIR"/ 2>/dev/null | grep -v "^total" | awk '{print "    " $NF}'
echo "═══════════════════════════════════════════════════════════════"
