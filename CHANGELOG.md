# Changelog

All notable changes to KnoxStudio will be documented in this file.

## [1.5.7]

### Added

- Voice Isolator
- Voice Changer
- Forced Alignment
- Sound Effects

### Changed

- Clips on a track can now be targeted the same way from typed prompts, @ mentions, and realtime voice — by name, filename, or short id, not only UUID.

### Fixed

- Export state
- Backspace in the agent chat field was aborting on macOS’s IME path

## [1.5.6]

### Added Knox Audio Endpoints

- Music
- TTS
- STT

### Fixed

- Agent audio-card **Play** seeks the clip on the timeline and uses KnoxStudio playback (same as video cards), instead of opening the MP3 in the system player
- Asking the Manager to add captions/subtitles or transcribe an existing video now goes to the Editor STT path (`caption_clip`) instead of `generate_video`

### Changed

- Caption cues use larger bold type on a compact bottom-center pill (shrink-wrapped to the words) instead of a full-width bar with small text

## [1.5.5]

- Screen capture improvements
- Video player optimizations

## [1.5.4]

- Git Improvements
- File Tree Improvements

## [1.5.3]

### Added

- Elapsed-duration kit component: hours, minutes, and seconds broken out of a `Duration`, with an optional tenths-of-a-second precision mode for live timers, localized unit labels, and an optional clock icon. Generation cards and the Director pipeline now use it instead of their own `1:02` / `12.3s` strings
- Generation cards persist and display their permanent output path; the card’s copy dump and the Markdown/plain-text conversation export include `elapsed` and `path`
- **Show in Finder** on a generation card whose file is no longer at the saved location, plus a "Missing" card state with the last saved path
- Generation-history lookup by prompt and `source_path` on stored assets, so a restored card can find the real file or the retained source

### Changed

- Production KnoxStudio API origin is now `https://api.knoxstudio.ai` (was `api.knox.chat`) across Manager, Editor, Image, Vision, Video, and Voice models, OAuth authorize / token / userinfo / mint / revoke, the LLM client, the realtime WebSocket origin, and continuity vision. Existing configs with a stale `api.knox.chat` endpoint are rewritten on load
- AI Agent Configuration opens on the **Defaults** tab, which is now the first sidebar item
- Canvas quick view follows the active dark/light UI theme instead of always painting a cinema-black backdrop and plate
- Media Library file tree no longer draws a folder icon per row — only file-type glyphs remain
- Removed the vendored `egui/` tree

### Fixed

- Opening a past thread no longer restores video cards as live **Pending** jobs; restored cards are settled against generation history
- History restore keeps the real generation time — from history timestamps or the stored file’s mtime — and the stored file location, instead of resetting the card to `0.0 s` and losing where the output went
- Generation cards now persist as soon as a job completes or fails, so restoring history shows the finished state rather than a frozen in-flight timer 

## [1.5.2]

GPUI now matches the remaining egui editor, inspector, agent, and screenplay surfaces that were still thinner after the 1.5.0 runtime switch.

Cmd/Shift clip selection no longer depends on finding a sliver of empty track: a modifier-click hits the clip body even when trim handles eat the whole block.

### Timeline

- Cmd-click toggles and Shift-click range-selects clips and gaps without hunting for a tiny hand-cursor gap; trim handles yield to selection while a modifier is held
- Scrollbar thumbs are draggable; clicking the track jumps scroll
- Gap menu: named marker header, Red / Green / Blue / Yellow / Orange, and Delete Marker “name”
- Auto Caption is disabled while a caption job is already running
- Clip hover tooltip shows Start / Duration / End (`MM:SS.ms`), follows the pointer, and hides during trim or slip
- Closed-hand cursor while dragging a clip or keyframe; full-height in/out lines; header/content divider; volume and pan presets disable when already at that value
- Nested-edit window title is `KnoxStudio — Parent › NestedName`

### Canvas

- Rotated titles, shapes, and callouts paint and hit-test around the box center
- Wrapped type matches egui: align, letter-spacing, plate, shadow, outline, typewriter reveal, highlight
- Stroke trim and arrow caps on draw-on lines; numbered-step badge sits in a filled plate
- Inline text editor uses the annotation font, size, color, and plate padding, and grows while typing
- Out-of-bounds flash is a yellow frame, not a red wash

### Inspector

- Color-fill clips: picker, hex, Black / White, hint
- Audio overlaps: add / remove, duration, role, mix preview, ducking amount / attack / release
- Audio tab mute plus analyzing / unavailable waveform copy
- Reset Anchor; drag the three curve handles; effect stack drag-reorder with insert gap and ghost

### Recording

- Empty-canvas and transport Record run the same preflight as egui: initializing, FFmpeg missing, and screen-capture-off opens Recording prefs instead of failing silently

### Agent

- Director and Storyboard stay in the chat scroller so the thread stays visible
- Estimate card lists per-shot rows; sequence shot hover is a rich popover
- Follow-up chips only on the last completed turn
- @-mention popup sits above the composer
- Agent config opens on Manager (or the last tab)
- Voice `set_ui` accepts the egui aliases (`true` / `false`, `en-us` / `zh-cn` / `中文`, `properties` / `chat` / `none` / `off`, razor / slip keys)
- `[` / `]` verbosity only while the debug console is open
- Variations grid shows a first-frame thumb for video records

### Screenplay

- Outline is a scene breakdown: block previews, character-tinted dialogue, find hits
- Git diff: split / unified toggle, gutters, hunk headers
- Editor context menu: Cut / Copy / Paste / Select All and Send selection to Agent
- Minimap blocks sized by content and colored by scene status

### App

- One graceful-shutdown path on Quit, window close, unsaved Discard / Save → Quit, and update-install: cancel export, stop voice / AI, finalize recording, persist layout, checkpoint media DB, clean export temps
- Session error log with copy, clear, Open Panic Log, and Open Crash Reports
- Debug console lists crash reports (copy / delete / clear), a memory / health / crash stats strip, and a launch toast for unviewed crashes
- Preferences: custom 1–120 FPS next to presets
- Shortcuts overlay: Hide, Hide Others, FPS monitor, screenplay Find / Close tab / minimap / line numbers

Voice Director chrome now tells user speech from agent speech by colour and motion, instead of painting both as the same red bars. An open-but-silent session no longer redraws the whole window at display rate.

## [1.5.1]

Fix the GPUI preview path that could grow resident memory into tens of gigabytes until macOS paused or killed the app.

GPUI uploads every distinct `RenderImage` into the Metal sprite atlas and never frees the tile unless `drop_image` is called. Playback, live camera, quick look, and storyboard were minting a new image every frame and dropping only the CPU buffer, so Apple Silicon unified memory kept every old frame resident (~0.5 GB/s at 1080p60, ~2 GB/s at 4K).

Recording on the GPUI runtime now matches the egui behavior: Stop returns immediately instead of freezing the window, Recording and Devices settings stick, and system audio captures real sound instead of digital silence.

### Memory

- Preview, camera PiP, quick-look video, storyboard playback, and Devices camera now retire the previous atlas tile when a new frame arrives
- CPU composites, rotated clips, and blur-region mosaics reuse one tile while the playhead and pixels are unchanged, instead of uploading a new image on every paint
- Timeline GPU thumbs and stills are LRU-capped; clearing those caches actually releases Metal tiles
- Memory-pressure handlers now evict preview and timeline GPU images, not only CPU thumbnail / waveform caches

### Timeline editing

- Delete and Backspace both remove the current selection (clips, gaps, or keyframes); Shift+Backspace ripples the selection and Cmd+Backspace ripples the in/out range, matching the existing Shift+Delete / Cmd+Delete bindings
- Clicking a clip or gap on the timeline now steals keyboard focus, so Backspace / Delete reach clip and gap editing instead of a text field that happened to hold focus
- The timeline keeps a `Workspace Playback Timeline` key context, so NLE shortcuts keep firing after a clip or gap click
- Delete, ripple-delete, and ripple-delete-in/out are ignored while an annotation text label is being edited, so Backspace edits text instead of deleting the clip

### Runtime

- Export progress no longer calls `notify` from inside `render`, which was spinning a full-app redraw for the entire export
- Waiting for a first decoded frame times out after five seconds, so a stalled or missing decoder cannot pin the animation loop at display rate

### Recording

Stop recording no longer freezes the window. Native ScreenCaptureKit / AVFoundation teardown and `ffprobe` probes run on a worker; the record button becomes a disabled spinner until the take is imported, so repeated clicks cannot start a second take on top of one that is still finalizing.

- Recording and Devices preferences now stick: `AppSession.capture` is the single source of truth, so the 250ms poll no longer overwrites Recording-tab toggles with the manager's stale copy
- System audio is independent of screen capture, so an audio-only take is valid and is imported instead of being silently deleted
- ScreenCaptureKit no longer excludes KnoxStudio's own output, which was recording digital silence when previewing timeline media or capturing a walkthrough of the app
- A silent system-audio capture is reported in the UI instead of adding a dead track that looks like a success
- Native start no longer reports success when the ScreenCaptureKit semaphore times out
- Camera permission no longer deadlocks the main thread waiting on the system prompt
- Quitting mid-take finalizes the recording so the `.mov` is playable
- Import uses durations and resolution already probed on the finalize worker, so `ffprobe` never runs on the UI thread

### Voice Director

The composer mic, status meter, and header badge share one clock and the same smoothed mic / playback envelopes. User speech is aqua with inward ripples; the agent is violet with outward ripples. Thinking is amber chasing dots; connecting breathes teal; error is a static red.

- Mic orb fill, glyph, and ripple rings follow session state and live loudness instead of a static teal/red circle
- Status row adds a 15-bar meter beside the hint; live captions stay body-coloured because the meter already carries the state
- Header Voice Director badge tints to the same accent and glyph as the composer orb, including the device-picker speaker
- Mic RMS is attack/release-smoothed and noise-gated; assistant playback envelope is exposed so AI speech drives the indicator instead of leftover speaker bleed into the mic
- Voice chrome only schedules frames while something is moving (speech, thinking, connecting, or a loud ready-state room). A quiet Connected session stays off the animation loop; reduced motion draws a static snapshot

## [1.5.0]

KnoxStudio now runs on **GPUI + gpui-kit** instead of egui/eframe. The NLE, capture, export, and AI domain stay the same; the window runtime is a retained-mode Mac app.

### Runtime

- GPUI with gpui-kit: GPU-composited window, native TitleBar, resizable splits, overlays, and semantic light/dark theme
- Native macOS application menu (KnoxStudio / File / Edit / View / Playback / Window / Help) with system Undo, Redo, Cut, Copy, Paste
- Finder, Dock, and `open` file events through GPUI `on_open_urls` — no vendored winit patch
- Session split into independent entities: `Document`, `Workspace`, canvas, timeline, Inspector, Agent, Screenplay
- Playback clock advances the playhead without rebuilding Inspector, Agent, or chrome every display refresh; canvas and timeline request their own animation frames
- Custom GPU `Element`s for the preview canvas and the timeline (hit-testing, paint, thumbs, waveforms)
- Screenplay editor on the kit rope `Editor`: Tree-sitter highlighting, line numbers, soft wrap, find/replace, outline, and git
- Agent composer is a real textarea with @ mentions, decorations, and streaming markdown — not a per-frame egui text edit
- In-app FPS HUD (`gpui-fps`) from GPUI frame timings: FPS, frame time, P95, drop rate, CPU / GPU / memory
- Dedicated tokio runtime so AI, export, and IO never block the UI thread
- Bundle FFmpeg/FFprobe 9.0.1

### What this unlocks

- Native Mac chrome: traffic lights, menus, and OS edit actions instead of a painted-in title bar
- Smoother preview while playing: only the surfaces that show time (canvas, timeline, meters) tick
- A Zed-class text substrate (rope + Tree-sitter + LSP types) for screenplays and a future coding agent
- Observable session state (entities + subscriptions) as working memory for agents and checkpoints
- Drop the eframe/winit activation workaround that existed only to keep bundled-app file-open correct

### Still the same product

Capture, timeline editing, Inspector, Voice Director, generation, export, OAuth, and autosave are the 1.4.x feature set on the new runtime. Domain Criterion benches (`project_benchmarks`) are unchanged; they measure project JSON and timeline ops, not GPU frames.

## [1.4.3]

- Shortener storyboard_projects to be storyboard for media library list
- Keeps a quarter-screen of empty room after the last clip
- Move Title-safe feature to transport from canvas
- Clickable target in the app uses the pointing-hand cursor instead of the default arrow
- Modal UI Optimizations
- Remove First Run Setup modal
- Remove project template
- Defaults tab by default with first time app launch
- Dim covers the strip under the title bar
- Fix Inspector templates were drawing type larger than their boxes
- Canvas actions improvement
- Improve OAuth UX
- Unchecked the camera stays off — no hardware connection

## [1.4.2]

### Added

- Drop PDFs, presentations, spreadsheets, CSVs, and other office files onto the agent composer to attach them as context
- Originals are kept in `~/.knoxmedia/docs/`; a Markdown copy is created beside them so the agent can read the document
- Converted Markdown files appear in `@` mentions from `docs/`, so you can reference them again in later turns
- Click a Markdown file in the Media Library `docs/` folder to open it in the Screenplay Editor for preview and edit

### Timeline & editing

- Fit modes: Contain, Cover, Stretch, and None
- Crop a clip from the Inspector or canvas handles
- Anchor point so scale and rotation orbit a chosen origin
- Blend modes: Multiply, Screen, Overlay, Add, Darken, and Lighten
- Speed ramps, reverse, freeze frame, and slow-mo quality (Duplicate, Blend, Optical)
- J / K / L shuttle: reverse, pause, play, tap for 2× / 4× / 8×
- Compound clips: nest a selection, double-click to open, export the nest
- Transitions in one place: crossfade, dissolve, dip, wipes, slides and pushes in all directions, zoom dissolve, blur dissolve
- Camera PiP as circle, rounded rect, square, or full-frame video
- Multi-select rotation, fit, align, and distribute on the canvas
- Slip tool (Y): change what’s inside a clip without moving its edges

### Animation

- Expand a clip to edit keyframe lanes on the timeline
- Hold and Bezier easing; value graph under the timeline with draggable handles
- Motion path on the canvas when Position X and Y are keyed
- One-click motion presets: Ken Burns, Pop in, Fade up, Slide, Drift, Punch-in
- Optional Ken Burns on new stills (off for existing projects)
- Motion blur on fast-moving clips
- Auto-key: the next move writes a key at the playhead
- Copy, paste, and reverse keyframes
- Parent / follow so a label or PiP stays stuck to a moving clip

### Color & effects

- Per-clip effect stack: enable, mix, reorder, and search by category
- Color grade: exposure, gamma, highlights, shadows, hue, vibrance, plus High contrast / Fade film / Night
- Gaussian blur, sharpen, vignette, 3D LUT, and RGB curves
- Clip mask (ellipse, rectangle, freehand) with invert and feather
- Blur region (pixelate a password) and spotlight (darken everything else)
- Chroma key for green or blue screen
- Adjustment layer that grades all video below it
- Keyframe grade, blur radius, and vignette amount
- Film grain and solid color clips (fade to black / white)

### Titles, cursor & captions

- Zoom-to-region: draw a box and the clip punches in, holds, then eases out
- Auto-zoom on recorded clicks
- Styled pointer overlay: show/hide, scale, and scale-on-click
- Click effects: ripple, sonar, freeze ring, with different left and right colors
- Title in/out: fade, slide, type-on, highlight-on, and draw-on
- Text outline, shadow, and rounded background plate
- Pick any system font for titles (CJK falls back when a face is missing)
- Safe-area guides on the canvas: title-safe, action-safe, 9:16, 1:1
- Caption track: add cues, import/export SRT and VTT, burn in or write a sidecar, auto-caption from speech

### Audio

- Mixer strip: volume, pan, mute, solo, and Peak/RMS meters
- 3-band EQ, high-pass, compressor, and limiter, with a Voice preset
- Ducking you can see: music dips under dialogue with amount, attack, and release
- Fade-curve preview on audio overlaps

### Export & playback

- H.264 / H.265 quality that actually changes the file; Hardware, Software, or Auto encoder
- ProRes Fastest / Normal / Slowest as 422 LT, 422 HQ, and 4444
- Export Whole project, In to Out, Selection, or Marker to Marker
- GIFs keep camera PiP and overlays instead of dropping them
- Social presets: TikTok / Reels 9:16, YouTube 1080p and 4K, Square, Twitter / X
- YouTube chapter list from timeline markers
- Playback Proxy / Auto / Full; export always uses the original
- Smoother preview while playing, full quality when paused; notification when export finishes

### Voice Director

- “Punch in here”, “blur this password”, “make it warm”, “caption this clip”, “export in to out”

## [1.4.1]

### Changed

- Theme (light/dark) and language controls moved from the transport bar to the top bar
- Title bar shows a centered **KnoxStudio — project name**; Screenplay / Canvas moved from the sidebar footer to the leading end of the title bar, after the traffic lights
- Left and right sidebar sections can be toggled from the title bar
- Voice chrome uses a single status line that moves Connecting → Ready → Listening → Thinking → Speaking without stacking the same words
- Stronger multilingual UI coverage

### Fixed

- Export status modal now fully greys out the canvas behind it

## [1.4.0]

### Added

- Auto-update from [GitHub Releases](https://github.com/knoxchat/knoxstudio/releases): check `latest.json` (with API fallback), verify the DMG checksum and Developer ID, replace the installed app, and relaunch. Preferences still has Check for Updates / auto-check.

### Inspector — preview matches export

- Annotation text, strokes, shadows, and corners use **composition pixels** (the project canvas, usually 1920 wide), so a 48 px label on the preview is the same relative size in a 1080p or 720p export
- Export uses the same Latin-then-Noto font stack as the canvas, so "Hello World" is no longer a different width or Regular-only Noto face in Quick Look
- Text wraps to the annotation box; Inspector Size changes wrap width, not font size
- Typography in Annotate: font family (proportional / monospace), size, bold / italic / underline, and left / center / right alignment — preview and export both honor them
- Line and arrow endpoints and callout tails are Inspector fields, not canvas-only; templates use EN/ZH copy and composition-pixel sizes
- Drawing an annotation always creates a **linked** timeline clip; deleting one side removes the other; Timing edits the clip, not an orphan overlay
- Annotation list filters to the playhead, shows layer, and reorders layers by drag; Callout and numbered Step have tool shortcuts **1–9**
- **Annotation keyframes** for position, scale, rotation, and opacity (same diamonds as Actions). Preview follows the playhead; export writes a PNG sequence when any of those properties are keyed, otherwise a static overlay plus fade
- Lock, visibility, and layer order undo as recorded commands instead of a full project snapshot; dragging to reorder layers is one undo step
- Export rasterizes **every** annotation kind — including simple rectangles and highlights — through the same PNG drawer as the canvas, so fill, stroke, and corners match preview (ffmpeg `drawbox` is no longer used)

### Inspector — clip, audio, actions, filters

- Selecting a clip or annotation opens the matching Inspector tab (Video / Audio / Annotate); `⌘1` focuses the panel **and** that tab. Tab and panel width (up to ~380 px) persist
- Clip tab: in/out points, probed duration off the hot path, lock goes through undo. Annotation clips jump to Annotate instead of an empty Video page
- Audio processing (normalize / ducking / noise reduction, fades) is undoable; empty state when the clip has no audio
- Actions: speed includes reverse, keyframes stay inside the clip, opacity lives here only
- Multi-select applies volume, mute, and opacity to every selected clip as one undo step; unique fields (name, start, in/out, offset, color, speed, transform) show **Mixed** and stay disabled
- **Filters** is color grading: brightness, contrast, saturation, temperature, Reset, and B&W / Warm / Cool presets. Preview tints the frame; export uses matching ffmpeg `eq` / `colorbalance`. Identity grade adds no filter. Timeline clip-chip color moved to the Clip tab
- Tools, Templates, Typography, and Transform sections collapse; open/closed state is remembered
- Empty states instead of greyed-out dummy sliders: select a clip, select or draw an annotation, or "this clip has no audio"
- Audio Peak/RMS meters follow the playhead; volume can be keyed like opacity, with per-key ease (clip and annotation tracks)
- Canvas move/resize of an annotation writes a key at the playhead when Position or Scale is already keyed
- Still-image duration is editable on the Clip tab; locked clips show a notice on Clip and Audio
- Audio tab can add a crossfade with the neighboring clip; Annotate Transform has aspect lock and a nudge amount
- Text / callout / step have line height and letter spacing; click-effect changes undo per field

### Sign in with Knox.chat

- Preferences → Defaults: **Sign in with KnoxStudio** (OAuth2 + PKCE) instead of pasting an API key as the primary path. Production consent is `https://knoxstudio.ai/oauth2/authorize`; token exchange stays on `https://api.knox.chat`.
- After you allow access in the browser, the app mints a hidden `KnoxStudio Desktop` key and stores it in the macOS Keychain
- Connected account shows `@username`; Sign out revokes the key on the server when the network is available
- **Advanced** still accepts a pasted `sk-` key, including keys saved before this change
- Cancel after mint could leak a key & Advanced paste left a stale OAuth session
- Shape AI models config modal bars fill the same horizontal bounds

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
