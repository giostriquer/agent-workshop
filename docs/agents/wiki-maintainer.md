# wiki-maintainer

## Origin

Documentation drift was the first agent-justifying pressure to appear in the originating project. Earlier in the project's life, when it was mostly concept framing and prototype planning, a local documentation agent would have been premature. The repo first needed enough moving pieces to justify it: active client code, scene/prefab work, edit-mode tests, architecture and decision docs, and emerging implementation-adjacent planning notes.

That combination created real documentation drift risk. After the first few weeks of "the docs say X but the code does Y" moments, `wiki-maintainer` was introduced as the local documentation owner. It is the oldest agent in the set.

## Problem

Three drift modes appear in any project that survives past the toy stage:

1. **Diff-driven drift.** Code changes lands, the docs that describe it don't get updated, and the docs gradually become misleading.
2. **Cross-task coherence drift.** Two tasks each touch related docs, neither is wrong on its own, but together the wording / routing / terminology has fragmented.
3. **Documentation-impact bypass.** Implementation work treats documentation as optional cleanup, so meaningful features ship without leaving a re-grounding-readable trace.

A repo-local maintainer addresses all three: diff-driven by default for (1), end-of-flow consolidated pass for (2), the documentation-trace rule for (3).

## Solution shape

`wiki-maintainer` is **the documentation authority** for the repo. It patches docs directly (it is not a review gate), and it has its own change-log skill loaded so the change-log entry rule is enforced consistently.

Two workflows: **diff-driven** (the default — review the current diff, decide whether docs need to change, update only the relevant docs, then run the change-log skill) and **audit** (rare — explicit request to audit the whole doc surface, propose-before-apply).

A specialization of the diff-driven workflow runs at branch closure: the **end-of-flow consolidated pass** that operates on the full branch diff to catch cross-task coherence drift that per-task passes can't see by construction.

Source priority — code first, then existing docs, then routing surfaces. If docs and code disagree, prefer code unless the task is explicitly about planned design changes.

## Real workflow snippet

Example `AGENTS.md` lines that wire the agent into a project's standard development workflow:

```markdown
## Standard development workflow

Meaningful implementation tasks follow: **Spec → Plan → Execute → Review → Critique → Final-Docs**.

- During Review, dispatch `wiki-maintainer` opportunistically when broader doc impact is visible during a task.
- The `change-log` skill runs unconditionally after meaningful changes.
- During Final-Docs (immediately before merge / PR), dispatch `wiki-maintainer` once against the full branch diff for a consolidated end-of-flow pass — fresh dispatch, not a SendMessage-resume of any per-task session.
```

Example dispatch shape from a Claude session, mid-feature:

> Dispatch `wiki-maintainer` to review documentation impact for the current diff and update relevant docs. The diff touches the reward-progression scoring rules, the player-facing UI for unlock cards, and the math doc for hero progression.

## Pitfalls observed

- **Dispatching `wiki-maintainer` for retrieval questions.** Use `doc-indexer` for "where does the source of truth for X live?" — `wiki-maintainer` does not need to load to answer routing questions.
- **Skipping the consolidated end-of-flow pass.** Per-task `wiki-maintainer` invocations don't catch cross-task coherence drift. The branch-closure dispatch is mandatory by default.
- **Audit mode for narrow changes.** Audit mode is propose-before-apply and slow. Use diff-driven mode for normal work; reserve audit mode for explicit "audit the whole doc surface" requests.
- **Cross-task SendMessage-resume.** Each branch's end-of-flow pass is a fresh dispatch, not a continuation of any per-task session. Cross-artifact context inheritance is the cross-task mistake.
- **Treating docs as optional cleanup.** Making documentation-impact part of completion (the trace rule) rather than a follow-up step.

## Adaptation notes

- The synchronization checklist in the spec is a starting point. Trim items that don't apply to your project (UI mockup routing, host-specific debug surfaces, etc.) and add ones that do.
- The "Host-file workflow-rule parity" rule (CLAUDE.md / AGENTS.md / GEMINI.md keep workflow rules inline, do not pointer-only) is **load-bearing**. Don't trim it. Originating-project history: a Claude session skipped the spec-reviewer pre-implementation gate when its rules were trimmed from CLAUDE.md and only forward-pointed to AGENTS.md.
- The end-of-flow consolidated pass requires a clear "branch closure" boundary. If your project doesn't have that (no PR / merge / branch-feature workflow), the diff-driven workflow alone is enough.
- `obsidian-only: true` frontmatter and the `_index.md` vs `README.md` split are project-specific patterns from the originating project's Obsidian-vault dual-purpose. Drop these if you don't use Obsidian.
