# Change Log

## 2026-06-15

### claim-check skill — unbiased premise investigation

Added `claim-check`, a skill that runs an unbiased, evidence-grounded
investigation of a premise — a tracker ticket (the primary case), a hunch, or a
bare question — against the current repo, then stops at a verdict without
implementing. Every claim is treated as a hypothesis checked against evidence,
never assumed in either direction, so "the premise still holds" is a first-class
outcome alongside "already handled." A fuzzy input is first articulated into
atomic claims and confirmed with the operator; fan-out to subagents is the
recommended (not mandated) tool for code/doc scanning, with neutral,
evidence-returning briefs. Output is two-axis: a validity verdict (`confirmed` ·
`partially-confirmed` · `refuted/obsolete` · `mis-scoped` · `confirmed-but-blocked`)
with evidence, plus a readiness dossier or exactly what is missing. See
[`docs/decisions/claim-check.md`](decisions/claim-check.md) and the origin doc
[`docs/skills/claim-check.md`](skills/claim-check.md).

- Byte-identical mirrors in `.codex/` and `.gemini/` plus both onboarding
  reference roots; the skills roster is now eleven skills and both READMEs name
  it. Shipped as an active `reviewers` plugin skill (`0.5.0` → `0.6.0`): payload
  copy, validator pin widened to the five skills, both reviewers manifests, the
  Claude marketplace entry, plugin README, root README, and the marketplace docs
  updated. The onboarding payload's mirrored references changed too, so
  `agent-workshop` bumps `0.1.4` → `0.1.5`. `scripts/validate-native-plugin.ps1`
  passes.
- Refined the prior-work scan (step 3): git history (commits, merged PRs) is
  always searched; sibling/duplicate tickets are searched only when the tracker
  is queryable, and the skill must say the backlog was not swept when it is not
  reachable — rather than implying it was. Propagated to all six mirrors.

## 2026-06-11

### doc-to-html skill — markdown to standalone dark HTML page

Added `doc-to-html`, a scaffold skill that renders a markdown report / audit /
findings document as a single self-contained dark-themed HTML page (sticky TOC,
keyboard nav, verified-links-only, evidence appendix, print stylesheet) and
governs how the page is edited afterward. The design system ships as
battle-tested defaults (bright sans-serif on a dark blue-gray canvas, subtle
card panels, one sparing accent family); the process rules are rigid:
one-pass generation, full clean rewrite on any design-direction change,
one-knob-at-a-time feedback handling, a collision-safe renumbering procedure,
and a pre-finish checklist. Reference markup for the card and vertical-stepper
structures is embedded in the skill. See
[`docs/decisions/doc-to-html.md`](decisions/doc-to-html.md) and the origin doc
[`docs/skills/doc-to-html.md`](skills/doc-to-html.md).

- Byte-identical mirrors in `.codex/` and `.gemini/` plus both onboarding
  reference roots; the skills roster is now ten skills and the README skills
  line names it. The reference files change the onboarding plugin payload
  served by both the Claude and Codex marketplaces, so `agent-workshop` bumps
  `0.1.2` → `0.1.3` (both payload manifests, root manifest, Claude marketplace
  entry). `scripts/validate-native-plugin.ps1` passes.
- Shipped the same day as an active `reviewers` plugin skill (`0.4.0` →
  `0.5.0`) so already-installed instances update in place: payload copy,
  validator pin widened to the four skills, both reviewers manifests, the
  Claude marketplace entry, plugin README, root README, and marketplace docs
  updated (the onboarding payload's mirrored marketplace docs changed too, so
  `agent-workshop` is `0.1.4`). See the amendment in
  [`docs/decisions/doc-to-html.md`](decisions/doc-to-html.md).
- GREEN-tested per the writing-skills discipline: a fresh agent given only the
  skill applied the one-knob rule, the renumbering procedure (ids,
  cross-references, TOC, keyboard array, grep verification), the
  rewrite-on-direction-change rule, and the full pre-finish checklist.

## 2026-06-10

### handoff-goal skill — forward handoff in the reviewers plugin

Added `handoff-goal`, the third handoff skill, shipped through the `reviewers`
plugin (now `0.4.0`). Where `handoff-review` / `handoff-pr` hand a finished
branch backward, `handoff-goal` hands work *forward*: it writes a self-contained
goal document (`tmp/<YYYY-MM-DD>-<goal-slug>.md`) that a new session picks up
and pursues autonomously. The document carries the goal as an outcome with a
definition of done, current state re-derived from the repo, and operating rules
with concrete values (branch / worktree, commits, push / PR, validation,
stop-and-ask boundaries), and instructs the pursuing session to re-read the
rules after every compaction and append to a progress log — the file, not
session memory, is the durable contract. Goal resolution is three-way: inferred
from session context (then confirmed), scoped to referenced existing work, or
shaped from a brand-new description. The skill never pursues the goal itself.
See [`docs/decisions/handoff-goal.md`](decisions/handoff-goal.md).

- Validator now requires the `reviewers` payload to expose exactly
  `handoff-goal`, `handoff-pr`, and `handoff-review`, each byte-identical to
  canonical; mirrors landed in `.codex/`, `.gemini/`, the plugin payload, and
  both onboarding reference roots; origin doc added and the skills roster is
  now nine skills.
- Authored test-first per the writing-skills discipline: a baseline (no-skill)
  run produced a doc with no compaction-survival mechanics and an invented
  user-mandated rule; with the skill, producer and zero-context consumer runs
  passed both checks.

## 2026-06-08

### Codex marketplace install path

Hardened the Codex onboarding plugin metadata and documented the separate-machine
install flow. The `agent-workshop` onboarding plugin is now `0.1.2`, its Codex
manifest includes starter prompts for Codex plugin presentation, and the README,
native plugin doc, and plugin README show the Codex marketplace commands:
`codex plugin marketplace add giostriquer/agent-workshop --ref main` followed by
`codex plugin add agent-workshop@agent-workshop`.

Added `reviewers` to the Codex marketplace with a Codex manifest on the existing
Claude Code reviewers payload. It installs from the same marketplace and exposes
`handoff-review` / `handoff-pr` as Codex skills; the reviewer agent files remain
bundled for Claude Code and reference rather than active Codex plugin agents. See
[`docs/decisions/codex-reviewers-plugin.md`](decisions/codex-reviewers-plugin.md).

### Handoff skills in the reviewers plugin

Added two direct-use prompt-artifact skills and shipped them through the `reviewers`
plugin (now `0.3.0`, broadened from agents-only to agents + skills). `handoff-review`
produces a self-contained, unbiased review brief (task-vs-code, rules conformance,
information leak, correctness) for a separate agent or session to run before a PR.
`handoff-pr` produces a structured PR handoff artifact with confirmed ticket links and
review status for a separately-authorized session to open, and never runs
`gh pr create` itself. Both are tool-agnostic and stand alone — each re-derives the
task from the ticket + diff, not from the implementing session's context. See
[`docs/decisions/handoff-skills.md`](decisions/handoff-skills.md) and its
[implementation plan](decisions/handoff-skills-implementation-plan.md).

- `scripts/validate-native-plugin.ps1` now requires the `reviewers` payload to expose
  exactly `handoff-pr` and `handoff-review`, each byte-identical to canonical —
  reversing the earlier "reviewers ships no skills" assertion.
- Canonical skills live in `.claude/skills/`, mirrored byte-identical to `.codex/`,
  `.gemini/`, the `reviewers` payload, and the onboarding reference trees; origin docs
  added to `docs/skills/` and listed in the skills roster (now eight skills).

## 2026-06-05

### pattern-reviewer comment-noise check

Added a built-in comment-noise check to the canonical `pattern-reviewer`: in every
mode and regardless of domain, it flags comments that only restate the code
(line-by-line narration, name/signature headers, long blocks recoverable from the
code) and recommends deletion or replacement-by-naming, while explicitly keeping
comments that carry rationale, warnings, public-API intent, external references,
legal headers, and `TODO`/`FIXME` markers. Unlike project-specific conventions it is
reported as a finding even when undocumented; it defers to project-documented comment
conventions when they exist. Folded into the spec, origin doc, and catalog note, and
re-synced across the `reviewers` payload and the onboarding reference mirrors. See
[`docs/decisions/pattern-reviewer-comment-noise.md`](decisions/pattern-reviewer-comment-noise.md).
Bumped the `reviewers` plugin to `0.2.0` to ship the new capability.

## 2026-05-29

### Direct-use agents plugin

Added a second Claude Code marketplace plugin, `reviewers`, for
operators who want to use agents directly without onboarding the scaffold into a
project. It ships four curated standalone-capable agents (`spec-reviewer`,
`test-quality-reviewer`, `pattern-reviewer`, `vigil`) as active plugin agents and
contains no skills — the `agent-workshop-onboard` skill stays exclusive to the
bootstrapper plugin. This narrowly reverses the "no global scaffold agents"
non-goal for a bounded, curated subset; see
[`docs/decisions/agent-workshop-direct-use-agents-plugin.md`](decisions/agent-workshop-direct-use-agents-plugin.md).

- Enhanced canonical `pattern-reviewer` with a discovery/inference fallback: in a
  repo with no domain layout it discovers convention docs under `docs/` or infers
  conventions from sibling files, labelling findings lower-confidence rather than
  emitting a blanket coverage gap. Folded into the canonical spec, its origin doc,
  and the catalog note (kept byte-identical across the onboarding reference mirrors).
- The Claude marketplace now lists two plugins; `scripts/validate-native-plugin.ps1`
  validates the two-plugin marketplace and asserts the new payload has no skills and
  exactly four agents byte-identical to `.claude/agents/`.
- Generalized non-shipped sibling-agent references in `pattern-reviewer`,
  `spec-reviewer`, and `vigil` to role-based language (e.g. "a separate
  documentation-maintenance responsibility" instead of naming `wiki-maintainer`), so the
  curated plugin never points at agents absent from it and the canonical specs read
  portably in any context.
- Claude Code only this slice; Codex/Gemini/OpenCode delivery deferred.

## 2026-05-24

### Slim native plugin payload

Corrected native marketplace packaging so both Claude Code and Codex entries use
the slim `plugins/agent-workshop/` payload instead of shipping the repository
root. The payload exposes only `agent-workshop-onboard`; scaffold agents and
skills remain nested onboarding references until an approved plan copies them
into a target repo. Reference skill templates now avoid nested `SKILL.md`
filenames so plugin hosts do not discover them as active skills. Plugin metadata
is bumped to `0.1.1` so hosts can install a fresh payload instead of reusing the
old `0.1.0` cache.

## 2026-05-23

### Native onboarding plugin

Added Claude Code and Codex marketplace packaging for a single guided
`agent-workshop-onboard` skill. The plugin keeps scaffold agents as bundled
references, defaults to read-only `mode: plan`, gates writes behind approved
`mode: apply`, and includes a validator for manifest shape and reference parity.

### Manifest-backed agent marketplace

Added a marketplace layer for pack-based adoption. The new catalog defines initial agent packs (`review-core`, `docs-core`, `governance`, `specialized`), role and maturity labels, host-wrapper support, prerequisites, and project profile slots. Marketplace docs explain pack selection and keep project-specific behavior in profiles rather than canonical agent specs.

### Risk-aware test-quality reviewer

Reworked `test-quality-reviewer` from a narrow trustworthiness checklist into a lane-based scaffold for test trust, risk coverage, and test strategy. The canonical agent now supports `diff`, `audit`, and `strategy` modes; keeps `CRAP <= 6` as the default recommended ceiling when valid per-method CRAP data exists; leaves coverage targets project-defined; and treats property testing, mutation testing, and acceptance mutation testing as targeted strategy lanes rather than universal gates.

- Updated the Claude canonical spec plus Codex, Gemini, and OpenCode wrappers.
- Updated the origin doc, agent index, SDD example, and adjacent reviewer boundary language so adopters see the same ownership split.
