# Vesper

[![GitHub License](https://img.shields.io/github/license/peter14l/vesper)](https://github.com/peter14l/vesper/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20windows%20%7C%20macos-blue)](https://github.com/peter14l/vesper)

**Vesper** is an open-source, privacy-first voice memo and transcription app. It captures your thoughts, meetings, and ideas through voice, then uses on-device AI to transcribe, summarize, and organize them into a searchable local vault.

Built with **Flutter** and a high-performance **Rust** core, Vesper runs entirely on your device, ensuring your data never leaves your control unless you explicitly opt-in to cloud features.

---

## 🌟 Vision

Vesper is built for people who think faster than they type. It bridges the gap between simple voice recorders and overpriced, cloud-dependent transcription tools.

- **Privacy-First:** Transcription happens on-device by default.
- **Cross-Platform:** One seamless experience across Android, iOS, Windows, and macOS.
- **AI-Powered Intelligence:** Beyond just text — get summaries, action items, and auto-tags.
- **Open Source:** Transparent, extensible, and community-driven.

---

## ✨ Features

### 🎙️ Recording Engine
- **One-Tap Recording:** Quick-start from any screen.
- **Alive UI:** Interactive "Recording Orb" that reacts to your voice.
- **Background Recording:** Keep capturing even when the app is minimized.
- **High-Quality Audio:** Configurable formats (M4A, WAV) and quality settings.

### ✍️ Transcription & AI
- **On-Device Whisper:** Powered by `whisper.cpp` via Rust bindings for 100% offline transcription.
- **Cloud Fallback:** Optional high-speed transcription via Groq (Whisper Large V3).
- **Smart Summaries:** Automated paragraph summaries and action item extraction using Llama 3 (via Groq).
- **Speaker Diarization:** Identify different speakers in your recordings.
- **Multi-Language:** Support for over 99 languages.

### 🗄️ Searchable Vault
- **Full-Text Search:** Search through transcripts, summaries, and tags instantly.
- **Organization:** Use folders, nested structures, and auto-generated tags.
- **Mood Detection:** Automatically detect the tone of your memos.
- **Synced Playback:** Interactive transcripts that follow the audio as it plays.

### 📤 Export & Integration
- **Formats:** Export to Markdown, Plain Text, or PDF.
- **Native Sharing:** Send your notes to any app on your device.

---

## 🛠️ Tech Stack

- **Frontend:** [Flutter](https://flutter.dev) (Multi-platform UI)
- **Core Logic:** [Rust](https://www.rust-lang.org) (High-performance audio & AI bindings)
- **FFI:** [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- **Transcription:** [whisper.cpp](https://github.com/ggerganov/whisper.cpp) via `whisper-rs`
- **Database:** [Drift](https://drift.simonbinder.eu) (SQLite)
- **State Management:** [Riverpod](https://riverpod.dev)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Rust Toolchain
- LLVM / Clang (for FFI generation)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/peter14l/vesper.git
   cd vesper
   ```

2. Install Flutter dependencies:
   ```bash
   cd vesper_flutter
   flutter pub get
   ```

3. Build the Rust core:
   ```bash
   cd ../vesper_core
   cargo build
   ```

4. Run the app:
   ```bash
   cd ../vesper_flutter
   flutter run
   ```

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🙌 Acknowledgements

- [whisper.cpp](https://github.com/ggerganov/whisper.cpp)
- [Groq](https://groq.com)
- [Flutter Rust Bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- [Phosphor Icons](https://phosphoricons.com)
