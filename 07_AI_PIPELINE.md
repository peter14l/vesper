# 07 — Vesper: AI Pipeline

## Overview

Vesper uses two AI systems:

1. **Transcription** — OpenAI Whisper (via whisper.cpp, on-device) or Groq Whisper API (cloud)
2. **Analysis** — Groq Llama 3 (cloud, requires user API key)

All AI runs in the Rust core layer and results are passed to Flutter via FFI.

---

## Pipeline Flow

```
Audio File
    │
    ▼
┌───────────────────────────────────────────────────┐
│              STEP 1: TRANSCRIPTION                 │
│                                                   │
│  ┌─────────────────┐    ┌──────────────────────┐  │
│  │  ON-DEVICE       │    │  CLOUD (opt-in)       │  │
│  │  whisper.cpp     │ OR │  Groq Whisper API     │  │
│  │  via whisper-rs  │    │  whisper-large-v3     │  │
│  └────────┬────────┘    └──────────┬───────────┘  │
│           └──────────────────────┘               │
│                        │                          │
│              Vec<TranscriptionSegment>            │
└────────────────────────┬──────────────────────────┘
                         │
                         ▼
┌───────────────────────────────────────────────────┐
│              STEP 2: DIARIZATION                  │
│                                                   │
│  Assign speaker_id to each segment                │
│  Output: segments with speaker labels             │
└────────────────────────┬──────────────────────────┘
                         │
                         ▼
┌───────────────────────────────────────────────────┐
│              STEP 3: AI ANALYSIS                  │
│                                                   │
│  Groq API — llama-3.3-70b-versatile               │
│  Single API call, structured JSON output          │
│                                                   │
│  Input: full transcript text                      │
│  Output: title, summary, action_items,            │
│          tags, mood                               │
└────────────────────────┬──────────────────────────┘
                         │
                         ▼
┌───────────────────────────────────────────────────┐
│           STEP 4: CUSTOM PROMPTS                  │
│                                                   │
│  For each saved template:                         │
│  Replace {{transcript}} → run Groq API call       │
│  Store result in custom_prompt_results table      │
└────────────────────────┬──────────────────────────┘
                         │
                         ▼
                   Save to SQLite
                         │
                         ▼
                   Update Flutter UI
```

---

## Transcription — whisper.cpp (On-Device)

### Model Selection

| Model | Size | Speed | Accuracy | Use Case |
|-------|------|-------|----------|---------|
| `tiny` | 75MB | ~10x realtime | Basic | Quick notes, fast devices |
| `base` | 142MB | ~7x realtime | Good | **Default** |
| `small` | 466MB | ~4x realtime | Better | Longer recordings |
| `medium` | 1.5GB | ~2x realtime | High | High accuracy needs |

Speeds measured on a mid-range Android device (Snapdragon 778G).

### Model Download Strategy

```
First launch of transcription feature:
    │
    ▼
Check if whisper-base.bin exists in cache dir
    │
    ├── YES → Use cached model
    │
    └── NO → Show download prompt
              "Download AI model (142MB) to enable
               transcription. This is a one-time download."
                    │
                    ▼
               Download from HuggingFace CDN
               Show progress bar
                    │
                    ▼
               Verify SHA256 checksum
                    │
                    ▼
               Cache to: {app_support}/models/whisper-base.bin
```

### Rust Implementation Sketch

```rust
use whisper_rs::{WhisperContext, WhisperContextParameters, FullParams, SamplingStrategy};

pub fn transcribe_audio(
    audio_path: &str,
    model_path: &str,
    language: Option<&str>,
) -> Result<TranscriptionResult> {
    // Load model
    let ctx = WhisperContext::new_with_params(
        model_path,
        WhisperContextParameters::default()
    )?;

    // Load and resample audio to 16kHz mono f32
    let audio_data = load_audio_as_f32(audio_path)?;

    // Configure transcription
    let mut params = FullParams::new(SamplingStrategy::Greedy { best_of: 1 });
    params.set_language(language);
    params.set_print_progress(false);
    params.set_token_timestamps(true); // word-level timestamps

    // Run transcription
    let mut state = ctx.create_state()?;
    state.full(params, &audio_data)?;

    // Extract segments
    let num_segments = state.full_n_segments()?;
    let mut segments = Vec::new();

    for i in 0..num_segments {
        let text = state.full_get_segment_text(i)?;
        let start_ms = (state.full_get_segment_t0(i)? * 10) as u64;
        let end_ms = (state.full_get_segment_t1(i)? * 10) as u64;

        segments.push(TranscriptionSegment {
            start_ms,
            end_ms,
            text,
            speaker_id: None, // filled by diarization pass
            confidence: 1.0,
            words: extract_words(&state, i)?,
        });
    }

    Ok(TranscriptionResult {
        segments,
        language_detected: state.full_lang_id()?.to_string(),
        duration_ms: audio_data.len() as u64 / 16, // 16kHz
    })
}
```

---

## Transcription — Groq Cloud API

### Endpoint
`POST https://api.groq.com/openai/v1/audio/transcriptions`

### Request

```rust
// Multipart form upload
// Model: whisper-large-v3-turbo
// response_format: verbose_json (includes timestamps)
// timestamp_granularities: ["word", "segment"]

let form = reqwest::multipart::Form::new()
    .text("model", "whisper-large-v3-turbo")
    .text("response_format", "verbose_json")
    .text("timestamp_granularities[]", "segment")
    .text("timestamp_granularities[]", "word")
    .file("file", audio_path)?;
```

### Response Parsing

```rust
// Parse verbose_json response into Vec<TranscriptionSegment>
// Map Groq segment format → internal TranscriptionSegment type
// Same output format as on-device — Flutter sees no difference
```

---

## Speaker Diarization

Diarization runs as a post-processing step on the transcription segments.

### Approach

Use a lightweight speaker embedding model to:
1. Extract audio for each segment
2. Compute speaker embedding vector
3. Cluster embeddings (k-means or agglomerative)
4. Assign speaker labels based on clusters

**Library:** `pyannote-audio` equivalent in Rust, or integrate via a lightweight ONNX model.

**Fallback:** If diarization model is unavailable or disabled, all segments assigned `speaker_1`.

### Output

Each `TranscriptionSegment.speaker_id` is set to `"speaker_1"`, `"speaker_2"`, etc.
User can rename speakers in the Note Detail screen.

---

## AI Analysis — Groq Llama 3

### Endpoint
`POST https://api.groq.com/openai/v1/chat/completions`

### System Prompt

```
You are an AI assistant that analyses voice memo transcripts.
Given a transcript, you extract structured information.

You MUST respond with ONLY valid JSON. No preamble, no explanation,
no markdown code fences. Only the JSON object.

The JSON must follow this exact schema:
{
  "title": "string — short descriptive title, max 8 words",
  "summary": "string — concise summary of main points",
  "action_items": ["string", "string"],
  "tags": ["string", "string", "string"],
  "mood": "one of: neutral | reflective | energetic | stressed | focused | creative"
}

Rules:
- title: max 8 words, sentence case, no punctuation at end
- summary: 1-3 sentences for short memos, up to 5 for long ones
- action_items: only include if clearly stated in transcript, empty array if none
- tags: 3-6 tags, lowercase, single words or short phrases
- mood: choose the single best fit
```

### User Message

```
Transcript:
{full_transcript_text}
```

### Response Parsing

```rust
// Parse JSON response
// Validate all required fields present
// Strip any accidental markdown fences before parsing
// On parse failure: retry once, then return partial result

let response_text = extract_text_from_groq_response(&data)?;
let clean = response_text
    .trim()
    .trim_start_matches("```json")
    .trim_start_matches("```")
    .trim_end_matches("```")
    .trim();

let result: AiAnalysisResult = serde_json::from_str(clean)?;
```

### Model Selection Logic

```
Primary:  llama-3.3-70b-versatile
    │
    ├── On rate limit / error → retry after 1s
    │
    └── On second failure → fallback to llama-3.1-8b-instant
```

---

## Custom Prompt Execution

```rust
pub fn run_custom_prompt(
    template: &CustomPromptTemplate,
    transcript: &str,
    api_key: &str,
) -> Result<String> {
    // Replace {{transcript}} placeholder
    let prompt = template.prompt.replace("{{transcript}}", transcript);

    // Call Groq API with freeform prompt
    // No JSON constraint — return raw text response
    let result = groq_chat_completion(
        api_key,
        "llama-3.3-70b-versatile",
        &prompt,
        false // not structured JSON
    )?;

    Ok(result)
}
```

---

## Error Handling

| Error | Handling |
|-------|---------|
| No API key | AI features disabled, prompt to add key in Settings |
| Invalid API key | Clear error message, link to Settings |
| Rate limit (429) | Retry after delay shown to user |
| Network error | Retry option, or skip AI and save transcript only |
| JSON parse error | Retry once, then save transcript without AI fields |
| Model unavailable | Fallback to smaller model |
| On-device model missing | Prompt to download model |
| Audio too short (<1s) | Skip transcription, save as empty note |
| Audio too long (>2hr) | Split into chunks, transcribe sequentially |

---

## Privacy Guarantees

| Data | On-Device Mode | Cloud Mode |
|------|---------------|------------|
| Audio file | Never leaves device | Sent to Groq for transcription only |
| Transcript | Never leaves device | Sent to Groq for AI analysis |
| API key | Stored in platform secure enclave | Never sent to any Vesper server |
| Note metadata | Never leaves device | Never leaves device |

**Vesper operates no servers.** All cloud requests go directly from the user's device to Groq's API using the user's own API key. Vesper cannot see any user data.
