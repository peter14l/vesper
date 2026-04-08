# Vesper — Product Requirements Document
> *Speak. Remember.*

**Version:** 1.0.0  
**Status:** Pre-development  
**License:** Open Source (MIT)  
**Target Release:** After Phase 6 completion

---

## Document Structure

This PRD is split into focused documents, each readable by AI coding tools independently.

| File | Contents |
|------|----------|
| `01_OVERVIEW.md` | Vision, goals, target users, competitive positioning |
| `02_TECH_STACK.md` | Full stack decisions, architecture, dependencies |
| `03_FEATURES.md` | Complete feature specification |
| `04_DESIGN_SYSTEM.md` | UI/UX guidelines, design tokens, component patterns |
| `05_PHASES.md` | Phased build plan with workflow diagrams |
| `06_DATA_MODELS.md` | Local data schema, storage architecture |
| `07_AI_PIPELINE.md` | Transcription + summarization pipeline spec |

---

## Quick Reference

**Platform:** Android, iOS, Windows, macOS  
**Framework:** Flutter  
**Backend:** Rust  
**Transcription:** whisper.cpp (on-device) + Groq Whisper API (cloud fallback)  
**Summarization:** Groq — Llama 3  
**Storage:** Local-first (SQLite via Drift + file system)  
**Open Source:** Yes — full release after Phase 6  
