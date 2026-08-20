#!/usr/bin/env bash
# KnoxStudio pre-commit quality gate.
# Commits are rejected unless format, clippy, and tests all pass.
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [[ "${SKIP_QUALITY_GATE:-}" == "1" ]]; then
    echo "⚠ SKIP_QUALITY_GATE=1 — pre-commit cargo checks skipped"
    exit 0
fi

echo "══════════════════════════════════════════════════"
echo "  KnoxStudio pre-commit quality gate"
echo "══════════════════════════════════════════════════"
echo ""

echo "▸ cargo fmt --all -- --check"
cargo fmt --all -- --check
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
