# Changelog

## [1.3.9]

### Voice Director — studio modes by speech

- Speak to open Director, Writer, Editor, Storyboard, or Character Roles — the Voice Director switches modes itself, so you do not need the composer text field or mode icons while the mic is on
- Composer icons and voice share one studio-mode path, so clicks and speech stay in sync
- After a mode switch, the Voice Director keeps its studio tools instead of falling back to web search only
- Switching modes while a reply is still speaking no longer shows "Conversation already has an active response" or blocks the next turn

### Voice Director — drive specialists by voice

- Ask for a shot list, start or cancel the Director pipeline, or reset and analyze a new brief
- Send spoken instructions to the Screenplay Writer and Timeline Clip Editor; their replies stream in the specialist panel instead of duplicating in the voice transcript
- Start a Storyboard from a spoken plot, pick a style, and continue past review checkpoints
- Activate, create, or list character roles ("use Pablo", "turn off Ashley") so generations pick up those references
- Play, pause, stop, skip start/end, rewind, fast-forward, loop, or jump the playhead by speech

### Voice Director — transport and timeline chrome

- Speak to toggle the Media Library, Agent or Inspector, dark/light theme, and English/Chinese — the same buttons as the transport bar, without clicking
- Undo, redo, new/save/open project, export, add media, and relink missing files by voice
- Start or stop screen recording, and open Preferences (including the recording-setup Devices tab)
- Set timeline edit mode (Normal / Ripple / Insert), Select or Blade, Snap, import at playhead vs start, zoom, the performance overlay, and Image Gen merge of selected clips

### Voice Director — clip context menu

- Speak the timeline clip right-click actions: split, trim front/end to the playhead, rotate 90°, copy/cut/paste, duplicate, move to playhead, select all on track, detach audio, freeze frame, and cross dissolve
- Reveal in Finder, extract the playhead / first / last / key frames, mute, lock, add the clip to agent context, regenerate, generate a variation, extend, or delete — targeting the selected clip, the clip under the playhead, or a spoken clip id

### Voice Director — generation without the keyboard

- Generate video, image, and audio by speech; video can attach a first frame and reference images when those files exist
- Voice sessions skip Manager Confirm-mode cards so spoken generate runs without a click
- Search generated assets, read scene environment, and inspect timeline, role, and scene context while talking

## [1.3.8]

- Add realtime endpoint
- Add Knox API for voice models

### Voice Director — realtime speech to speech

- Talk with the Voice Director over KnoxChat Realtime — speech in, speech out, with studio tools for video, image, and audio
- Assistant speech stays continuous: queued audio is no longer dropped when the model streams faster than playback, so replies do not skip or chop mid-sentence
- Gaps in the network stream fade out instead of clicking; playback waits for a short buffer before starting so the first words are not cut off
- Microphone audio is sent as it is captured, not once per UI frame — turn-taking stays smooth while the timeline or preview is busy
- Laptop speaker echo no longer cancels the Director mid-word; talking over a reply still interrupts after a short stretch of real speech
- Desktop mics (Yeti + MacBook speakers) no longer cut a reply on a 60 ms burst of speaker leak — interrupt needs louder, longer speech than the current playback
- Network jitter no longer punches a silence hole in the middle of a sentence; playback stays live through gaps instead of pausing 400–480 ms to re-buffer
- After a reply you can interrupt or ask a follow-up in the same session; the mic opens once the model finishes that spoken turn
- Your words appear in the chat as you speak (live captions), then as a user message when the turn finishes
- Composer shows Listening / Thinking / Speaking, a live mic-level ring on the voice button, and a pulse while connecting
- Header title switches to **Voice Director** for the whole session, including while connecting; click the mic to start or stop

### AI Agent chat — typesetting & density

- Switching dark and light no longer shreds agent reply text — markdown no longer reuses glyph meshes after the font atlas is rebuilt
- Contractions from voice and LLM replies no longer render as `I' m` / `I' ll` — typographic apostrophes and quotes typeset with Latin metrics
- Agent replies are document-style (no heavy bubble); user messages shrink-wrap and sit on the right with a tight tail corner
- Timestamp, token usage, and Copy / Retry / More share one compact meta row instead of a token line plus an empty action bar
- Tighter thread, header, notices, Scene/Roles chips, and empty composer so more of the conversation stays on screen
- Markdown headings use size hierarchy instead of rainbow colors; body line-height is 1.35 for sidebar density

### Fonts Issues

- Blank UI text on some Macs (icons visible, every label a gray bar): macOS 15+ PingFang UI stores outlines in a private `hvgl` table that egui cannot rasterize. The app no longer uses that face for UI text
- Bundle Noto Sans SC (SIL OFL) after the Latin UI face, so English punctuation keeps Latin metrics and Simplified Chinese still draws when PingFang is missing, on-demand, or `hvgl`-only
- System CJK fonts (PingFang SC, Hiragino Sans GB, Heiti SC) are extra coverage only after a raster probe — cmap-only faces cannot steal Latin glyphs
- Fix startup crash on some Macs — `Invalid index 180 for font collection` when loading PingFang SC no longer aborts the app
- CJK UI fonts resolve dynamically from wherever macOS stores them, instead of hardcoded paths and TTC face indices
- Annotation export uses the bundled Noto Sans SC font so exported Chinese text is never blank
- Release and DMG builds run a font preflight during `--smoke-test` so a bad collection index or undrawable bundled face cannot ship in the packaged app

### Media Library — Source Control sidebar

- Fix Source Control (git) tab clipping in the Media Library sidebar — commit box, tabs, and status text no longer get cut off at narrow widths
- File tree and Source Control remember separate sidebar widths; switching views restores each one instead of sharing a single narrow column
- Opening Source Control expands to a comfortable width automatically; your resized width is persisted per view
- Git sidebar layout is content-driven: tab labels, commit hint, branch controls, and header chrome are measured at runtime instead of using fixed pixel breakpoints
- View tabs share the available width equally; when space is tight they collapse to icons with tooltips
- Branch name field and **Create branch** stack or sit side by side based on measured fit; the input fills remaining space when inline
- Long changed-file names ellipsize instead of overflowing the row; group actions collapse to icons when the header is tight
- Branch name in the sidebar header truncates with ellipsis so it does not crowd the action icons
- Media Library max width scales with window size (~45% of content width) rather than a hard cap

## [1.3.7]

### AI Agent chat — reliability & streaming

- Fix duplicated and overlapping agent replies after video generation — each turn now shows one assistant message that updates in place
- Remove the separate “Thinking…” placeholder bubble; responses stream live into a single message
- System updates (video placed on timeline, generation failed or cancelled, sequence complete) appear as compact notices instead of extra agent paragraphs
- **Stop** while the agent is working: the Send button becomes Stop, Esc cancels, and partial replies are kept
- Prevent sending a second message while a reply is still in progress
- Starting a new chat or switching conversations no longer lets a late reply appear in the wrong thread
- Chat history no longer shows the same reply twice after a video job

### AI Agent chat — reading experience

- Markdown wraps properly — long URLs, job IDs, hashes, and mixed Chinese/English text no longer stack one character per line
- Bulleted and numbered lists read cleanly with proper indentation
- Code blocks show the language, include a **Copy** button, and scroll horizontally when needed
- Tables scroll horizontally; cell text wraps by word, not by character
- Long links ellipsize instead of breaking the layout
- Inline math (`$…$`, `$$…$$`) renders in the message; LaTeX and Mermaid blocks appear as copyable code
- Message text remains selectable for copy-paste

### AI Agent chat — streaming feel

- Smoother token streaming with less flicker and layout jumping while the agent is typing
- Blinking cursor at the end of the in-flight reply instead of a separate “Streaming…” bubble
- Status shown inside the message: Reasoning, calling a tool, generating video, writing, and similar states
- Scroll stays put when you read older messages; a **New messages** button appears when new content arrives below
- Loading dots inside the message when the first tokens are slow to arrive
- Stream errors show a clear message with **Retry** instead of raw error text in the reply

### AI Agent chat — reasoning

- One collapsible **Reasoning** section per message — no duplicate thinking boxes
- While reasoning: section expands automatically; when done, collapses with a summary like “Thought for 4s”
- Completed messages show reasoning collapsed by default; expand/collapse is remembered per message
- **Copy reasoning** available from the message actions menu; default copy copies the answer only
- Reasoning effort setting (Off / Low / Medium / High) in AI Agent configuration; hidden for models that do not support it

### AI Agent chat — messages & actions

- Cleaner message layout: less repeated chrome, more room for content; refreshed light and dark styling
- Hover actions on each message: **Copy**, **Retry** (agent), **Edit** (user), and **More** (copy as Markdown, delete, quote, and more)
- **Retry** resends your last prompt without duplicating your message
- **Edit** lets you change a past prompt and resubmit; later messages in the thread are removed (ChatGPT-style)
- Timestamps on hover or when messages are far apart; **Today** and **Yesterday** date separators
- Chat history uses the same layout and timestamp rules as live chat — no timestamp on every line
- Related notices and tool cards group visually; stopped or failed turns show a clear banner

### AI Agent chat — composer

- Composer grows as you type (taller draft area for long prompts)
- Choose **Enter to send** or **Cmd+Enter to send** in preferences; Shift+Enter always adds a new line
- Drafts are saved per conversation and restored when you return
- Drag and drop files onto the panel, or paste an image from the clipboard; preview chips with remove
- Character count for long prompts; warning when many timeline stills may exceed context limits
- Quick-start prompts (generate video, edit last clip, explain selection, write a shot list, and more) insert into the composer without sending immediately
- Composer stays above floating buttons and mention popups; focus returns after send or stop

### AI Agent chat — video, audio & tools

- Video generation shown as one card per job: prompt, progress, elapsed time, and errors in a single place
- When complete: **Play**, **Reveal in timeline**, **Copy prompt**, and **Retry** on the card; timeline placement shown on the card, not as a second reply
- Audio messages show duration and playback
- Image and video previews in chat; click an image for a lightbox; scrub video thumbnails on hover
- Plan, confirm, and question cards improved — live step updates, approval-style confirms, keyboard 1–9 for quick answers
- Compact tool-call rows in the thread (expand for details), similar to Cursor-style tool cards

### AI Agent chat — history & search

- History view matches live chat — same bubbles, actions, and styling
- Resuming a conversation restores generation card state and reasoning layout
- Search within the open conversation (highlight matches in the thread)
- Export a conversation as Markdown or plain text
- Delete a single message or an entire turn (user + agent) with confirmation
- Conversation titles no longer pick up “Thinking…” from old sessions

### AI Agent chat — performance & polish

- Long conversations scroll smoothly with a virtualized message list
- Suggested follow-up chips after a completed reply (e.g. make it shorter, generate a video, continue)
- **Quote** inserts a blockquote into the composer from any message
- Open a message in a larger overlay for wide tables or long code
- Header shows the active model and Auto vs Confirm mode; optional token usage when the API provides it
- Network and quota errors as clear notices with **Retry** and a link to AI settings
- **Jump to bottom** button with unread count when you have scrolled up
- Select multiple messages (checkbox or ⌘⇧A) to copy, export, or delete in bulk
- Pin an important message or generation card to the top of the panel
- Accessibility labels on icon buttons; reduced motion disables blinking cursors and loading animations
- New chat UI strings in English and Chinese

## [1.3.6]

- Add StoryBoard
- Bundle FFmpeg/FFprobe 9.0
- Mentions now sit in the sentence
- Image & Vision modality with default KnoxStudio provider
- Remove unused Collapse all icon/button
- Add KnoxStudio video generation models

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
