# 03 — Vesper: Feature Specification

## Feature Map

```
Vesper
├── Recording Engine
│   ├── Core recording
│   ├── Audio import
│   └── Waveform visualization
├── Transcription
│   ├── On-device (whisper.cpp)
│   ├── Cloud fallback (Groq)
│   ├── Multi-language
│   └── Speaker diarization
├── AI Layer
│   ├── Summarization
│   ├── Action item extraction
│   ├── Auto-tagging
│   ├── Mood detection
│   ├── Title generation
│   └── Custom prompts
├── Vault
│   ├── Note management
│   ├── Folders
│   ├── Tags
│   └── Full-text search
├── Playback
│   ├── Synchronized transcript
│   ├── Speed control
│   └── Waveform scrubbing
├── Export
│   ├── Plain text
│   ├── Markdown
│   └── PDF
└── Settings
    ├── Transcription preferences
    ├── AI preferences
    ├── Theme
    └── API key management
```

---

## F1 — Recording Engine

### F1.1 Core Recording
- One-tap recording from any screen via persistent floating action button
- Background recording — app can be minimized during recording
- Pause and resume during an active recording session
- Recording timer displayed prominently during active session
- Audio encoded as `.m4a` (AAC) for storage efficiency
- Configurable audio quality: Standard (64kbps), High (128kbps), Lossless (WAV)

### F1.2 Audio Import
- Import existing audio files from device storage
- Supported formats: MP3, M4A, WAV, FLAC, OGG, AAC
- File size limit: 500MB per file
- Imported files treated identically to recorded memos post-import

### F1.3 Waveform Visualization
- Real-time waveform drawn during recording using amplitude data from Rust audio engine
- Waveform scrolls horizontally as recording progresses
- Waveform rendered as a mirrored bar chart (top + bottom symmetry)
- Color of waveform reacts to amplitude — quiet sections are muted, loud sections bright

---

## F2 — Recording Orb (Hero Interaction)

The recording orb is the centrepiece UI element of Vesper. It must feel alive.

### States

| State | Visual Behaviour |
|-------|-----------------|
| **Idle** | Slow breathing pulse — orb gently scales up/down on a ~3s cycle. Soft glow. |
| **Recording** | Amplitude-reactive waves emanate outward from centre. Wave speed and size proportional to voice volume. Orb tints to accent color. |
| **Processing** | Slow shimmer/rotation animation. Indicates AI is working. Non-reactive to input. |
| **Complete** | Satisfying collapse — waves retract, orb pulses once, then transitions to transcript view. |
| **Paused** | Waves freeze. Orb dims slightly. A visual pause indicator overlays centre. |

### Interaction
- Tap to start recording
- Tap again to pause
- Hold (long press) to stop and trigger processing
- Double tap to cancel and discard

---

## F3 — Transcription

### F3.1 On-Device (Default)
- Uses whisper.cpp via `whisper-rs` Rust bindings
- Model options (user configurable):
  - `whisper-tiny` — fastest, lowest accuracy
  - `whisper-base` — default, good balance
  - `whisper-small` — better accuracy, moderate speed
  - `whisper-medium` — high accuracy, slower
- Model files downloaded on first use and cached locally
- Transcription runs entirely offline — no data leaves device

### F3.2 Cloud Transcription (Optional)
- Uses Groq Whisper API (`whisper-large-v3-turbo`)
- Requires user to provide their own Groq API key
- Significantly faster and more accurate than on-device small models
- Opt-in only — user must explicitly enable in settings
- Clear UI indicator when cloud mode is active

### F3.3 Multi-Language Support
- Whisper supports 99 languages natively
- Language can be set to Auto-detect or manually selected
- Language preference saved per-note and globally

### F3.4 Speaker Diarization
- Identifies and labels distinct speakers in a recording
- Labels: Speaker 1, Speaker 2, etc. (user can rename)
- Displayed inline in transcript with color-coded speaker labels
- Powered by a lightweight diarization model running post-transcription

### F3.5 Transcript Format
- Transcript segmented by time — each segment has a start timestamp
- Word-level confidence scores stored internally (used for highlighting uncertain words)
- Uncertain words visually indicated with subtle underline in transcript view

---

## F4 — AI Layer (Groq + Llama 3)

All AI features require a Groq API key. If no key is provided, transcription still works (on-device) but AI features are disabled with a clear prompt to add a key.

### F4.1 Smart Summary
- Concise paragraph summary of the recording content
- Adapts length to recording length — short memos get 1-2 sentences, long recordings get structured paragraphs

### F4.2 Action Item Extraction
- Identifies tasks, todos, and follow-ups mentioned in the recording
- Displayed as a checklist below the summary
- Each action item is checkable within Vesper (state persisted locally)

### F4.3 Auto-Tagging
- Automatically generates 3-6 topic tags per note
- Tags are editable by user post-generation
- Tags feed into the vault's filtering system

### F4.4 Mood / Tone Detection
- Detects the emotional tone of the recording
- Categories: Neutral, Reflective, Energetic, Stressed, Focused, Creative
- Displayed as a subtle badge on the note card

### F4.5 Title Generation
- Auto-generates a short, descriptive title for each note
- User can edit the title at any time
- Falls back to date/time if AI is unavailable

### F4.6 Custom Prompts
- User can define their own prompt templates
- Templates applied to every note automatically, or triggered manually
- Examples: "Extract all names mentioned", "List all decisions made", "Summarize in bullet points"
- Up to 10 saved templates

---

## F5 — Vault

### F5.1 Note List
- Default view: chronological, newest first
- Each note card shows: title, date, duration, tags, mood badge, summary snippet
- Swipe actions on mobile: archive (left), delete (right)
- Multi-select mode for bulk actions

### F5.2 Folders
- User-created folders for organizing notes
- Nested folders supported (up to 3 levels deep)
- Notes can exist in multiple folders (many-to-many)
- Default folders: All Notes, Recent, Archived

### F5.3 Tags
- Auto-generated tags + manual tags
- Tag browser view — see all tags and note counts
- Filter vault by one or multiple tags simultaneously

### F5.4 Full-Text Search
- Search across: titles, transcripts, summaries, action items, tags
- Real-time results as user types
- Matched terms highlighted in results
- Search scoped to current folder or global

### F5.5 Note Actions
- Pin note to top of vault
- Archive note (hidden from main view, accessible in Archive folder)
- Delete note (moves to Trash)
- Trash with 30-day auto-purge and manual restore

---

## F6 — Synchronized Playback

- Audio playback synced word-for-word with transcript
- Currently playing word highlighted in transcript in real time
- Tap any word in transcript to jump to that moment in audio
- Waveform scrubber synced to playback position
- Playback speed: 0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x
- Skip silence — automatically skips long silent gaps during playback

---

## F7 — Export

### F7.1 Export Formats
| Format | Contents |
|--------|----------|
| Plain Text (`.txt`) | Transcript only |
| Markdown (`.md`) | Title, summary, action items, tags, full transcript with timestamps |
| PDF (`.pdf`) | Formatted document with Vesper branding, all content |

### F7.2 Share
- Native share sheet on iOS and Android
- Copy to clipboard (transcript or summary independently)
- Save to Files app (iOS) / Downloads (Android/Windows/macOS)

---

## F8 — Settings

### Transcription
- Default transcription mode (on-device / cloud)
- On-device model selection (tiny / base / small / medium)
- Default language (auto-detect or specific language)

### AI
- Groq API key input (stored in platform secure enclave)
- Default summarization style (paragraph / bullet points / action items only)
- Custom prompt template management

### Appearance
- Theme: Light / Dark / System
- Font size: Small / Medium / Large
- Reduce motion toggle (accessibility)

### Storage
- Storage usage breakdown (audio files vs database)
- Clear cache
- Export all data (full vault backup as zip)
- Delete all data

### About
- Version number
- Open source license info
- Link to GitHub repository
- Acknowledgements (whisper.cpp, Groq, Flutter, Rust)
