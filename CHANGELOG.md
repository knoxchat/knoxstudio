# Changelog

## [1.3.5]

- Upgrade egui stack to 0.36.1 (`eframe`, `egui`, `egui_extras`) and adapt to the `DroppedFile.path()` API for project and timeline file drops
- Harden media database startup: restore from backup, quarantine corrupt on-disk files, and fall back to an in-memory database so launch never aborts on SQLite I/O failures
- Run native screen/microphone/camera device enumeration on the UI thread during capture init (FFmpeg availability still probed in the background) to avoid AVFoundation / ScreenCaptureKit permission issues off the main thread
- Enable local panic logs by default for new installs and existing preference files missing the field
- Bump `base64` to 0.23.1 and `open` to 5.4.1

## [1.3.4]

- Remember AI Agent vs Inspector panel selection across app launches (including open/closed state)
- Expand AI Agent Reasoning section by default (users can still collapse it manually)
- Simplify AI Agent Configuration for Manager and Editor models: KnoxChat (`api.knox.chat`) is the only provider, with Provider and Endpoint fields hidden
- Move the shared KnoxChat API key to the Defaults tab for Manager and Editor models
- Drive KnoxChat Manager, Editor, Sub-Models, Director, Vision, and title generation from the live [`List Available Models`](https://docs.knox.chat/1.0.0/list-available-models) catalog (`GET /v1/models`): `context_length`, `max_completion_tokens`, `supported_parameters`, and architecture modalities
- Apply catalog `max_completion_tokens` as the default Manager/Editor completion limit (no static 256/8192 ceiling), clamp user overrides to that cap, and reload agents when the catalog finishes loading
- Gate tools, temperature, and Claude extended thinking from each model's `supported_parameters`; auto-detect text / image / vision roles from `input_modalities` / `output_modalities`
- Add a gear (Parameters / Advanced) panel on Manager and Editor models for Max Tokens, Temperature, Top P/K, penalties, Min P, and Seed — only showing controls listed in `supported_parameters`, with limits from the catalog
- Fix chat auto-title generation truncating reasoning models at `max_tokens: 256` (`length` on KnoxChat); titles now use a catalog-aware soft ceiling (8192)

## [1.3.3]

- Add video rotation
- Add shift + click with range slection
- Shift+click & Cmd+click work for empty gaps
- Fixed selecting stay on all dragged clips
- Removed the duplicate clip_refs_in_shift_range function

## [1.3.2]

- Implemented audio-only export (.mp3 and .wav) end-to-end
- Update carmera bubble lives
- Update multi-segment paths:
  - the concat path (every clip clamped to [cv{i}] before concat),
  - the xfade/transition path (each [sv{i}] clamped, which also makes the transition offsets — derived from seg.duration — line up with the real stream length).

## [1.3.1]

- Separate system audio and microphone audio on the timeline tracks
- Remove tokens usage
- Auto-naming chat history title better
- Add "Back to chat" link
- Use stable_slider for all Sliders to replace default egui ones
- Redesign slider visuals (rounded track, teal progress fill, circular handle with hover/drag emphasis) and unify every inspector slider (Volume, Fade In/Out, Speed, Opacity, Scale, Rotation) onto one framed component with an inline label + editable value, removing duplicate value displays

## [1.3.0]

### Editor mode — AI timeline editor

- Editor agent is now a full timeline editor that can do everything a human can on the tracks: split, trim, move, delete, retime, opacity/volume/fade/transform, add/remove transitions, duplicate, copy/cut/paste, detach audio, freeze frames, lock/unlock, group/ungroup, ripple-delete a range, and insert space.
- Move the red playhead/scrubber, select clips, and manage tracks (add, remove, rename, mute/solo/lock/volume) directly from chat.
- Frame extraction from real footage: extract a frame (playhead/first/last/specific time) or auto-detect key frames and drop them on the timeline as stills.
- Insert media from a file path, an `@`-mentioned attachment, or the Media Library.
- AI generation from the timeline: `regenerate_clip`, `generate_variation` (opens the variations panel), and `extend_clip` queue async generations grounded in the source clip.
- Vision-grounded edits: the agent can watch the actual footage (by clip, time, or playhead) before deciding where to cut/trim.
- Selection-aware: the agent now sees what you have selected, so "slow this down", "delete this", or "caption the selected clip" resolves to the right clips.
- Richer timeline awareness: the snapshot now shows canvas resolution, per-clip lock/group/audio/transition/transform state, per-track gaps, and markers — so edits like removing a transition or closing a gap are grounded, not guessed.
- Content analysis without watching frames: `analyze_timeline` returns scene-change cut points and silent/dead-air ranges so the agent can "remove the silences", "tighten the pauses", or "cut on every scene change" precisely.
- Edit by what's said: `transcribe_clip` transcribes a clip's speech (ElevenLabs Scribe v2) with timeline-time timestamps, so the agent can "cut to where she says X", "remove the part about Y", or caption the dialogue.
- Titles & captions: `add_text` places a text overlay (title card, caption, lower-third) on the canvas; `add_marker` / `remove_marker` manage chapter/beat markers.
- Safety: destructive edits (delete / ripple-delete / remove track) prompt read-back verification, and in Confirm mode they wait for an in-chat approval card before being applied. If you edit the timeline while the agent is working, its changes are held for your approval instead of overwriting your manual edits.
- Director mode support vision model to watch the previous clip, then extract a continuity frame for next video generating base on contexts and prompts

## [1.2.6]

- Add custom modal
- Return the directory a file-import dialog of the given `key` should open in
- Adjust unsave project open new one modal optimization
- Improve click effect playing dynamically even speed changes
- Match exported click effect to the preview: animate the ring (grow + fade) as a per-frame sequence, fix overlay alignment in original-resolution exports, and render the preview ring in project (compose) pixels so its size matches the exported video
- Export filename now derives from the project name instead of the hardcoded export
- Redisign the recording setup modal


## [1.2.4]

- LLMs supporting for Screenplay editor
- Git supporting for Screenplay editor
- Remove unused accessibilities
- Director mode: AI director shot breakdown with framing, camera, and per-shot timing
- Director mode: Interactive Shot List editor to review and edit prompts and durations before generation
- Director mode: Send screenplay directly from the Screenplay editor toolbar
- Director mode: Syllable-accurate duration enforcement with auto-split for overlong dialogue
- Director mode: Robust planner JSON parsing with one repair round before fallback
- Director mode: Persist final shot plan snapshot into chat history when the pipeline starts
- Director mode: Accurate duration totals when skipping failed shots
- Add fallback：Hiragino Sans GB → STHeiti Light
- Chat history items list optimizations
- Fix some bugs

## [1.2.3]

### App Optimization

- Add Media Preview
- Add Media Library Sidebar TreeView
- Improve the Timeline Zoon actions
- Update all phrases for multilingual support with Chinese & English
- Update Inspector Icons
- Enhance Screenplay Editor


#### Screenplay Editor — seamless workspace integration
- The screenplay editor is no longer a floating window. It now renders inside the central
  workspace behind a `Canvas | Screenplay` tab strip that appears once a document is open.
- The editor's separate file sidebar was merged into the Media Library: clicking an editable
  screenplay file (`.md`, `.markdown`, `.fountain`, `.txt`, `.json`, `.yaml`, `.yml`) under
  `~/.knoxmedia/screenplay` opens it inline, and the active document's row is highlighted in
  the tree.
- JSON and YAML files open in the same inline editor with data-aware syntax highlighting in Edit
  mode and fenced-code formatting in Read mode.
- Media Library context menus gained screenplay actions (Open, Rename, Duplicate, Pin/Unpin,
  Delete, Reveal in Finder; New file/folder on screenplay folders). File-management modals are
  shared and work from either the Canvas or Screenplay view.
- Focus mode (Cmd+Enter / F11) hides the Media Library and right panel for distraction-free
  writing; the timeline is hidden while writing. Closing the last document returns to Canvas.
- The last-open screenplay document is restored on launch.
- Read-mode scene cards now show a "Roles:" chip row mapping each scene character to its
  Character Role — chips indicate active/inactive/missing roles and one click toggles a role's
  active state (and saves it).
- Scene cards with generated media gained an "↗ Add to timeline" action that imports the scene's
  generated clips onto the timeline and switches to the Canvas view.
- Screenplay file operations (new / rename / delete / duplicate) now refresh the Media Library
  tree immediately.

### Removed

- Pruned the screenplay editor's retired internal file tree (`file_browser.rs` and the unused
  `browser` / `move_entry` / `recompute_browser_filter` / content-search scaffolding) now that the
  Media Library owns the file tree.

## [1.1.4]

### Added

#### Video Continuity System
- Video sequence and shot tracking for multi-clip continuity across scenes
- Automatic frame chaining — exit frames extracted and injected as entry frames for the next shot
- Scene environment propagation and prompt enhancement across all shots in a sequence
- Motion state analysis via prompt heuristics and Gemini 3.5 Flash vision (KnoxChat or Google API)
- ContinuityContextBuilder unifying frames, environment, and motion for generation
- SQLite persistence for sequences with auto-migration from JSON and real-time state saves
- Sequential shot generation integrated with JobQueue, Director, and batch scene generation
- ContinuityAwarePlan wrapper for multi-step video plans with automatic frame chaining
- Failed shot tracking with per-shot and batch retry support

#### Agent Panel & Sequence UI
- Sequence list view (chain link icon) with pause, resume, delete, and duplicate controls
- SequenceCard with real-time progress, ETA, and generation statistics
- Shot preview popovers with exit-frame thumbnails, status, and error details
- Timeline mini-map with duration-proportional, color-coded shot blocks
- Inline shot editing — prompt, duration, resolution, aspect ratio, and audio toggle
- Shot reordering, add-shot to existing sequences, and batch delete failed shots

#### Timeline Integration
- Send to Timeline — one-click import of completed sequences to a new video track
- Import preview dialog showing shot timings and total duration before committing
- Continuity chain markers and connecting lines between sequence clips on the timeline
- Quick jump from a completed shot to its clip on the timeline

#### Settings & Notifications
- Continuity toggles in AI Agent Config → Defaults (frame chaining, sequential mode, vision analysis, environment sync, motion prompts)
- macOS desktop notifications when sequences complete or fail, with preference toggle
- Escape shortcut to close sequence view popovers

## [1.1.3]
- New generated content (videos, images, audio) will now be added after the last clip on the timeline
- Multiple generated assets are placed sequentially (each after the previous one)
- No overlaps - content is automatically appended to the end
- Explicit positions from the timeline_place tool are still respected when specified
- User-initiated placements (like variations panel) continue to use playhead position as intended

### Added
- Architecture documentation (`docs/ARCHITECTURE.md`)
- Developer onboarding guide (`docs/DEVELOPER.md`)
- Architecture Decision Records (ADRs) in `docs/adr/`
- Keyboard shortcuts reference (`docs/KEYBOARD_SHORTCUTS.md`)
- FFmpeg license compliance documentation

## [1.1.0] — 2026-05-23

### Added

#### AI & Generation
- Manager Agent with streaming responses and tool calling
- Voice agent support via GPT-4o Realtime API
- Multi-provider video generation (Minimax, Luma, Kling, Veo)
- Character role system with reference images
- Screenplay editor with scene-driven generation
- Generation history with variations support
- Cost tracking dashboard for AI usage

#### Data Integrity (Phase 7)
- Project file backup rotation (keeps last 5 autosave snapshots)
- SHA-256 checksum for project bundle corruption detection
- SQLite database backup on app launch
- Export output verification with duration/stream checks
- Preferences migration system with versioned schema
- Configuration schema validation with helpful error messages
- MDM/enterprise configuration profile support

#### Internationalization (Phase 6)
- Complete English and Chinese translations (650+ keys)
- Translation completeness validator
- Pluralization support (`t_plural!` macro)
- Locale-aware date/time/number formatting
- High-contrast theme variants (dark and light)
- VoiceOver accessibility labels
- Full keyboard navigation support

#### Observability (Phase 4)
- Crash reporting with local storage
- Export performance metrics (FPS, ETA)
- AI generation cost tracking
- Health check system (ffmpeg, disk, memory)
- Session analytics (opt-in)
- Runtime log level toggle
- Export progress ETA calculation

#### Build & Release (Phase 5)
- Comprehensive Makefile with all targets
- Universal Binary build automation (ARM64 + x86_64)
- Automated notarization workflow
- Auto-update system with GitHub releases
- Version bumping script
- SBOM generation
- Pretty DMG creation with custom layout
- Changelog generation from commits

#### Performance (Phase 3)
- Incremental undo with diff snapshots
- Memory pressure monitoring with adaptive cache eviction
- Frame buffer pool for video player
- Performance benchmarks (Criterion)
- Lazy track loading for large projects
- Batch annotation rendering for export
- Async thumbnail generation pipeline
- Zstd compression for project files

#### Testing (Phase 2)
- Export pipeline integration tests
- AI agent tool dispatch tests
- Fuzz testing for project file deserialization
- Property-based tests for timeline operations
- Rate limiter edge case tests
- Snapshot tests for FFmpeg filter graphs
- Circuit breaker for external APIs
- Undo/redo stress tests
- Crash recovery tests
- Code coverage reporting (cargo-llvm-cov)

#### Foundation (Phase 1)
- Pre-release check script (build, test, clippy, fmt)
- `cargo audit` integration
- macOS Keychain for API key storage
- Retry logic with exponential backoff
- Log rotation (10MB max, 5 files)
- Safety documentation for all `unsafe` blocks
- Input sanitization for LLM prompts
- Graceful shutdown with WAL checkpoint

### Changed
- Improved timeline rendering performance
- Better error messages for common issues
- Modernized preferences dialog

### Fixed
- Memory leak in video player frame copy
- Timeline zoom persistence across sessions
- Audio waveform rendering at high zoom levels

## [1.0.0] — 2026-03-15

### Added

#### Core Features
- Screen recording with ScreenCaptureKit
- Multi-track timeline editing
- Video/audio clip management
- Annotation tools (shapes, text, arrows)
- FFmpeg-based export pipeline
- Project file format (.knoxstudio bundles)

#### UI
- egui-based interface
- Canvas preview with annotations
- Timeline with tracks, clips, markers
- Inspector panel for clip properties
- Dark and light themes

#### Recording
- Screen capture with cursor
- Microphone audio recording
- System audio capture
- Camera overlay recording
- Click highlight effects

#### Export
- MP4 (H.264) export
- WebM (VP9) export
- GIF export
- Custom resolution and bitrate
- Audio mixing

#### Project Management
- Autosave snapshots
- Recent files list
- Undo/redo history
- Project templates

### Technical
- Rust + Swift FFI architecture
- AVFoundation video playback
- SQLite for media indexing
- Tokio async runtime for AI

---

## Version History

| Version | Date | Highlights |
|---------|------|------------|
| 1.1.0 | 2026-05-23 | AI agents, data integrity, i18n |
| 1.0.0 | 2026-03-15 | Initial release |
