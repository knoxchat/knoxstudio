#!/usr/bin/env bash
# KnoxStudio pre-commit quality gate.
# Commits are rejected unless format, clippy, and tests all pass.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRATE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$CRATE_DIR"

# rustc can overflow the default ~8MB stack while expanding GPUI/test macros.
if ulimit -s >/dev/null 2>&1; then
  ulimit -s 65520 2>/dev/null || ulimit -s unlimited 2>/dev/null || true
fi
export RUST_MIN_STACK="${RUST_MIN_STACK:-67108864}"

if [[ "${SKIP_QUALITY_GATE:-}" == "1" ]]; then
    echo "⚠ SKIP_QUALITY_GATE=1 — pre-commit cargo checks skipped"
    exit 0
fi

echo "══════════════════════════════════════════════════"
echo "  KnoxStudio pre-commit quality gate"
echo "══════════════════════════════════════════════════"
echo ""

echo "▸ cargo fmt -- --check"
cargo fmt -- --check
echo "  ✓ format"

echo ""
echo "▸ cargo clippy --all-targets -- -D warnings"
cargo clippy --all-targets -- -D warnings
echo "  ✓ clippy"

echo ""
echo "▸ cargo test --workspace"
cargo test --workspace
echo "  ✓ tests"

echo ""
echo "══════════════════════════════════════════════════"
echo "  ✓ Quality gate passed — commit allowed"
echo "══════════════════════════════════════════════════"
