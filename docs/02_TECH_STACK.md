# 02 — Vesper: Tech Stack

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  Flutter UI Layer                    │
│         (Android, iOS, Windows, macOS)               │
└───────────────────────┬─────────────────────────────┘
                        │ FFI (flutter_rust_bridge)
┌───────────────────────▼─────────────────────────────┐
│                  Rust Core Layer                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ Audio Engine│  │  Transcription│  │ AI Pipeline│  │
│  │   (cpal)    │  │  (whisper-rs) │  │  (reqwest) │  │
│  └─────────────┘  └──────────────┘  └────────────┘  │
│  ┌─────────────────────────────────────────────────┐ │
│  │          Storage Layer (SQLite via rusqlite)    │ │
│  └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
                        │
        ┌───────────────┴───────────────┐
        │                               │
┌───────▼──────┐               ┌────────▼───────┐
│  On-Device   │               │  Groq Cloud API │
│ whisper.cpp  │               │ (opt-in only)   │
│ (default)    │               │                 │
└──────────────┘               └────────────────┘
```

---

## Frontend — Flutter

**Why Flutter:**
- Single codebase for Android, iOS, Windows, macOS
- Pixel-perfect custom UI (no native widget constraints)
- Excellent FFI support for Rust integration via `flutter_rust_bridge`
- Strong performance on all target platforms

**Flutter Version:** Latest stable (3.x)  
**Dart Version:** Latest stable

### Key Flutter Packages

| Package | Purpose |
|---------|---------|
| `flutter_rust_bridge` | FFI bridge between Flutter and Rust core |
| `drift` | Type-safe SQLite ORM for Flutter |
| `riverpod` | State management |
| `go_router` | Navigation and routing |
| `just_audio` | Audio playback |
| `record` | Audio recording (fallback for platforms where Rust audio isn't available) |
| `phosphor_flutter` | Duotone icon set |
| `google_fonts` | Plus Jakarta Sans + Lora |
| `flutter_animate` | Expressive animations |
| `shared_preferences` | Lightweight settings persistence |
| `path_provider` | Platform-safe file paths |
| `file_picker` | Import audio files |
| `share_plus` | Export/share sheet |
| `flex_color_scheme` | Theming system |

---

## Backend — Rust Core

**Why Rust:**
- Performance-critical audio processing and transcription
- Memory safety without garbage collector pauses
- whisper.cpp has first-class Rust bindings (`whisper-rs`)
- Cross-compilation to all target platforms via `cargo`

### Rust Crates

| Crate | Purpose |
|-------|---------|
| `whisper-rs` | Rust bindings for whisper.cpp — on-device transcription |
| `cpal` | Cross-platform audio I/O |
| `hound` | WAV file reading/writing |
| `rusqlite` | SQLite bindings |
| `reqwest` | HTTP client for Groq API calls |
| `serde` / `serde_json` | Serialization |
| `tokio` | Async runtime |
| `anyhow` | Error handling |
| `log` / `env_logger` | Logging |

---

## AI Services

### Transcription

| Mode | Provider | Model | Default |
|------|----------|-------|---------|
| On-device | whisper.cpp via `whisper-rs` | whisper-base or whisper-small | ✅ Yes |
| Cloud | Groq API | whisper-large-v3-turbo | Optional |

**Model selection strategy:**
- Default: `whisper-base` — fast, low memory, good accuracy for clear speech
- User can upgrade to `whisper-small` or `whisper-medium` in settings (tradeoff: speed vs accuracy)
- Cloud mode uses `whisper-large-v3-turbo` via Groq — highest accuracy, requires internet + API key

### Summarization

| Provider | Model | Notes |
|----------|-------|-------|
| Groq API | `llama-3.3-70b-versatile` | Primary summarization model |
| Groq API | `llama-3.1-8b-instant` | Fallback / faster option |

**User provides their own Groq API key** — Groq's free tier is generous (14,400 requests/day). Vesper never proxies keys through any server.

---

## Storage — Local First

**Primary database:** SQLite via `drift` (Flutter) / `rusqlite` (Rust)  
**Audio files:** Stored in app documents directory, referenced by path in DB  
**No cloud sync in v1** — everything lives on device

### Storage locations by platform

| Platform | Data Directory |
|----------|---------------|
| Android | `/data/data/com.vesper.app/files/` |
| iOS | `~/Documents/Vesper/` |
| Windows | `%APPDATA%\Vesper\` |
| macOS | `~/Library/Application Support/Vesper/` |

---

## Project Structure

```
vesper/
├── vesper_flutter/          # Flutter app
│   ├── lib/
│   │   ├── core/            # App-wide utilities, constants, theme
│   │   ├── features/
│   │   │   ├── recording/   # Recording UI + state
│   │   │   ├── vault/       # Note list, search, folders
│   │   │   ├── player/      # Synchronized playback
│   │   │   ├── ai/          # AI result display
│   │   │   └── settings/    # Settings screens
│   │   ├── shared/          # Shared widgets, design system components
│   │   └── main.dart
│   └── pubspec.yaml
│
├── vesper_core/             # Rust core library
│   ├── src/
│   │   ├── audio/           # Recording, encoding, decoding
│   │   ├── transcription/   # whisper.cpp integration
│   │   ├── ai/              # Groq API client
│   │   ├── storage/         # SQLite layer
│   │   └── lib.rs           # FFI exports
│   └── Cargo.toml
│
├── docs/                    # PRD and documentation
└── README.md
```

---

## Platform-Specific Notes

### Android
- Minimum SDK: 26 (Android 8.0)
- Permissions: `RECORD_AUDIO`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`
- whisper.cpp compiled as `.so` via Android NDK

### iOS
- Minimum: iOS 15
- Permissions: `NSMicrophoneUsageDescription`
- whisper.cpp compiled as static framework via `cargo-lipo`

### Windows
- Minimum: Windows 10
- whisper.cpp compiled as `.dll`
- MSVC toolchain required

### macOS
- Minimum: macOS 12 (Monterey)
- Entitlements: `com.apple.security.device.microphone`
- whisper.cpp compiled as `.dylib`
