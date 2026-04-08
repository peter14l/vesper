# 06 — Vesper: Data Models

## Storage Architecture

Vesper is local-first. All data lives on the user's device. There is no backend server, no user accounts, no sync.

```
App Documents Directory
├── vesper.db              ← SQLite database (all structured data)
└── audio/
    ├── {note_id}.m4a      ← Audio recordings
    └── {note_id}_imported.{ext}  ← Imported audio files
```

---

## SQLite Schema

### Table: notes

Primary record for every voice note.

```sql
CREATE TABLE notes (
  id              TEXT PRIMARY KEY,        -- UUID v4
  title           TEXT NOT NULL,           -- User-editable or AI-generated
  ai_title        TEXT,                    -- Raw AI-generated title
  created_at      INTEGER NOT NULL,        -- Unix timestamp (ms)
  updated_at      INTEGER NOT NULL,        -- Unix timestamp (ms)
  duration_ms     INTEGER NOT NULL,        -- Audio duration in milliseconds
  audio_path      TEXT NOT NULL,           -- Relative path to audio file
  language        TEXT DEFAULT 'auto',     -- ISO 639-1 code or 'auto'
  transcription_mode TEXT NOT NULL,        -- 'on_device' | 'cloud'
  whisper_model   TEXT,                    -- Model used (e.g. 'base')
  summary         TEXT,                    -- AI-generated summary
  mood            TEXT,                    -- 'neutral'|'reflective'|'energetic'|'stressed'|'focused'|'creative'
  is_pinned       INTEGER DEFAULT 0,       -- Boolean (0/1)
  is_archived     INTEGER DEFAULT 0,       -- Boolean (0/1)
  is_deleted      INTEGER DEFAULT 0,       -- Boolean (0/1) — soft delete
  deleted_at      INTEGER,                 -- Timestamp of soft delete
  word_count      INTEGER DEFAULT 0        -- Derived from transcript
);
```

### Table: segments

Transcript segments with timestamps and speaker info.

```sql
CREATE TABLE segments (
  id              TEXT PRIMARY KEY,        -- UUID v4
  note_id         TEXT NOT NULL,           -- FK → notes.id
  start_ms        INTEGER NOT NULL,        -- Start time in milliseconds
  end_ms          INTEGER NOT NULL,        -- End time in milliseconds
  text            TEXT NOT NULL,           -- Transcribed text
  speaker_id      TEXT,                    -- 'speaker_1', 'speaker_2', etc.
  confidence      REAL,                    -- 0.0 to 1.0
  is_edited       INTEGER DEFAULT 0,       -- User has manually edited this segment
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
);

CREATE INDEX idx_segments_note_id ON segments(note_id);
CREATE INDEX idx_segments_start_ms ON segments(start_ms);
```

### Table: words

Word-level timestamps for synchronized playback (optional — populated when available).

```sql
CREATE TABLE words (
  id              TEXT PRIMARY KEY,
  note_id         TEXT NOT NULL,
  segment_id      TEXT NOT NULL,
  start_ms        INTEGER NOT NULL,
  end_ms          INTEGER NOT NULL,
  word            TEXT NOT NULL,
  confidence      REAL,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
  FOREIGN KEY (segment_id) REFERENCES segments(id) ON DELETE CASCADE
);

CREATE INDEX idx_words_note_id ON words(note_id);
```

### Table: speakers

Speaker labels per note (user-renameable).

```sql
CREATE TABLE speakers (
  id              TEXT PRIMARY KEY,        -- UUID v4
  note_id         TEXT NOT NULL,           -- FK → notes.id
  speaker_key     TEXT NOT NULL,           -- 'speaker_1', 'speaker_2'
  display_name    TEXT NOT NULL,           -- User-facing name ('Alice', 'Speaker 1')
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
);
```

### Table: action_items

AI-extracted tasks and todos.

```sql
CREATE TABLE action_items (
  id              TEXT PRIMARY KEY,        -- UUID v4
  note_id         TEXT NOT NULL,           -- FK → notes.id
  text            TEXT NOT NULL,           -- Action item text
  is_complete     INTEGER DEFAULT 0,       -- Boolean (0/1)
  position        INTEGER NOT NULL,        -- Display order
  created_at      INTEGER NOT NULL,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE
);
```

### Table: tags

Tag definitions.

```sql
CREATE TABLE tags (
  id              TEXT PRIMARY KEY,        -- UUID v4
  name            TEXT NOT NULL UNIQUE,    -- Tag name (lowercase, trimmed)
  is_auto         INTEGER DEFAULT 0,       -- 1 = AI-generated, 0 = user-created
  created_at      INTEGER NOT NULL
);
```

### Table: note_tags

Many-to-many join between notes and tags.

```sql
CREATE TABLE note_tags (
  note_id         TEXT NOT NULL,
  tag_id          TEXT NOT NULL,
  PRIMARY KEY (note_id, tag_id),
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);
```

### Table: folders

User-created folder hierarchy.

```sql
CREATE TABLE folders (
  id              TEXT PRIMARY KEY,        -- UUID v4
  name            TEXT NOT NULL,
  parent_id       TEXT,                    -- NULL = root folder; FK → folders.id
  position        INTEGER DEFAULT 0,       -- Display order within parent
  created_at      INTEGER NOT NULL,
  FOREIGN KEY (parent_id) REFERENCES folders(id) ON DELETE CASCADE
);
```

### Table: note_folders

Many-to-many join between notes and folders.

```sql
CREATE TABLE note_folders (
  note_id         TEXT NOT NULL,
  folder_id       TEXT NOT NULL,
  PRIMARY KEY (note_id, folder_id),
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
  FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
);
```

### Table: custom_prompt_templates

User-defined AI prompt templates.

```sql
CREATE TABLE custom_prompt_templates (
  id              TEXT PRIMARY KEY,        -- UUID v4
  name            TEXT NOT NULL,           -- Template name
  prompt          TEXT NOT NULL,           -- Prompt with {{transcript}} placeholder
  position        INTEGER DEFAULT 0,       -- Display order in settings
  created_at      INTEGER NOT NULL
);
```

### Table: custom_prompt_results

Results from running custom templates on notes.

```sql
CREATE TABLE custom_prompt_results (
  id              TEXT PRIMARY KEY,
  note_id         TEXT NOT NULL,
  template_id     TEXT NOT NULL,
  result_text     TEXT NOT NULL,
  generated_at    INTEGER NOT NULL,
  FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE,
  FOREIGN KEY (template_id) REFERENCES custom_prompt_templates(id) ON DELETE CASCADE
);
```

### Full-Text Search Virtual Table

```sql
CREATE VIRTUAL TABLE notes_fts USING fts5(
  note_id UNINDEXED,
  title,
  summary,
  transcript_text,  -- Full concatenated transcript
  action_items_text -- Concatenated action items
);
```

FTS table is rebuilt/updated whenever a note's content changes.

---

## FFI Data Types (Rust ↔ Flutter)

These are the types exchanged across the flutter_rust_bridge FFI boundary.

```rust
// Rust side — vesper_core/src/lib.rs

pub struct TranscriptionSegment {
    pub start_ms: u64,
    pub end_ms: u64,
    pub text: String,
    pub speaker_id: Option<String>,
    pub confidence: f32,
    pub words: Vec<WordTimestamp>,
}

pub struct WordTimestamp {
    pub start_ms: u64,
    pub end_ms: u64,
    pub word: String,
    pub confidence: f32,
}

pub struct TranscriptionResult {
    pub segments: Vec<TranscriptionSegment>,
    pub language_detected: String,
    pub duration_ms: u64,
}

pub struct AiAnalysisResult {
    pub title: String,
    pub summary: String,
    pub action_items: Vec<String>,
    pub tags: Vec<String>,
    pub mood: String,
}

pub struct AudioAmplitude {
    pub value: f32,  // 0.0 to 1.0, streamed during recording
}
```

---

## Settings Schema (shared_preferences)

Lightweight key-value settings stored outside SQLite.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `transcription_mode` | String | `on_device` | `on_device` or `cloud` |
| `whisper_model` | String | `base` | `tiny`, `base`, `small`, `medium` |
| `language` | String | `auto` | ISO 639-1 or `auto` |
| `groq_api_key` | String | `""` | Stored in platform secure storage |
| `summarization_style` | String | `paragraph` | `paragraph`, `bullets`, `actions_only` |
| `theme_mode` | String | `system` | `light`, `dark`, `system` |
| `font_size` | String | `medium` | `small`, `medium`, `large` |
| `reduce_motion` | bool | `false` | Disable animations |
| `cloud_fallback` | bool | `true` | Fallback to on-device if cloud fails |

**API Key Storage:** Groq API key is NOT stored in shared_preferences. It uses:
- iOS/macOS: Keychain
- Android: EncryptedSharedPreferences
- Windows: Windows Credential Manager

---

## Data Relationships Diagram

```
notes (1)
  ├──────── segments (many)
  │             └── words (many)
  ├──────── speakers (many)
  ├──────── action_items (many)
  ├──────── note_tags (many) ────── tags (many)
  ├──────── note_folders (many) ─── folders (many, hierarchical)
  └──────── custom_prompt_results (many) ── custom_prompt_templates (1)

folders (self-referential)
  └── parent_id → folders.id (max 3 levels deep)
```
