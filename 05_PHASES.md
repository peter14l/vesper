# 05 — Vesper: Phased Build Plan

## Overview

Vesper is built across 6 phases. Each phase produces a fully working, internally testable slice of the app. The repo is not released until Phase 6 is complete and all platforms are verified.

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
  Core      Audio     Trans-    AI        Vault     Polish
  Infra     Engine    cription  Layer     & UX      & Ship
```

---

## Phase 1 — Core Infrastructure

**Goal:** Project skeleton, Rust-Flutter bridge, design system, navigation shell

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     PHASE 1 TASKS                        │
└─────────────────────────────────────────────────────────┘

  1. Flutter Project Setup
     ├── Create Flutter project (multi-platform)
     ├── Configure pubspec.yaml with all dependencies
     ├── Set up folder structure (features/, core/, shared/)
     └── Configure go_router navigation

  2. Rust Core Setup
     ├── Create vesper_core Rust library crate
     ├── Add flutter_rust_bridge
     ├── Define FFI interface (lib.rs exports)
     └── Verify bridge compiles on all 4 platforms

  3. Design System Implementation
     ├── Define all color tokens (dark + light)
     ├── Configure flex_color_scheme theme
     ├── Load Plus Jakarta Sans + Lora via google_fonts
     ├── Create spacing constants
     └── Build base component library:
         ├── VesperButton (primary + secondary)
         ├── VesperCard
         ├── VesperTag
         └── VesperTextField

  4. Navigation Shell
     ├── Implement floating tab bar (mobile)
     ├── Implement collapsible sidebar (desktop)
     ├── Set up route guards and deep linking
     └── Placeholder screens for all tabs

  5. Settings Foundation
     ├── Settings screen UI
     ├── shared_preferences integration
     ├── Theme switching (light/dark/system)
     └── Font size preference

DELIVERABLE: App launches on all 4 platforms with correct
theme, navigation, and design system. No features yet.
```

### Acceptance Criteria
- [ ] App builds and runs on Android, iOS, Windows, macOS
- [ ] Dark/light theme switching works
- [ ] Navigation between all placeholder screens works
- [ ] Rust bridge compiles and a hello-world FFI call succeeds
- [ ] Design tokens applied correctly

---

## Phase 2 — Audio Engine

**Goal:** Full recording and playback capability via Rust audio engine

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     PHASE 2 TASKS                        │
└─────────────────────────────────────────────────────────┘

  1. Rust Audio Recording
     ├── Implement audio capture via cpal
     ├── Encode to M4A (AAC) via platform encoder
     ├── Stream amplitude data to Flutter in real time
     ├── Implement pause/resume/stop
     └── Save audio file to platform documents dir

  2. Recording Orb UI
     ├── Build orb widget (CustomPainter)
     ├── Implement idle breathing animation
     ├── Implement amplitude-reactive wave rings
     │   └── Rings expand outward, opacity 0.6 → 0
     │       Speed and size proportional to amplitude
     ├── Implement paused state (frozen waves, dimmed)
     └── Implement complete state (rings retract, flash)

  3. Recording Screen
     ├── Full-screen recording view
     ├── Orb centred in screen
     ├── Recording timer (MM:SS)
     ├── Waveform history scrolling behind orb
     ├── Pause / Stop controls
     └── Discard confirmation dialog

  4. Audio Playback
     ├── Implement playback via just_audio
     ├── Waveform scrubber widget
     ├── Playback speed control (0.5x → 2x)
     └── Skip silence feature

  5. Audio Import
     ├── File picker integration
     ├── Format validation (mp3, m4a, wav, flac, ogg)
     ├── Copy imported file to app storage
     └── Trigger processing pipeline post-import

  6. Local Storage — Audio Layer
     ├── SQLite schema for Note table (partial)
     │   ├── id, title, created_at, duration_ms
     │   └── audio_file_path
     └── CRUD operations for notes

FLOW: User taps orb → Recording starts → Amplitude streams
      to Flutter → Orb waves react → User stops →
      Audio saved to disk → Note created in DB →
      Navigate to processing screen

┌──────┐    ┌──────────┐    ┌─────────┐    ┌──────────┐
│ Tap  │───▶│ Rust     │───▶│ Flutter │───▶│ Note     │
│ Orb  │    │ Records  │    │ Orb     │    │ Saved    │
└──────┘    │ Audio    │    │ Reacts  │    │ to DB    │
            └──────────┘    └─────────┘    └──────────┘
                │                               │
                │ amplitude stream              │ audio path
                ▼                               ▼
            Real-time                      Note detail
            waveform                       screen (empty)
```

### Acceptance Criteria
- [ ] Can record audio on all 4 platforms
- [ ] Orb reacts visually to voice amplitude in real time
- [ ] Pause/resume works correctly
- [ ] Audio saved and playable after recording
- [ ] Waveform scrubber syncs with playback position
- [ ] Audio files importable from device storage

---

## Phase 3 — Transcription Engine

**Goal:** On-device and cloud transcription, speaker diarization, synchronized transcript

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     PHASE 3 TASKS                        │
└─────────────────────────────────────────────────────────┘

  1. whisper.cpp Integration (Rust)
     ├── Add whisper-rs to Cargo.toml
     ├── Implement model download + caching
     │   └── Models: tiny, base, small, medium
     ├── Implement transcription function:
     │   ├── Input: audio file path + model choice
     │   ├── Output: Vec<Segment> with timestamps + text
     │   └── Run on background thread (tokio)
     └── Expose via FFI to Flutter

  2. Groq Cloud Transcription (Rust)
     ├── Implement Groq Whisper API client via reqwest
     ├── Model: whisper-large-v3-turbo
     ├── Handle API key from settings (passed via FFI)
     ├── Same output format as on-device
     └── Error handling: fallback to on-device if API fails

  3. Processing Screen
     ├── Shown after recording/import
     ├── Orb in "processing" shimmer state
     ├── Progress indicator with status text:
     │   "Transcribing..." → "Analysing..." → "Done"
     └── Cancel option (discards note)

  4. Speaker Diarization
     ├── Post-transcription diarization pass
     ├── Assign speaker IDs to each segment
     ├── Store speaker labels in DB
     └── Allow user to rename speaker labels

  5. Transcript Data Model
     ├── Segment table: note_id, start_ms, end_ms,
     │                  text, speaker_id, confidence
     └── Word table (optional, for word-level sync):
         note_id, segment_id, start_ms, end_ms, word, confidence

  6. Synchronized Transcript UI
     ├── Transcript rendered as scrollable list of segments
     ├── Each segment: [timestamp] [speaker] [text in Lora]
     ├── Tap segment → audio jumps to that timestamp
     ├── During playback: current segment highlighted
     └── Word-level highlight if word table is populated

  7. Settings — Transcription
     ├── Mode selector: On-device / Cloud
     ├── Model selector (on-device only)
     ├── Language selector (auto + 99 languages)
     └── Model download management UI

TRANSCRIPTION PIPELINE:

┌──────────┐     ┌─────────────────────────────────────┐
│  Audio   │────▶│           Rust Core                  │
│  File    │     │                                      │
└──────────┘     │  ┌─────────┐      ┌──────────────┐  │
                 │  │ On-     │  OR  │ Groq Cloud   │  │
                 │  │ Device  │      │ Whisper API  │  │
                 │  │ Whisper │      │              │  │
                 │  └────┬────┘      └──────┬───────┘  │
                 │       └──────────────────┘          │
                 │                │                    │
                 │       ┌────────▼────────┐           │
                 │       │  Diarization    │           │
                 │       └────────┬────────┘           │
                 │                │                    │
                 │       ┌────────▼────────┐           │
                 │       │  Vec<Segment>   │           │
                 │       └────────┬────────┘           │
                 └────────────────┼────────────────────┘
                                  │ FFI
                         ┌────────▼────────┐
                         │  Flutter DB     │
                         │  (Drift/SQLite) │
                         └────────┬────────┘
                                  │
                         ┌────────▼────────┐
                         │  Transcript UI  │
                         └─────────────────┘
```

### Acceptance Criteria
- [ ] On-device transcription works offline on all 4 platforms
- [ ] Cloud transcription works with valid Groq API key
- [ ] Diarization correctly identifies multiple speakers
- [ ] Transcript displays with correct speaker labels + timestamps
- [ ] Tapping a transcript segment jumps audio to correct position
- [ ] Current segment highlights during playback

---

## Phase 4 — AI Layer

**Goal:** Full AI pipeline — summary, action items, tags, mood, title, custom prompts

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     PHASE 4 TASKS                        │
└─────────────────────────────────────────────────────────┘

  1. Groq LLM Client (Rust)
     ├── reqwest client for Groq /v1/chat/completions
     ├── Model: llama-3.3-70b-versatile (primary)
     │         llama-3.1-8b-instant (fallback)
     ├── Structured JSON output prompting
     └── Error handling + retry logic

  2. AI Prompts
     Each prompt takes the full transcript as input.
     All run in a SINGLE Groq API call using a structured
     output prompt that returns JSON with all fields.

     Prompt output schema:
     {
       "title": "string",
       "summary": "string",
       "action_items": ["string"],
       "tags": ["string"],
       "mood": "neutral|reflective|energetic|stressed|focused|creative"
     }

  3. Custom Prompt Templates
     ├── User-defined prompt templates (up to 10)
     ├── Each template: name + prompt string
     ├── {{transcript}} placeholder replaced at runtime
     ├── Output: freeform text displayed in note
     └── Templates managed in Settings

  4. Note Detail Screen — AI Panel
     ├── Summary section (collapsible)
     ├── Action items as interactive checklist
     │   └── Check state persisted in DB
     ├── Auto-tags displayed + editable
     ├── Mood badge in header
     └── Custom prompt results panel

  5. AI Data Model
     ├── Add to Note table:
     │   ├── summary TEXT
     │   ├── mood TEXT
     │   └── ai_title TEXT
     ├── ActionItem table:
     │   ├── id, note_id, text, is_complete
     └── CustomPromptResult table:
         ├── id, note_id, template_id, result_text

  6. Re-run AI
     ├── User can re-trigger AI analysis on any note
     ├── Useful after editing transcript
     └── Previous AI results overwritten (with confirmation)

AI PIPELINE FLOW:

┌────────────────┐
│  Transcription │
│  Complete      │
└───────┬────────┘
        │
        ▼
┌────────────────┐     ┌──────────────────────────────┐
│ Build prompt   │────▶│      Groq API                 │
│ with full      │     │  llama-3.3-70b-versatile      │
│ transcript     │     │                               │
└────────────────┘     │  Input: transcript text       │
                       │  Output: structured JSON      │
                       └──────────────┬───────────────┘
                                      │
                              ┌───────▼───────┐
                              │  Parse JSON   │
                              └───────┬───────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
    ┌─────────▼───────┐   ┌──────────▼──────┐   ┌───────────▼──────┐
    │ Save to DB      │   │ Render in UI     │   │ Run custom       │
    │ title, summary, │   │ summary panel,   │   │ prompt templates │
    │ mood, tags,     │   │ action checklist,│   │ (if any defined) │
    │ action items    │   │ tags, mood badge │   └──────────────────┘
    └─────────────────┘   └─────────────────┘
```

### Acceptance Criteria
- [ ] Single Groq API call returns all AI fields correctly
- [ ] Summary, action items, tags, mood, title all populate
- [ ] Action item checkboxes persist state
- [ ] Tags editable after AI generation
- [ ] Custom prompt templates save and execute
- [ ] Re-run AI works correctly

---

## Phase 5 — Vault, Search & Export

**Goal:** Full note management system — vault, folders, tags, search, export

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     PHASE 5 TASKS                        │
└─────────────────────────────────────────────────────────┘

  1. Vault Screen
     ├── Note list with full card design
     ├── Sort: newest, oldest, duration, title
     ├── Filter by: folder, tag, mood, date range
     ├── Swipe actions (mobile): archive / delete
     ├── Multi-select mode + bulk actions
     └── Empty state illustration

  2. Folder System
     ├── Create / rename / delete folders
     ├── Nested folders (max 3 levels)
     ├── Move notes to folders
     ├── Note can belong to multiple folders
     └── Folder list in sidebar (desktop) / drawer (mobile)

  3. Full-Text Search
     ├── SQLite FTS5 (full-text search extension)
     ├── Index: title, transcript, summary, action items, tags
     ├── Real-time results as user types
     ├── Highlight matched terms in results
     ├── Scope: current folder or global
     └── Recent searches saved locally

  4. Tag System
     ├── Tag browser screen (all tags + note count)
     ├── Filter vault by single or multiple tags
     ├── Auto-tag vs manual tag visual distinction
     └── Merge tags (combine two tags into one)

  5. Archive + Trash
     ├── Archive: hidden from main vault, in Archive folder
     ├── Trash: deleted notes held for 30 days
     ├── Restore from trash
     ├── Permanent delete from trash
     └── Auto-purge after 30 days

  6. Export
     ├── Plain text export
     ├── Markdown export (title + summary + action items
     │                    + tags + full transcript)
     ├── PDF export (formatted, Vesper branded)
     └── Native share sheet / save to Files

  7. Note Detail — Full Layout
     ├── Header: title (editable), date, duration, mood
     ├── Tabs: Summary | Transcript | Actions
     ├── Floating audio player bar at bottom
     │   └── Plays/pauses, scrubs, shows current time
     └── Edit transcript (tap to edit any segment text)

VAULT INFORMATION ARCHITECTURE:

All Notes
├── Recent (last 7 days)
├── Pinned
├── [User Folder 1]
│   └── [Nested Folder]
├── [User Folder 2]
├── Archived
└── Trash

SEARCH FLOW:

User types query
      │
      ▼
SQLite FTS5 query across
title + transcript + summary
+ action items + tags
      │
      ▼
Results ranked by relevance
      │
      ▼
Display with matched terms
highlighted in card snippet
```

### Acceptance Criteria
- [ ] Full vault with sorting + filtering works
- [ ] Folders created, nested, and notes assigned
- [ ] Search returns correct results in real time
- [ ] Archive and trash work with 30-day auto-purge
- [ ] Export to txt, md, pdf works on all platforms
- [ ] Note transcript is editable inline

---

## Phase 6 — Polish, Performance & Ship Prep

**Goal:** Cross-platform parity, performance optimisation, onboarding, accessibility, README

### Workflow

```
┌─────────────────────────────────────────────────────────┐
│                     PHASE 6 TASKS                        │
└─────────────────────────────────────────────────────────┘

  1. Performance Pass
     ├── Profile Flutter rendering (no jank on orb animation)
     ├── Profile Rust transcription memory usage
     ├── Lazy load note list (pagination)
     ├── Audio waveform rendering optimisation
     └── Cold start time < 1.5s on all platforms

  2. Cross-Platform Parity Audit
     ├── Test every feature on Android, iOS, Windows, macOS
     ├── Fix platform-specific layout issues
     ├── Verify keyboard shortcuts on desktop
     └── Verify file paths and storage on all platforms

  3. Onboarding Flow
     ├── First-launch walkthrough (3 screens max)
     │   ├── Screen 1: Welcome + what Vesper does
     │   ├── Screen 2: Microphone permission request
     │   └── Screen 3: Optional Groq API key setup
     ├── Empty state screens with helpful prompts
     └── Tooltip hints on first use of key features

  4. Accessibility Pass
     ├── Semantic labels on all interactive elements
     ├── Verify 4.5:1 contrast ratio throughout
     ├── Test with TalkBack (Android) + VoiceOver (iOS)
     ├── Verify reduce-motion disables all animations
     └── Minimum 44x44dp touch targets everywhere

  5. Error Handling & Edge Cases
     ├── No microphone permission — graceful error
     ├── Groq API key invalid — clear error message
     ├── No internet in cloud mode — fallback to on-device
     ├── Storage full — warning before recording
     ├── Transcription fails — retry option
     └── App backgrounded during recording — continues correctly

  6. Open Source Prep
     ├── Write comprehensive README.md
     │   ├── Project overview + screenshots
     │   ├── Build instructions for all platforms
     │   ├── Architecture explanation
     │   └── Contributing guide
     ├── Add LICENSE (MIT)
     ├── Add CONTRIBUTING.md
     ├── Add GitHub issue templates
     ├── Add GitHub Actions CI (build check on PR)
     └── Clean up all debug code and TODOs

  7. Final QA
     ├── Full regression test on all 4 platforms
     ├── Memory leak check (especially long recordings)
     └── Battery usage check (background recording)

SHIP CHECKLIST:

  □ All Phase 1-5 acceptance criteria met
  □ No crashes on any platform in 1hr stress test
  □ README complete with screenshots
  □ LICENSE file present
  □ CI pipeline passing
  □ All debug logs removed
  □ API key not hardcoded anywhere
  □ .gitignore covers build artifacts and secrets
  □ Initial GitHub release tagged v1.0.0
```

### Acceptance Criteria
- [ ] App runs smoothly (60fps) on all platforms
- [ ] Cold start under 1.5s
- [ ] All features work identically across all 4 platforms
- [ ] Onboarding flow completes without errors
- [ ] All accessibility requirements met
- [ ] README is complete and clear
- [ ] CI passing on GitHub Actions
- [ ] No hardcoded secrets or API keys

---

## Phase Summary Table

| Phase | Focus | Key Deliverable |
|-------|-------|----------------|
| 1 | Core Infrastructure | App shell, design system, Rust bridge |
| 2 | Audio Engine | Recording orb, audio capture + playback |
| 3 | Transcription | On-device + cloud transcription, sync transcript |
| 4 | AI Layer | Summary, actions, tags, mood, custom prompts |
| 5 | Vault & UX | Full note management, search, export |
| 6 | Polish & Ship | Performance, accessibility, open source release |
