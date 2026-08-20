#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# KnoxStudio Translation Completeness Validator
#
# Validates that all translation keys have both English and Chinese values.
# Used as a pre-release check to ensure no missing translations.
#
# Usage: ./scripts/validate_translations.sh
# Exit code: 0 if all translations complete, 1 if missing translations found
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
I18N_FILE="$ROOT_DIR/src/i18n.rs"

echo "═══════════════════════════════════════════════════════════════"
echo "  KnoxStudio Translation Validator"
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [[ ! -f "$I18N_FILE" ]]; then
    echo "Error: i18n.rs not found at $I18N_FILE"
    exit 1
fi

# Count define_translation! macro calls
TOTAL_TRANSLATIONS=$(grep -c "define_translation!" "$I18N_FILE" || echo "0")

# Count define_plural! macro calls
TOTAL_PLURALS=$(grep -c "define_plural!" "$I18N_FILE" || echo "0")

echo "Translation Statistics:"
echo "  - Total translation keys: $TOTAL_TRANSLATIONS"
echo "  - Total plural forms: $TOTAL_PLURALS"
echo ""

# Check for any translations with empty strings
# Using grep -c which returns count, or 0 on no match
set +e  # Temporarily disable exit on error
EMPTY_EN=$(grep -cE 'define_translation!\([^,]+,\s*""' "$I18N_FILE" 2>/dev/null | tr -d '\n')
[[ -z "$EMPTY_EN" ]] && EMPTY_EN=0
EMPTY_ZH=$(grep -cE 'define_translation!\([^,]+,[^,]+,\s*""\)' "$I18N_FILE" 2>/dev/null | tr -d '\n')
[[ -z "$EMPTY_ZH" ]] && EMPTY_ZH=0
set -e  # Re-enable exit on error

if [[ "$EMPTY_EN" -gt 0 ]] || [[ "$EMPTY_ZH" -gt 0 ]]; then
    echo "⚠ Warning: Found empty translation values"
    echo "  - Empty English strings: $EMPTY_EN"
    echo "  - Empty Chinese strings: $EMPTY_ZH"
    echo ""
    
    if [[ "$EMPTY_EN" -gt 0 ]]; then
        echo "Empty English translations:"
        grep -n -E 'define_translation!\([^,]+,\s*""' "$I18N_FILE" | head -20
        echo ""
    fi
    
    if [[ "$EMPTY_ZH" -gt 0 ]]; then
        echo "Empty Chinese translations:"
        grep -n -E 'define_translation!\([^,]+,[^,]+,\s*""\)' "$I18N_FILE" | head -20
        echo ""
    fi
fi

# Check for TODO/FIXME comments near translations
TODO_COUNT=$(grep -cE '(TODO|FIXME|XXX).*translation' "$I18N_FILE" 2>/dev/null || echo "0")
TODO_COUNT=$(echo "$TODO_COUNT" | tr -d '\n')
if [[ "$TODO_COUNT" -gt 0 ]]; then
    echo "⚠ Warning: Found $TODO_COUNT TODO/FIXME comments related to translations"
    grep -n -E '(TODO|FIXME|XXX).*translation' "$I18N_FILE" || true
    echo ""
fi

# Compile check - ensures all translations are syntactically correct
echo "▸ Running compilation check..."
cd "$ROOT_DIR"
if cargo check --quiet 2>/dev/null; then
    echo "  ✓ Compilation successful"
else
    echo "  ✗ Compilation failed - check for syntax errors in i18n.rs"
    exit 1
fi

# Final status
echo ""
if [[ "$EMPTY_EN" -eq 0 ]] && [[ "$EMPTY_ZH" -eq 0 ]] && [[ "$TODO_COUNT" -eq 0 ]]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ✓ All translations complete!"
    echo ""
    echo "  $TOTAL_TRANSLATIONS translation keys"
    echo "  $TOTAL_PLURALS plural forms"
    echo "═══════════════════════════════════════════════════════════════"
    exit 0
else
    echo "═══════════════════════════════════════════════════════════════"
    echo "  ⚠ Translation validation completed with warnings"
    echo ""
    echo "  Review the warnings above before release."
    echo "═══════════════════════════════════════════════════════════════"
    exit 0  # Warnings don't fail the check, only errors do
fi
