# Skill Parity

## Rule

When your project supports multiple hosts (Claude Code, Codex, Gemini, OpenCode), skills mirror across host folders:

- Canonical: `.claude/skills/<name>/SKILL.md`
- Codex port: `.codex/skills/<name>/SKILL.md`
- Gemini port: `.gemini/skills/<name>/SKILL.md`

Each host loads the SKILL.md content directly, so the **file content is what travels**. The only host-specific differences should be **explainable per-host adaptations** (e.g., commit-trailer model attribution, host-specific dispatch wiring).

`.opencode/` is wrapper-only by convention — agents are wrapped, but skills are not mirrored there. Adopt or adjust based on which hosts your project actually targets.

## Why

Without explicit parity discipline, mirrors drift silently. The original is updated; the mirrors stay frozen. A Codex session loads stale guidance, does the wrong thing, and the operator finds out only after the wrong thing landed.

A parity manifest plus periodic check makes drift visible in seconds instead of weeks.

## Manifest shape

A parity manifest at `docs/agents/skill-parity.md` (or wherever your project tracks agent governance) lists each skill, which hosts mirror it, and the **expected per-host adaptation points**. Example shape:

```markdown
| Skill                | Codex | Gemini | Expected per-host adaptation                                              |
| :------------------- | :---: | :----: | :------------------------------------------------------------------------ |
| `agent-audit`        |   ✓   |   —    | Codex: dispatch flow uses host-specific spawn / send / resume calls.      |
| `change-log`         |   ✓   |   ✓    | Byte-identical to canonical.                                              |
| `doc-audit`          |   ✓   |   ✓    | Byte-identical to canonical.                                              |
| `push`               |   ✓   |   ✓    | Co-author trailer differs per host (Claude / Codex / Gemini model name).  |
| `research`           |   ✓   |   ✓    | Byte-identical to canonical.                                              |
| `visual-advisor`     |   ✓   |   ✓    | Byte-identical to canonical.                                              |
```

`✓` = port exists and is in expected sync; `✗` = port missing; `—` = intentionally not ported.

The "Expected per-host adaptation" column is **load-bearing**. Without it, future drift checks cannot tell intentional divergence from drift.

## Mechanical drift detection

A small script that diffs each canonical against its ports and reports findings (typically `scripts/skill-parity.ps1`). It computes content hashes after CRLF normalization, applies an inline allow-list for known intentional divergences, and classifies each skill as:

- `IDENTICAL` — content matches canonical
- `ALLOWED_DRIFT` — differs from canonical but matches an allow-list entry
- `UNEXPECTED_DRIFT` — differs from canonical and is not allow-listed

Cross-reference unexpected drift against the manifest's "Expected per-host adaptation" column. Stale-mirror failures are common; newly-intentional divergences should be added to the allow-list with a one-clause reason.

## When parity matters most

Three failure modes the manifest + script combination addresses:

1. **Stale mirror.** The canonical updates; the mirror doesn't. Operators on the non-canonical host load outdated guidance.
2. **Mirror divergence drift.** A host-specific adaptation lands as a one-off but isn't recorded in the manifest. Future drift checks treat it as a bug.
3. **Missing port.** A new skill lands in canonical but not in the mirrors. Hosts targeting those mirrors don't have the skill.

## In your project's docs

Adopt this convention if your project supports multiple hosts. Write a project-specific manifest at `docs/agents/skill-parity.md` listing your project's skills, ports, and adaptation points. Add a parity script under `scripts/` or equivalent.

If your project supports only one host, this convention doesn't apply — skip it.

## Anti-pattern: silent allow-list growth

Every entry in the script's allow-list should have a one-clause reason. An allow-listed divergence with no reason is a signal that no one knows whether the divergence is still intentional. Periodic Vigil audits should grep the allow-list for unjustified entries and either re-justify them or remove the divergence.
