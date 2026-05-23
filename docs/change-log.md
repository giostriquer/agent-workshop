# Change Log

## 2026-05-23

### Risk-aware test-quality reviewer

Reworked `test-quality-reviewer` from a narrow trustworthiness checklist into a lane-based scaffold for test trust, risk coverage, and test strategy. The canonical agent now supports `diff`, `audit`, and `strategy` modes; keeps `CRAP <= 6` as the default recommended ceiling when valid per-method CRAP data exists; leaves coverage targets project-defined; and treats property testing, mutation testing, and acceptance mutation testing as targeted strategy lanes rather than universal gates.

- Updated the Claude canonical spec plus Codex, Gemini, and OpenCode wrappers.
- Updated the origin doc, agent index, SDD example, and adjacent reviewer boundary language so adopters see the same ownership split.
