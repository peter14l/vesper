# 01 — Vesper: Overview

## Vision

Vesper is an open-source, privacy-first voice memo and transcription app for Android, iOS, Windows, and macOS. It captures fleeting thoughts, meetings, lectures, and ideas through voice — then uses on-device AI to transcribe, summarize, and organize them into a searchable local vault.

Vesper is built for people who think faster than they type.

---

## Problem Statement

Voice memo apps today fall into two camps:

1. **Dumb recorders** — they capture audio but do nothing with it (Apple Voice Memos, Otter basic)
2. **Overpriced, cloud-dependent tools** — Whisper Memos, Otter AI, Fireflies — require subscriptions, send your data to servers, and lock you into their ecosystem

There is no fully-featured, open-source, privacy-first, AI-powered voice intelligence app. Vesper fills that gap.

---

## Goals

- **G1** — Deliver a complete, polished voice-to-intelligence experience with zero mandatory cloud dependency
- **G2** — Match or exceed Whisper Memos feature-for-feature, then go further
- **G3** — Be the reference open-source project in the voice AI app space
- **G4** — Perform exceptionally on all four target platforms with a single codebase
- **G5** — Protect user privacy by default — transcription happens on-device unless the user opts into cloud

---

## Target Users

### Primary — The Thinker
Students, researchers, writers, and professionals who have ideas constantly and need to capture them without friction. They care about privacy, hate subscriptions, and want their notes to actually be useful.

### Secondary — The Meeting Person
Knowledge workers who sit in many meetings and want automatic transcripts, summaries, and action items without sending recordings to a third-party server.

### Secondary — The Developer
Someone who discovers Vesper on GitHub, appreciates the architecture, and either contributes or forks it for their own use case.

---

## Competitive Positioning

| Feature | Vesper | Whisper Memos | Otter AI | Apple Voice Memos |
|---------|--------|---------------|----------|-------------------|
| Free | ✅ | ❌ (paid tier) | ❌ | ✅ |
| On-device transcription | ✅ | ❌ | ❌ | ❌ |
| Open source | ✅ | ❌ | ❌ | ❌ |
| Cross-platform | ✅ | ❌ (iOS only) | ✅ | ❌ (Apple only) |
| Speaker diarization | ✅ | ❌ | ✅ | ❌ |
| Searchable vault | ✅ | ❌ | ✅ | ❌ |
| Custom AI prompts | ✅ | ❌ | ❌ | ❌ |
| Synchronized playback | ✅ | ❌ | ✅ | ❌ |
| Privacy-first | ✅ | ❌ | ❌ | ✅ |

---

## Non-Goals (v1.0)

- No integrations (Notion, Zapier, email delivery) — planned for post-launch
- No watch OS / Wear OS support — desktop + mobile only
- No real-time live transcription (transcription happens after recording)
- No collaboration or shared vaults
- No web app

---

## Success Metrics (Post-Launch)

- GitHub stars as primary distribution signal
- Community contributions within 30 days of release
- Zero reported data leaks (privacy promise maintained)
- Cross-platform parity — feature identical on all 4 platforms
