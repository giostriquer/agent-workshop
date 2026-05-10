# Doc Audit Pass

End-to-end walkthrough of running a proactive `doc-audit`, triaging findings, and routing fixes to the right agents and skills.

## When to run this

- After a major project milestone lands and the doc surface may have drifted.
- Before a scope-doc refresh, to catch gaps upstream.
- When you sense doc drift and want a sweep.

Skip for small targeted changes — that remains diff-driven `wiki-maintainer` territory.

## Step 1 — Invoke the skill

> /doc-audit

Or, if you want a narrower pass:

> /doc-audit quick   (Tier 1 only)
> /doc-audit deep    (Tiers 2–3)
> /doc-audit code-arch  (Tier 4)

The skill orchestrates `doc-indexer` for Tier 1's mechanical checks and runs Tiers 2–4 inline.

## Step 2 — Read the report

The skill produces one consolidated findings report:

```markdown
# Doc Audit Report — 2026-05-10

Mode: full
Docs scanned: 142
Total findings: 11

## Tier 1 — Mechanical findings

### Check 1: Section-README coverage
- `docs/architecture/code/_index.md` advertises a "shared scoring helper" page that does not exist on disk.

### Check 2: Orphaned pages
- `docs/architecture/old-roster.md` not linked from any routing doc; last-modified 2026-02-12.

### Check 3: Link integrity
- `docs/systems/auth.md` links to `docs/systems/old-auth.md` which has been renamed to `docs/systems/auth-history.md`.

(... continued for checks 4–14)

## Recommended next actions

- Tier 1 fixes → dispatch `wiki-maintainer` with the confirmed list
- Tier 2 terminology candidates → user picks which to define; `wiki-maintainer` applies
- Tier 2 change-log gaps → user picks which to log; invoke `change-log` skill
- Tier 3 ADR candidates → user picks which to promote; draft in main session
- Tier 4 missing notes / content drift → user picks which to patch; dispatch `wiki-maintainer`

No action is taken until the user confirms which items to pursue.
```

## Step 3 — Triage the findings

Walk the findings as a user. Each finding falls into one of three buckets:

- **Confirmed fix.** Yes, this is real drift; please fix.
- **Defer.** Not worth fixing now; revisit later.
- **Reject.** Not actually drift (e.g., the orphaned page is intentionally archived; the terminology candidate isn't load-bearing).

Mark each finding with one of these decisions before moving on.

## Step 4 — Route fixes to the right agent or skill

For Tier 1 mechanical fixes (broken links, orphaned pages, README coverage):

> Dispatch `wiki-maintainer`. Apply the confirmed Tier 1 fixes from the doc audit report:
> - Remove the orphan reference at `docs/architecture/code/_index.md`.
> - Fix the broken link at `docs/systems/auth.md` line 47 (rename target to `auth-history.md`).
> - Add the missing tag to `docs/research/2026-05-09-architecture-survey.md`.

For Tier 2 terminology candidates (after user picks which to define):

> Dispatch `wiki-maintainer`. Add the following terms to `docs/systems/terminology.md`:
> - `<Term1>` — definition
> - `<Term2>` — definition

For Tier 2 change-log gaps:

> Use the `change-log` skill to record the missed entries:
> - Commit abc123 — feat: add rate-limit configuration (2026-05-04)
> - Commit def456 — refactor: extract event scheduler into core (2026-05-06)

For Tier 3 ADR candidates (the user typically drafts these in main session):

The orchestrator drafts the ADR directly in `docs/decisions/`, not via `wiki-maintainer`. ADRs require the orchestrator's design judgment, not a doc-maintainer's copy-edit.

For Tier 4 code-architecture gaps:

> Dispatch `wiki-maintainer`. The doc audit found `docs/architecture/code/` missing notes for the following classes:
> - `<ClassName1>` at `<path>`
> - `<ClassName2>` at `<path>`
> Create per-system notes following the existing pattern.

## Step 5 — Verify

Run a follow-up audit to confirm fixes landed:

> /doc-audit quick

Tier 1 should now show fewer findings. If a previously-confirmed fix doesn't appear resolved, re-dispatch `wiki-maintainer` for that specific item.

## Cadence

Don't run `doc-audit` on a cadence. Each run gives weeks of triage material; over-running dilutes the surface and produces findings nobody acts on. Trigger:

- After major milestones land.
- Before scope-doc refreshes.
- When you sense drift.
- On user request.

Otherwise, `wiki-maintainer`'s diff-driven mode handles routine maintenance.

## What this loop demonstrates

- **Skill orchestrating agent for routing.** `doc-audit` orchestrates `doc-indexer` for Tier 1.
- **Report-only stance.** The skill never edits; the user triages.
- **Routing fixes by category.** Mechanical fixes → `wiki-maintainer`; terminology / change-log entries → respective skills; ADR drafts → main session.
- **Verification after fixes.** A follow-up quick audit confirms drift was addressed.

This pattern (skill produces report, user triages, fixes route to right agent / skill) is reusable for any audit-style workflow your project might add.
