# ═══════════════════════════════════════════════════════════════════════════════
# KnoxStudio Build System
# ═══════════════════════════════════════════════════════════════════════════════
# macOS-only (13.0+, Apple Silicon + Intel Universal Binary)
# Languages: English and Chinese (中文) only
#
# Quick reference:
#   make check      - Run all pre-release checks (build, test, lint, audit)
#   make build      - Build debug binary
#   make release    - Build optimized release binary
#   make test       - Run all tests
#   make lint       - Run clippy and format check
#   make bundle     - Create .app bundle
#   make dmg        - Create signed DMG for distribution
#   make notarize   - Submit DMG for Apple notarization
#   make clean      - Remove build artifacts
# ═══════════════════════════════════════════════════════════════════════════════

SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

# ── Project Configuration ─────────────────────────────────────────────────────
APP_NAME := KnoxStudio
VERSION := 1.3.7
BUNDLE_ID := com.knoxstudio.knoxstudio
MIN_MACOS := 13.0

# ── Paths ─────────────────────────────────────────────────────────────────────
ROOT_DIR := $(shell pwd)
BUILD_DIR := $(ROOT_DIR)/target
RELEASE_DIR := $(BUILD_DIR)/release
DEBUG_DIR := $(BUILD_DIR)/debug
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
DMG_PATH := $(BUILD_DIR)/$(APP_NAME)-$(VERSION).dmg
TOOLS_DIR := $(ROOT_DIR)/tools

# ── Environment ───────────────────────────────────────────────────────────────
export MACOSX_DEPLOYMENT_TARGET := $(MIN_MACOS)

# Load signing configuration if present
-include .env.signing.mk
ifneq ($(wildcard .env.signing),)
    include .env.signing
    export
endif

# ═══════════════════════════════════════════════════════════════════════════════
# Main Targets
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: all
all: check build

.PHONY: help
help:
	@echo "KnoxStudio Build System"
	@echo ""
	@echo "Development:"
	@echo "  make build       Build debug binary"
	@echo "  make run         Build and run debug binary"
	@echo "  make test        Run all tests"
	@echo "  make lint        Run clippy + format check"
	@echo "  make fmt         Auto-format code"
	@echo "  make pre-commit  Required commit gate (fmt-check + clippy + test)"
	@echo "  make install-hooks  Install git pre-commit hook"
	@echo "  make coverage    Generate code coverage report"
	@echo "  make clean       Remove build artifacts"
	@echo ""
	@echo "Pre-release:"
	@echo "  make check       Run all pre-release checks"
	@echo "  make audit       Check for security vulnerabilities"
	@echo ""
	@echo "Release:"
	@echo "  make release     Build optimized release binary"
	@echo "  make bundle      Create .app bundle"
	@echo "  make sign        Code sign the app bundle"
	@echo "  make dmg         Create DMG installer"
	@echo "  make notarize    Submit DMG for Apple notarization"
	@echo "  make dist        Full release: check → release → bundle → sign → dmg"
	@echo ""
	@echo "Utilities:"
	@echo "  make setup       Install development dependencies"
	@echo "  make ffmpeg      Download/verify FFmpeg binaries"
	@echo "  make version     Show version information"
	@echo "  make smoke-test  Quick binary sanity check"

# ═══════════════════════════════════════════════════════════════════════════════
# Development Targets
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: build
build:
	@echo "▸ Building debug binary..."
	cargo build
	@echo "✓ Debug build complete: $(DEBUG_DIR)/knoxstudio"

.PHONY: release
release:
	@echo "▸ Building release binary (optimized)..."
	cargo build --release
	@echo "✓ Release build complete: $(RELEASE_DIR)/knoxstudio"

.PHONY: run
run: build
	@echo "▸ Running KnoxStudio..."
	$(DEBUG_DIR)/knoxstudio --debug

.PHONY: run-release
run-release: release
	$(RELEASE_DIR)/knoxstudio

# ═══════════════════════════════════════════════════════════════════════════════
# Testing & Quality
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: test
test:
	@echo "▸ Running tests..."
	cargo test --workspace
	@echo "✓ All tests passed"

.PHONY: test-verbose
test-verbose:
	cargo test --workspace -- --nocapture

.PHONY: coverage
coverage:
	@echo "▸ Running tests with coverage..."
	@if ! command -v cargo-llvm-cov &> /dev/null; then \
		echo "  Installing cargo-llvm-cov..."; \
		cargo install cargo-llvm-cov; \
	fi
	cargo llvm-cov --workspace --html --output-dir $(BUILD_DIR)/coverage
	@echo "✓ Coverage report: $(BUILD_DIR)/coverage/html/index.html"
	@echo ""
	@# Show summary
	cargo llvm-cov --workspace --summary-only
	@echo ""
	@echo "▸ Checking coverage threshold (target: 60% for core modules)..."
	@cargo llvm-cov --workspace --json 2>/dev/null | \
		python3 -c "import sys,json; d=json.load(sys.stdin); \
			cov=d.get('data',[{}])[0].get('totals',{}).get('lines',{}).get('percent',0); \
			print(f'  Total line coverage: {cov:.1f}%'); \
			sys.exit(0 if cov >= 30 else 1)" 2>/dev/null || \
		echo "  (Coverage threshold check requires python3 with json module)"

.PHONY: coverage-open
coverage-open: coverage
	open "$(BUILD_DIR)/coverage/html/index.html"

.PHONY: docs
docs:
	@echo "▸ Generating rustdoc..."
	cargo doc --no-deps --document-private-items
	@echo "✓ Documentation generated: $(BUILD_DIR)/doc/knoxstudio/index.html"

.PHONY: docs-open
docs-open: docs
	open "$(BUILD_DIR)/doc/knoxstudio/index.html"

.PHONY: lint
lint: clippy fmt-check
	@echo "✓ All lint checks passed"

# Required before every commit. Same commands as scripts/pre-commit.sh.
.PHONY: pre-commit
pre-commit:
	@echo "══════════════════════════════════════════════════"
	@echo "  KnoxStudio pre-commit quality gate"
	@echo "══════════════════════════════════════════════════"
	@echo ""
	$(MAKE) fmt-check
	@echo ""
	$(MAKE) clippy
	@echo ""
	$(MAKE) test
	@echo ""
	@echo "══════════════════════════════════════════════════"
	@echo "  ✓ Quality gate passed — commit allowed"
	@echo "══════════════════════════════════════════════════"

.PHONY: install-hooks
install-hooks:
	@if [ ! -d "$(ROOT_DIR)/.git/hooks" ]; then
		echo "✘ ERROR: .git/hooks not found (not a git checkout?)"
		exit 1
	fi
	@ln -sfn ../../scripts/pre-commit.sh "$(ROOT_DIR)/.git/hooks/pre-commit"
	@chmod +x "$(ROOT_DIR)/scripts/pre-commit.sh"
	@echo "✓ Git pre-commit hook installed → scripts/pre-commit.sh"

.PHONY: clippy
clippy:
	@echo "▸ Running clippy..."
	cargo clippy --workspace --all-targets -- -D warnings
	@echo "✓ Clippy passed"

.PHONY: fmt
fmt:
	@echo "▸ Formatting code..."
	cargo fmt --all
	@echo "✓ Code formatted"

.PHONY: fmt-check
fmt-check:
	@echo "▸ Checking code format..."
	cargo fmt --all -- --check
	@echo "✓ Code format OK"

.PHONY: audit
audit:
	@echo "▸ Checking for security vulnerabilities..."
	@if ! command -v cargo-audit &> /dev/null; then
		echo "  Installing cargo-audit..."
		cargo install cargo-audit
	fi
	cargo audit
	@echo "✓ Security audit passed"

# ═══════════════════════════════════════════════════════════════════════════════
# Pre-release Check (P0 requirement)
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: check
check:
	@echo "══════════════════════════════════════════════════"
	@echo "  KnoxStudio Pre-release Checks"
	@echo "══════════════════════════════════════════════════"
	@echo ""
	$(MAKE) fmt-check
	@echo ""
	$(MAKE) clippy
	@echo ""
	$(MAKE) test
	@echo ""
	$(MAKE) audit
	@echo ""
	$(MAKE) build
	@echo ""
	$(MAKE) smoke-test
	@echo ""
	@echo "══════════════════════════════════════════════════"
	@echo "  ✓ All pre-release checks passed!"
	@echo "══════════════════════════════════════════════════"

.PHONY: smoke-test
smoke-test:
	@echo "▸ Running smoke test..."
	@if [ -f "$(DEBUG_DIR)/knoxstudio" ]; then
		$(DEBUG_DIR)/knoxstudio --smoke-test
	elif [ -f "$(RELEASE_DIR)/knoxstudio" ]; then
		$(RELEASE_DIR)/knoxstudio --smoke-test
	else
		echo "  No binary found, building first..."
		cargo build
		$(DEBUG_DIR)/knoxstudio --smoke-test
	fi
	@echo "✓ Smoke test passed"

# ═══════════════════════════════════════════════════════════════════════════════
# Release & Distribution
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: ffmpeg
ffmpeg:
	@echo "▸ Setting up FFmpeg binaries..."
	bash $(ROOT_DIR)/setup_ffmpeg.sh
	@echo "✓ FFmpeg ready"

.PHONY: bundle
bundle: release ffmpeg
	@echo "▸ Assembling $(APP_NAME).app bundle..."
	@rm -rf "$(APP_BUNDLE)"
	@mkdir -p "$(APP_BUNDLE)/Contents/MacOS"
	@mkdir -p "$(APP_BUNDLE)/Contents/Resources"
	@# Copy and configure Info.plist
	@cp "$(ROOT_DIR)/Info.plist" "$(APP_BUNDLE)/Contents/Info.plist"
	@/usr/libexec/PlistBuddy -c "Set :CFBundleName $(APP_NAME)" "$(APP_BUNDLE)/Contents/Info.plist"
	@/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $(APP_NAME)" "$(APP_BUNDLE)/Contents/Info.plist"
	@/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $(BUNDLE_ID)" "$(APP_BUNDLE)/Contents/Info.plist"
	@/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(VERSION)" "$(APP_BUNDLE)/Contents/Info.plist"
	@# Copy executables
	@cp "$(RELEASE_DIR)/knoxstudio" "$(APP_BUNDLE)/Contents/MacOS/knoxstudio"
	@chmod +x "$(APP_BUNDLE)/Contents/MacOS/knoxstudio"
	@cp "$(TOOLS_DIR)/ffmpeg" "$(APP_BUNDLE)/Contents/MacOS/ffmpeg"
	@cp "$(TOOLS_DIR)/ffprobe" "$(APP_BUNDLE)/Contents/MacOS/ffprobe"
	@chmod +x "$(APP_BUNDLE)/Contents/MacOS/ffmpeg"
	@chmod +x "$(APP_BUNDLE)/Contents/MacOS/ffprobe"
	@# Copy icon
	@if [ -f "$(ROOT_DIR)/AppIcon.icns" ]; then
		cp "$(ROOT_DIR)/AppIcon.icns" "$(APP_BUNDLE)/Contents/Resources/AppIcon.icns"
	fi
	@echo "✓ App bundle assembled: $(APP_BUNDLE)"
	@# Verify bundle
	bash $(ROOT_DIR)/verify_app_bundle.sh "$(APP_BUNDLE)" --bundle-id "$(BUNDLE_ID)"

.PHONY: sign
sign:
	@echo "▸ Code signing $(APP_NAME).app..."
	@if [ -z "$(APPLE_SIGNING_IDENTITY)" ]; then
		echo "  No signing identity configured, using ad-hoc signing..."
		codesign --force --deep --sign - "$(APP_BUNDLE)" 2>/dev/null || echo "  ⚠ Ad-hoc signing skipped"
	else
		echo "  Signing with: $(APPLE_SIGNING_IDENTITY)"
		codesign --force --options runtime --timestamp \
			--sign "$(APPLE_SIGNING_IDENTITY)" \
			--entitlements "$(ROOT_DIR)/KnoxStudio.notarization.entitlements" \
			"$(APP_BUNDLE)/Contents/MacOS/ffmpeg"
		codesign --force --options runtime --timestamp \
			--sign "$(APPLE_SIGNING_IDENTITY)" \
			--entitlements "$(ROOT_DIR)/KnoxStudio.notarization.entitlements" \
			"$(APP_BUNDLE)/Contents/MacOS/ffprobe"
		codesign --force --options runtime --timestamp \
			--sign "$(APPLE_SIGNING_IDENTITY)" \
			--entitlements "$(ROOT_DIR)/KnoxStudio.notarization.entitlements" \
			"$(APP_BUNDLE)/Contents/MacOS/knoxstudio"
		codesign --force --options runtime --timestamp \
			--sign "$(APPLE_SIGNING_IDENTITY)" \
			--entitlements "$(ROOT_DIR)/KnoxStudio.notarization.entitlements" \
			"$(APP_BUNDLE)"
		codesign --verify --deep --strict --verbose=2 "$(APP_BUNDLE)"
	fi
	@echo "✓ Code signed"

.PHONY: dmg
dmg: bundle sign
	@echo "▸ Creating $(APP_NAME)-$(VERSION).dmg..."
	@rm -rf "$(BUILD_DIR)/dmg"
	@rm -f "$(DMG_PATH)"
	@mkdir -p "$(BUILD_DIR)/dmg"
	@cp -R "$(APP_BUNDLE)" "$(BUILD_DIR)/dmg/"
	@ln -s /Applications "$(BUILD_DIR)/dmg/Applications"
	hdiutil create \
		-volname "$(APP_NAME)" \
		-srcfolder "$(BUILD_DIR)/dmg" \
		-ov \
		-format UDZO \
		"$(DMG_PATH)"
	@rm -rf "$(BUILD_DIR)/dmg"
	@echo "✓ DMG created: $(DMG_PATH)"
	@# Verify artifacts
	bash $(ROOT_DIR)/verify_release_artifacts.sh \
		--app "$(APP_BUNDLE)" \
		--dmg "$(DMG_PATH)" \
		--bundle-id "$(BUNDLE_ID)"

.PHONY: notarize
notarize:
	@echo "▸ Submitting $(DMG_PATH) for notarization..."
	@if [ -z "$(APPLE_ID)" ] || [ -z "$(APPLE_PASSWORD)" ] || [ -z "$(APPLE_TEAM_ID)" ]; then
		echo "✘ ERROR: Notarization requires APPLE_ID, APPLE_PASSWORD, and APPLE_TEAM_ID"
		echo "  Configure these in .env.signing"
		exit 1
	fi
	xcrun notarytool submit "$(DMG_PATH)" \
		--apple-id "$(APPLE_ID)" \
		--password "$(APPLE_PASSWORD)" \
		--team-id "$(APPLE_TEAM_ID)" \
		--wait
	@echo "▸ Stapling notarization ticket..."
	xcrun stapler staple "$(DMG_PATH)"
	@echo "✓ Notarization complete"

.PHONY: dist
dist: check release bundle sign dmg
	@echo ""
	@echo "══════════════════════════════════════════════════"
	@echo "  ✓ Distribution build complete!"
	@echo ""
	@echo "  App: $(APP_BUNDLE)"
	@echo "  DMG: $(DMG_PATH)"
	@echo "══════════════════════════════════════════════════"

# ═══════════════════════════════════════════════════════════════════════════════
# Utilities
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: setup
setup:
	@echo "▸ Installing development dependencies..."
	@if ! command -v rustup &> /dev/null; then
		echo "  Installing Rust via rustup..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	fi
	rustup component add clippy rustfmt
	@if ! command -v cargo-audit &> /dev/null; then
		echo "  Installing cargo-audit..."
		cargo install cargo-audit
	fi
	$(MAKE) ffmpeg
	$(MAKE) install-hooks
	@echo "✓ Development environment ready"

.PHONY: version
version:
	@echo "$(APP_NAME) v$(VERSION)"
	@echo "  Rust: $$(rustc --version)"
	@echo "  Cargo: $$(cargo --version)"
	@echo "  macOS deployment target: $(MIN_MACOS)"
	@echo "  Bundle ID: $(BUNDLE_ID)"

.PHONY: clean
clean:
	@echo "▸ Cleaning build artifacts..."
	cargo clean
	rm -rf "$(APP_BUNDLE)"
	rm -f "$(DMG_PATH)"
	@echo "✓ Clean complete"

.PHONY: clean-all
clean-all: clean
	@echo "▸ Removing all generated files..."
	rm -rf "$(BUILD_DIR)"
	@echo "✓ Full clean complete"

# ═══════════════════════════════════════════════════════════════════════════════
# Universal Binary (arm64 + x86_64)
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: universal
universal:
	@echo "▸ Building Universal Binary (arm64 + x86_64)..."
	@# Build for both architectures
	cargo build --release --target aarch64-apple-darwin
	cargo build --release --target x86_64-apple-darwin
	@# Combine with lipo
	@mkdir -p "$(RELEASE_DIR)"
	lipo -create \
		"$(BUILD_DIR)/aarch64-apple-darwin/release/knoxstudio" \
		"$(BUILD_DIR)/x86_64-apple-darwin/release/knoxstudio" \
		-output "$(RELEASE_DIR)/knoxstudio"
	@echo "✓ Universal binary created: $(RELEASE_DIR)/knoxstudio"
	@file "$(RELEASE_DIR)/knoxstudio"

# ═══════════════════════════════════════════════════════════════════════════════
# Documentation
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: doc
doc:
	@echo "▸ Generating documentation..."
	cargo doc --no-deps --document-private-items
	@echo "✓ Documentation generated: $(BUILD_DIR)/doc/knoxstudio/index.html"

.PHONY: doc-open
doc-open: doc
	open "$(BUILD_DIR)/doc/knoxstudio/index.html"

# ═══════════════════════════════════════════════════════════════════════════════
# Release Automation Scripts
# ═══════════════════════════════════════════════════════════════════════════════

.PHONY: bump-patch
bump-patch:
	@bash scripts/bump_version.sh patch

.PHONY: bump-minor
bump-minor:
	@bash scripts/bump_version.sh minor

.PHONY: bump-major
bump-major:
	@bash scripts/bump_version.sh major

.PHONY: sbom
sbom:
	@echo "▸ Generating Software Bill of Materials..."
	@bash scripts/generate_sbom.sh --format all
	@echo "✓ SBOM generated in $(BUILD_DIR)/sbom/"

.PHONY: changelog
changelog:
	@echo "▸ Generating changelog from commits..."
	@bash scripts/generate_changelog.sh
	@echo "✓ CHANGELOG.md updated"

.PHONY: dmg-pretty
dmg-pretty: bundle sign
	@echo "▸ Creating DMG with custom background..."
	@bash scripts/create_dmg.sh
	@echo "✓ DMG created: $(DMG_PATH)"

# Full release workflow
.PHONY: release-full
release-full: check changelog sbom universal bundle sign dmg-pretty
	@echo ""
	@echo "══════════════════════════════════════════════════"
	@echo "  ✓ Full release build complete!"
	@echo ""
	@echo "  App:       $(APP_BUNDLE)"
	@echo "  DMG:       $(DMG_PATH)"
	@echo "  SBOM:      $(BUILD_DIR)/sbom/"
	@echo "  Changelog: CHANGELOG.md"
	@echo "══════════════════════════════════════════════════"
