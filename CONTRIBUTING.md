# Contributing to KnoxStudio

Thank you for helping build KnoxStudio. This is a native **macOS-only** Rust app (egui / eframe + Swift FFI). Contributions are welcome as long as they keep the tree compiling cleanly and the quality gate green.

**A commit is not ready until every required Cargo check passes.** That is not optional. The same commands that maintainers run locally are the ones this document specifies, and they were confirmed on this repository with Rust **1.97.1**.

| Gate | Command | Confirmed |
|------|---------|-----------|
| Format | `cargo fmt --all -- --check` | Pass |
| Lint | `cargo clippy --all-targets -- -D warnings` | Pass |
| Tests | `cargo test --workspace` | 580 passed, 6 ignored, 0 failed |

Use `make pre-commit` (or the git hook installed by `make install-hooks`) so you cannot commit a red tree by accident.

Deeper architecture notes live in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Environment and release details live in [docs/DEVELOPER.md](docs/DEVELOPER.md) and [docs/test.md](docs/test.md). If those docs disagree with this file about **Rust version** or **pre-commit commands**, this file wins.

---

## Table of contents

1. [Code of conduct](#code-of-conduct)
2. [What you can contribute](#what-you-can-contribute)
3. [Prerequisites](#prerequisites)
4. [First-time setup](#first-time-setup)
5. [Repository map](#repository-map)
6. [Day-to-day development](#day-to-day-development)
7. [Required quality gate (before every commit)](#required-quality-gate-before-every-commit)
8. [What each check means](#what-each-check-means)
9. [Git hook](#git-hook)
10. [Testing](#testing)
11. [Code style](#code-style)
12. [Internationalization](#internationalization)
13. [Native Swift / FFI](#native-swift--ffi)
14. [Do not change without review](#do-not-change-without-review)
15. [Branch, commit, and pull request](#branch-commit-and-pull-request)
16. [Review checklist](#review-checklist)
17. [Troubleshooting](#troubleshooting)
18. [Maintainer-only work](#maintainer-only-work)

---

## Code of conduct

- Be precise and respectful in issues and reviews.
- Do not commit secrets, API keys, signing credentials, or user media.
- Do not add network calls, telemetry, or new AI providers without an explicit design discussion.
- Keep user-facing strings in **English and Simplified Chinese**.
- Prefer small, reviewable changes over large mixed refactors.

---

## What you can contribute

Good first areas:

- Bug fixes with a failing test (or a clear reproduction) before the fix
- Timeline, project model, export, and i18n unit tests
- Clippy / rustc warning cleanup (warnings are errors)
- Accessibility, keyboard shortcuts, and translation completeness
- Docs that match the current tree (`src/i18n/`, Rust 1.97.1, Makefile targets)

Talk to maintainers first for:

- New AI providers or changes to KnoxChat routing
- Changes under `vendor/winit-0.30.13/`
- Version bumps, changelog, signing, notarization, or DMG layout
- New system permissions or Info.plist keys

---

## Prerequisites

KnoxStudio does not build on Linux or Windows. You need a Mac.

| Requirement | Version / notes |
|-------------|-----------------|
| **macOS** | 13.0 Ventura or later (`MACOSX_DEPLOYMENT_TARGET=13.0`) |
| **Hardware** | Apple Silicon or Intel |
| **Xcode CLT** | Command Line Tools (or full Xcode). `swiftc` must be on `PATH` — `build.rs` compiles `src/native/*.swift` into `libnative_swift.a` |
| **Rust** | **1.97.1** exactly as pinned in `rust-toolchain.toml` and `Cargo.toml` `rust-version`. Edition **2024** |
| **Components** | `rustfmt`, `clippy` (installed by rustup from the toolchain file) |
| **FFmpeg / FFprobe** | Bundled via `make ffmpeg` / `setup_ffmpeg.sh` into `tools/` (gitignored). Integration tests use `tools/ffmpeg` when present, otherwise `PATH` |
| **Git** | For branches, hooks, and PRs |

Optional but useful:

| Tool | Why |
|------|-----|
| `cargo-audit` | `make audit` / `make check` (not part of the commit gate) |
| `cargo-llvm-cov` | `make coverage` |
| `cargo-watch` | Rebuild on save |

Confirm the toolchain after clone:

```bash
rustc --version    # rustc 1.97.1 (...)
cargo --version    # cargo 1.97.1 (...)
rustfmt --version
cargo clippy --version
xcode-select -p
swiftc --version
```

If `rustc` is not 1.97.1, rustup will install it from `rust-toolchain.toml` the next time you run `cargo` in this directory:

```bash
rustup show
rustup component add rustfmt clippy
```

---

## First-time setup

```bash
git clone <repository-url>
cd knox-studio

# Toolchain + clippy/rustfmt + bundled FFmpeg + git hook
make setup
make install-hooks
```

`make setup` installs rustup components, `cargo-audit` if missing, and FFmpeg binaries. `make install-hooks` links `.git/hooks/pre-commit` to `scripts/pre-commit.sh`.

Then prove the tree is healthy:

```bash
make pre-commit
```

That is the same gate a commit will run. First compile can take several minutes; later runs reuse `target/`.

Run the app:

```bash
make run                 # debug binary with --debug
cargo run -- --debug     # same
cargo run --release
```

CLI flags the binary understands:

| Flag | Effect |
|------|--------|
| `--debug` | Debug console / verbose diagnostics |
| `--log-level=<level>` | Runtime log level |
| `--smoke-test` | Print `KnoxStudio smoke test OK` and exit (used by `make smoke-test`) |

Screen Recording, Camera, and Microphone permissions are requested when you use those features. A debug `cargo run` binary is not the notarized `.app`; grant permissions to your terminal or the built binary if capture fails.

---

## Repository map

```
knox-studio/
├── Cargo.toml                 # package knoxstudio 1.3.7, edition 2024, rust-version 1.97.1
├── rust-toolchain.toml        # pins rustc 1.97.1 + rustfmt + clippy
├── Makefile                   # build, test, lint, bundle, release
├── build.rs                   # Swift FFI compile, macOS 13 deployment target
├── .cargo/config.toml         # MACOSX_DEPLOYMENT_TARGET=13.0
├── src/
│   ├── main.rs                # entry, fonts, --debug / --smoke-test
│   ├── app/                   # KnoxStudioApp, playback, clip/project ops
│   ├── project/               # timeline model, .knoxstudio bundle I/O
│   ├── ui/                    # egui panels (timeline, canvas, agent, inspector, …)
│   ├── ai/                    # Manager / Editor / Director, generators, memory
│   ├── export/                # FFmpeg export pipeline
│   ├── native/                # Swift sources + Rust FFI
│   ├── i18n/                  # EN / zh-Hans (define_translation!)
│   ├── media/                 # native video player wrapper
│   └── …                      # capture, history, integrity, waveform, …
├── tests/                     # integration tests + fixtures
├── benches/                   # criterion (cargo bench)
├── assets/                    # fonts, AI system prompts
├── vendor/winit-0.30.13/      # patched winit — do not drive-by format
├── scripts/                   # version, changelog, SBOM, pre-commit hook
├── tools/                     # bundled ffmpeg/ffprobe (not committed)
└── docs/                      # architecture, testing, developer notes
```

This is a **single package**, not a Cargo workspace. `--workspace` still works and is what the Makefile uses.

The `winit` crates.io dependency is patched to `vendor/winit-0.30.13` so macOS app-activation behavior stays correct for Info.plist / App Store. Do not bump winit or “clean up” that vendor tree in a feature PR.

---

## Day-to-day development

| Task | Command |
|------|---------|
| Debug build | `make build` or `cargo build` |
| Run | `make run` or `cargo run -- --debug` |
| Auto-format | `make fmt` or `cargo fmt --all` |
| Format check | `make fmt-check` or `cargo fmt --all -- --check` |
| Clippy (warnings = errors) | `make clippy` or `cargo clippy --all-targets -- -D warnings` |
| Tests | `make test` or `cargo test --workspace` |
| **Commit gate** | **`make pre-commit`** |
| Full pre-release | `make check` (fmt + clippy + test + audit + build + smoke-test) |
| Docs | `make docs` / `make docs-open` |
| Coverage | `make coverage` |
| Clean | `make clean` |

`make help` lists release/bundle targets. You do not need those for ordinary PRs.

Suggested loop:

1. Create a branch (see [Branch, commit, and pull request](#branch-commit-and-pull-request)).
2. Make a focused change. Add or update tests next to the code (`#[cfg(test)]`) or under `tests/`.
3. Add both English and Chinese strings for any new UI copy.
4. Run `cargo fmt --all` while iterating.
5. Before `git commit`, run `make pre-commit` (the hook will run it anyway).
6. Open a pull request only when the gate is green.

---

## Required quality gate (before every commit)

These three commands **must** succeed, in this order, on the files you are about to commit. They are the project’s definition of “Rust is clean.”

```bash
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings
cargo test --workspace
```

Equivalent Makefile target (preferred):

```bash
make pre-commit
```

`make lint` is format-check + clippy only. `make test` is tests only. `make check` is **stricter than a commit**: it also runs `cargo audit`, a debug build, and `--smoke-test`. Use `make check` before a pull request or release, not as a substitute for skipping the commit gate.

### Why these flags

| Flag | Why it is required |
|------|--------------------|
| `cargo fmt --all -- --check` | rustfmt must already have been applied. `--check` fails instead of rewriting, so CI and hooks stay deterministic. `--all` covers the package the same way the Makefile does. |
| `cargo clippy --all-targets -- -D warnings` | Lints **lib, bins, tests, benches, and examples**. `-D warnings` treats every clippy and rustc warning as an error. A warning is a failed commit. |
| `cargo test --workspace` | Runs unit tests, `tests/crash_recovery.rs`, and `tests/export_integration.rs`. |

Do **not** use a weaker clippy invocation for the gate:

```bash
# Too weak — misses tests/benches and allows warnings
cargo clippy
```

The Makefile clippy line is `cargo clippy --workspace --all-targets -- -D warnings`. For this single-package repo that is equivalent to `--all-targets -- -D warnings`.

### If a check fails

**Format**

```bash
cargo fmt --all
cargo fmt --all -- --check
```

There is no `rustfmt.toml`. rustfmt uses edition 2024 from `Cargo.toml`. Do not hand-format to fight rustfmt.

**Clippy**

Fix the lint. Do not add `#[allow(clippy::…)]` unless the lint is a false positive **and** you explain why next to the allow. Do not use `#[allow(dead_code)]` on new code; `main.rs` already has a crate-level allow that we are not extending.

**Tests**

```bash
cargo test --workspace -- --nocapture
cargo test name_of_failing_test -- --nocapture --test-threads=1
```

Do not `#[ignore]` a failing test to get a green hook. Ignored tests must stay ignored for a documented reason (environment, flaky hardware, etc.).

---

## What each check means

### `cargo fmt --all -- --check`

Exits non-zero if any tracked Rust file in the package differs from rustfmt. Path dependency `vendor/winit-0.30.13` is **not** a workspace member and is not rewritten by this command. Do not run rustfmt on that tree.

### `cargo clippy --all-targets -- -D warnings`

Compiles every target with clippy. Common failures:

- unused imports, variables, or `mut`
- needless clones, useless `format!`, collapsible `if`
- too-complex types that should be a named struct
- missing `Default` / derives clippy considers idiomatic

Match existing module style. Do not enable extra clippy lint groups in a drive-by PR.

### `cargo test --workspace`

| Suite | How it runs | Needs |
|-------|-------------|--------|
| Unit tests in `src/**` | `cargo test --lib` (included) | Nothing extra |
| `tests/crash_recovery.rs` | 10 tests | Temp dirs only |
| `tests/export_integration.rs` | 8 tests | FFmpeg (`tools/ffmpeg` or `PATH`) |

Property tests use `proptest` (dev-dependency). They run as part of the normal suite.

`cargo test` without `--workspace` is usually enough on this package; the gate still uses `--workspace` so it stays aligned with `make test`.

### Not required to commit (but required for `make check` / release)

| Command | Purpose |
|---------|---------|
| `cargo audit` | Advisory DB (`make audit`). Needs `cargo-audit` and network on first run |
| `cargo build` | Debug binary |
| `knoxstudio --smoke-test` | Process starts and exits 0 |
| `cargo bench` | Criterion benches in `benches/project_benchmarks.rs` — compile-checked by clippy `--all-targets`, not run on commit |
| `make coverage` | llvm-cov; core modules target ≥60% line coverage, overall ≥30% |

---

## Git hook

After `make install-hooks`, every `git commit` runs `scripts/pre-commit.sh`:

1. `cargo fmt --all -- --check`
2. `cargo clippy --all-targets -- -D warnings`
3. `cargo test --workspace`

A failed step **aborts the commit**. Fix the issue, then commit again.

```bash
make install-hooks
# installs: .git/hooks/pre-commit -> ../../scripts/pre-commit.sh
```

Emergency escape hatch (do not use for normal work):

```bash
SKIP_QUALITY_GATE=1 git commit -m "…"
# or
git commit --no-verify
```

`--no-verify` and `SKIP_QUALITY_GATE=1` are for broken-hook debugging only. PRs that would fail the gate will be rejected.

The hook lives in `scripts/pre-commit.sh` so it is versioned. `.git/hooks/` is not.

---

## Testing

Write tests with the change. Prefer a unit test in the same file under `#[cfg(test)]`. Use `tests/` only when you need a separate crate (FFmpeg, process crash recovery, fixtures).

```bash
cargo test --workspace
cargo test --workspace -- --nocapture
cargo test project::
cargo test ai::circuit_breaker
cargo test --test crash_recovery
cargo test --test export_integration
cargo test -- --ignored          # only if you intend to run ignored tests
cargo test -- --list
```

### Unit test shape

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn split_preserves_total_duration() {
        let mut project = Project::new("test");
        // arrange / act / assert
        assert!(project.duration() >= 0.0);
    }
}
```

### Property tests

```rust
#[cfg(test)]
mod property_tests {
    use super::*;
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn duration_is_non_negative(start in 0.0f64..10_000.0, len in 0.0f64..1_000.0) {
            prop_assert!(start + len >= start);
        }
    }
}
```

### Integration tests

- `tests/export_integration.rs` — transcode, overlay, concat, image-to-video, ffprobe. Uses `tests/fixtures/` and bundled FFmpeg.
- `tests/crash_recovery.rs` — temp-file cleanup / recovery.

If fixtures are missing, export tests can recreate them (`test_fixtures_can_be_created`) or you can run `make ffmpeg` first.

### What we expect in a PR

- New logic: at least one test that would fail without your change
- Bug fix: a regression test named after the behavior, not the ticket number alone
- UI-only string/layout tweaks: no new test required if you cannot test without a window; still run the full gate
- Do not delete or weaken tests to silence failures

More recipes: [docs/test.md](docs/test.md).

---

## Code style

### Rust

- Edition **2024**, rustc **1.97.1**. Do not use nightly-only features.
- rustfmt is the formatter. No parallel style guide.
- Clippy warnings are errors (`-D warnings`).
- Public items that are part of a non-obvious API get `///` docs.
- Prefer `anyhow::Result` at application boundaries; `thiserror` where the AI / native layers already use it.
- Log with `log::{info, debug, warn, error}` — not `println!` in library code.
- Do not add dependencies without a reason in the PR. Pin versions in the same style as `Cargo.toml` (exact versions are used today).

### `unsafe` and FFI

Every `unsafe` block needs a `// SAFETY:` comment that states the invariant (pointer lifetime, thread, buffer size, who frees memory). Match `src/native/mod.rs` and existing capture wrappers.

```rust
// SAFETY: `path` is a valid CString that lives for this synchronous call.
let code = unsafe { ks_some_native_call(path.as_ptr()) };
```

Swift entry points use `@_cdecl("ks_…")`. Rust declarations live in `unsafe extern "C"` blocks. `build.rs` compiles:

- `audio_capture.swift`
- `screen_capture.swift`
- `camera_capture.swift`
- `video_player.swift`
- `file_handler.swift`
- `fonts.swift`

If you add a `.swift` file, add it to the `swift_files` list in `build.rs` or the link will miss your symbols.

### UI (egui)

- New panels: `src/ui/<name>.rs`, `pub mod` in `src/ui/mod.rs`, call from `KnoxStudioApp` / the existing panel host.
- Use `t!(key)` for user-visible strings. No raw English (or Chinese) in widgets except debug-only UI.
- Follow `src/ui/theme.rs` for colors and spacing. Do not introduce a second palette.

### Modules

Keep files focused. Large areas are already split (`ui/timeline/`, `ai/director/`, `export/runner/`). Put new code next to the feature it changes rather than in `main.rs`.

---

## Internationalization

Languages: **English** and **Simplified Chinese** (`zh-Hans`) only.

Strings live under `src/i18n/translations/`, grouped by feature (`timeline.rs`, `agent.rs`, `export.rs`, …). The macro requires both languages:

```rust
define_translation!(btn_save, "Save", "保存");
```

Register a new file in `src/i18n/translations/mod.rs` (`mod` + `pub use`).

Usage:

```rust
ui.button(t!(btn_save));
```

Rules:

- Never add a key with an empty `""` for either language.
- Reuse keys from `common.rs` for Save / Cancel / Close / Delete / Error.
- Plurals go through `t_plural!` / `src/i18n/pluralize.rs`.
- `scripts/validate_translations.sh` is **stale** (it still looks for `src/i18n.rs`). Completeness is enforced by the macro and by `src/i18n` unit tests. Do not rely on that script until it is updated.

---

## Native Swift / FFI

1. Implement the Swift function with a stable `@_cdecl` name (`ks_…`).
2. Declare it in Rust (`src/native/mod.rs` or the owning module).
3. Document SAFETY at the declaration and at each call site.
4. Add the `.swift` path to `build.rs`.
5. Keep work that touches AppKit / AVFoundation / ScreenCaptureKit on the main thread unless the existing module already proves otherwise.

Xcode must be selected:

```bash
xcode-select -p
# if needed:
xcode-select --install
# or: sudo xcode-select -s /Applications/Xcode.app
```

---

## Do not change without review

| Path / topic | Why |
|--------------|-----|
| `vendor/winit-0.30.13/` | Intentional macOS activation patch; keep on 0.30.13 |
| `.env.signing`, `*.p12`, notarization passwords | Never commit. `.gitignore` already excludes `.env.signing` |
| `tools/ffmpeg`, `tools/ffprobe` | Downloaded locally; not source |
| `Cargo.toml` version / `Makefile` `VERSION` | Use `scripts/bump_version.sh` in a release PR |
| `Info.plist` usage strings / bundle id | App Store and permission copy |
| KnoxChat base URL, keychain storage | Security and product contract |
| Crate-level `#![allow(dead_code)]` in `main.rs` | Do not spread allows; prefer deleting dead code |

`target/`, `.DS_Store`, and `.knox` are gitignored.

---

## Branch, commit, and pull request

### Branch

```bash
git checkout main
git pull
git checkout -b fix/timeline-snap-gap
```

Suggested prefixes: `fix/`, `feat/`, `refactor/`, `test/`, `docs/`, `chore/`.

### Commit messages

Write in the imperative, one focused subject (≤72 characters). Say **why** when it is not obvious.

```
fix clippy warnings in export runner

Keep -D warnings green after the filter graph change.
```

```
add regression test for ripple-delete of grouped clips
```

Do not bundle unrelated refactors with a bug fix. Do not commit `Cargo.lock` noise from unused dependency experiments.

The pre-commit hook must pass. If you forgot to format:

```bash
cargo fmt --all
git add -u
git commit
```

### Pull request

1. Rebase or merge `main` so you are not fighting stale clippy.
2. Run `make pre-commit` (commit gate).
3. Run `make check` before you ask for review (adds audit, build, smoke-test).
4. Fill in:

**Summary** — what changed and why.

**Test plan**

- [ ] `cargo fmt --all -- --check`
- [ ] `cargo clippy --all-targets -- -D warnings`
- [ ] `cargo test --workspace`
- [ ] `make check` (for larger or release-adjacent PRs)
- [ ] Manual: launch `cargo run -- --debug`, exercise the UI path you touched
- [ ] New UI strings exist in English and Chinese
- [ ] No secrets, no vendor drive-by, no version bump unless intended

**Notes** — screenshots for UI, SAFETY notes for FFI, any ignored tests.

Keep PRs small enough to review in one sitting. A timeline bug and an AI-router change are two PRs.

---

## Review checklist

Reviewers should reject a PR that:

- Fails format, clippy `-D warnings`, or tests
- Adds user-visible English without Chinese (or the reverse)
- Introduces `unsafe` without `// SAFETY:`
- Touches `vendor/winit-0.30.13` without a dedicated justification
- Weakens tests or adds broad `#[allow]` to silence the gate
- Changes signing, entitlements, or API key handling without security review

Authors should expect requests to add tests for timeline math, export filters, and project file I/O — those modules already have dense coverage (`project`, `export::runner::filters`, `history_v2`, `data_integrity`).

---

## Troubleshooting

### Wrong rustc version

```bash
cd /path/to/knox-studio
rustup show          # should select 1.97.1 from rust-toolchain.toml
rustup component add rustfmt clippy
```

Do not `rustup default nightly` for this repo. [docs/DEVELOPER.md](docs/DEVELOPER.md) still mentions nightly 1.95+; that is outdated.

### `can't find crate` / stale incremental

```bash
cargo clean
cargo test --workspace
```

### Swift / `build.rs` failed

```bash
xcode-select -p
xcrun --show-sdk-path
swiftc --version
```

Install CLT or point `xcode-select` at Xcode. Deployment target is **13.0** (`arm64-apple-macosx13.0` / `x86_64-apple-macosx13.0`).

### FFmpeg / export tests fail

```bash
make ffmpeg
ls -l tools/ffmpeg tools/ffprobe
./tools/ffmpeg -version
```

Or `brew install ffmpeg` so `PATH` has a working binary. Export tests skip poorly if neither exists — install one of them rather than ignoring failures.

### Screen / camera / mic permission

System Settings → Privacy & Security → enable the **terminal or binary** you launched, not only a previous `KnoxStudio.app`.

### Clippy passes locally but you used different flags

Always use `--all-targets -- -D warnings`. `cargo clippy` alone is not the gate.

### Hook did not run

```bash
ls -l .git/hooks/pre-commit
make install-hooks
```

### `cargo audit` missing (PR / `make check` only)

```bash
cargo install cargo-audit
make audit
```

---

## Maintainer-only work

Ordinary contributors should not run the release pipeline. For maintainers:

```bash
./scripts/bump_version.sh patch   # also: minor | major
make check
make changelog
make release && make bundle && make sign && make dmg
# or: make dist / make release-full
```

Signing needs `.env.signing` (not committed). Notarization needs Apple ID / team credentials. See `Makefile` and [docs/DEVELOPER.md](docs/DEVELOPER.md).

---

## Quick reference

```bash
# one-time
make setup && make install-hooks

# every commit — required
cargo fmt --all -- --check
cargo clippy --all-targets -- -D warnings
cargo test --workspace
# same as:
make pre-commit

# before a PR
make check
```

If those three Cargo commands are not green, do not commit.
