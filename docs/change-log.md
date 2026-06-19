# Change Log

## 2026-06-19

### handoff-goal — make the document defend the goal, not just preserve context

Reworked `handoff-goal` from a strong context-preserver into a goal *defender*.
The skill's founding rule (the document is the only context that survives) gains a
second: the document is the goal's defense against its own pursuing loop, which
under speed pressure Goodharts whatever *looks* done. The emitted document now
injects that discipline itself rather than assuming the target repo supplies it:
**verifiable acceptance checks** (verify command + evidence, plus a refutation/
mutation form for behavior changes) replace prose "definition of done"; an
**integrity rules** block forbids weakening/skipping/renaming-away tests and gates
and narrowing/reinterpreting scope (escalate instead); an operator-set **quality
posture** (default reliability-over-speed); **independent verification** baked into
the loop shape (act → verify with an independent pass → record → repeat);
stakes-scaled **invariants / non-goals**; a **progress ledger** authoritative over
post-compaction recollection; explicit **when-to-stop** conditions including the
"tempted to redefine the goal/checks/scope" tripwire; and a compaction *drift
check*. A calibration section keeps it from becoming a fortress: four parts are
always-on (verifiable checks, integrity rules, independent verification, the
tripwire), the rest scale with stakes. The `description` (triggering conditions) is
unchanged. See [`docs/decisions/handoff-goal-goal-defense.md`](decisions/handoff-goal-goal-defense.md).

- Validation note: across **three** methodologies — two reflective scenarios and a
  faithful behavioral test (a real runnable scratch repo, real tool-execution, a
  weaker pursuer model, and a subtle special-case-the-input hack caught by a hidden
  test the pursuers never saw) — the RED could not be established: pursuers did not
  reward-hack in either arm. When the honest fix is cheap they make it; when it is
  blocked they escalate. The change is **design-validated, not behavior-proven**;
  the intended mechanism (the tripwire was invoked by name) and a scope/autonomy
  delta were the observable wins. Full account in the decision note, including a
  wording refinement applied off the test (the integrity rule's "rename-away" now
  names the actual dodge and allows a legitimate repoint-to-a-seam fix).
- Canonical `.claude/skills/handoff-goal/SKILL.md` propagated byte-identical to all
  five mirrors (`.codex`, `.gemini`, `toolkit`, both onboarding reference roots);
  origin doc `docs/skills/handoff-goal.md` updated and mirrored to both reference
  roots. `toolkit` `0.8.1` → `0.8.2` (rework of an existing skill = patch),
  `agent-workshop` `0.1.12` → `0.1.13` (onboarding payload mirrors changed). No
  skill added or removed; `scripts/validate-native-plugin.ps1` passes.

### claim-check — STOP when the premise's source can't be reached

Closed a hole in `claim-check` surfaced in lived use: a session handed a ticket it
could not access (no integration, URL unreachable, no paste) ran the investigation
anyway, reconstructing the premise from the link and its own memory and emitting a
verdict on a resource it never saw. A new **access precondition** now fires before
the investigation — if the premise's source, or the artifact it concerns (ticket,
PR, repo, file, reference), can't be reached and the operator can't supply it, the
skill STOPs and reports the access gap (what couldn't be opened, what was tried,
what would unblock it) rather than substituting the link slug, memory, or inference
for the resource. Explicitly distinguished from `inconclusive` (which is earned
only *after* a real investigation hits a wall): the access STOP is a can't-start
precondition failure, not a verdict bucket. The premise-resolution fallback and the
Rules now cross-reference it. The `description` is unchanged. See
[`docs/decisions/claim-check-access-precondition.md`](decisions/claim-check-access-precondition.md).

- Canonical `.claude/skills/claim-check/SKILL.md` propagated byte-identical to all
  five mirrors; origin doc `docs/skills/claim-check.md` updated and mirrored to both
  reference roots. Rides the same `toolkit` `0.8.2` / `agent-workshop` `0.1.13`
  bump as the handoff-goal rework above — no additional bump, both reworks ship in
  one batch. `scripts/validate-native-plugin.ps1` passes.

### handoff-pr — discover and run the repo's pre-push static gates

Closed a hole behind a real CI failure: a branch was handed off and pushed without
the repo's *required* formatter gate ever running locally — `--no-verify` commits
had bypassed the pre-commit hook, the handoff carried no pre-push gate, and CI's
fail-fast formatter check blocked the whole PR while "tests pass" hid it. The
validation step is now a **discover-then-run gate**: the producing session
discovers what the repo actually gates a PR on (reading its CI workflows, hook
config, build/package scripts, and contributor docs — no hardcoded toolchain),
identifies the fast static checks (format / lint / type-check) **separately** from
the test suites, runs them against an up-to-date base, and records the exact
commands and results by kind. It calls out the `--no-verify` hazard explicitly
(hook-bypassing commits skip the formatter — run it by hand before push) and keeps
formatting/typecheck/stale-base failures separated in any "known issues" note so
the opener fixes the gate that's actually red. The validation-provenance field and
Rules carry it; the body stays tool-agnostic by discovery. See
[`docs/decisions/handoff-pr-prepush-validation-gate.md`](decisions/handoff-pr-prepush-validation-gate.md).

- Canonical `.claude/skills/handoff-pr/SKILL.md` propagated byte-identical to all
  five mirrors; origin doc `docs/skills/handoff-pr.md` updated and mirrored to both
  reference roots. Rides the same `toolkit` `0.8.2` / `agent-workshop` `0.1.13`
  batch bump — no additional bump. `scripts/validate-native-plugin.ps1` passes.

## 2026-06-18

### handoff-pr — derive the PR body from the repo's own PR template

Reworked `handoff-pr` so the PR body is no longer skill-invented. A new step before
assembly searches for a PR template GitHub would honor (case-insensitive):
`.github/pull_request_template.md` / `PULL_REQUEST_TEMPLATE.md`, any file under
`.github/PULL_REQUEST_TEMPLATE/`, and the same names (plus the directory form) in the
repo root and under `docs/`. When a template exists, the body *is* that template filled
in verbatim — headings, order, checkbox items, and `<!-- markers -->` preserved, our
content mapped into its existing fields, checklist boxes ticked `[x]` only when actually
verified; multiple templates are chosen by branch/intent and the choice is recorded.
With no template it falls back to a trimmed built-in Summary / Ticket / Caveats body.
The artifact is now two visibly separate blocks: the paste-ready **PR body** and an
opener-only **handoff notes** block carrying which template was used, validation
provenance, review status, and the `gh pr create` command — so process fields never leak
into the public PR description. A rule keeps the body tooling-agnostic (no named editors,
bots, or AI assistants; no "generated by" footers). See
[`docs/decisions/handoff-pr-template-derived-body.md`](decisions/handoff-pr-template-derived-body.md).

- Canonical `.claude/skills/handoff-pr/SKILL.md` propagated byte-identical to all five
  mirrors (`.codex`, `.gemini`, `toolkit`, both onboarding reference roots); origin doc
  `docs/skills/handoff-pr.md` and the `docs/skills/README.md` one-liner updated and
  mirrored. `toolkit` `0.8.0` → `0.8.1` (rework of an existing skill = patch),
  `agent-workshop` `0.1.11` → `0.1.12` (onboarding payload mirrors changed). No skill
  added or removed; `scripts/validate-native-plugin.ps1` passes.

## 2026-06-17

### qa-sweep — new team-scale, corroborated QA skill

Added `qa-sweep`, a direct-use skill that runs a broad QA / verification pass over
a decomposable surface (release, branch, feature, app) by fanning a QA team over
independent slices, then **reproducing every verdict-moving finding firsthand at
the running surface before it counts** — dropping what won't reproduce, separating
regressions from pre-existing bugs against a baseline, and synthesizing a
verdict-first, confidence-tagged report. Extracted from a lived-in QA session: the
durable lesson was the corroboration loop, not the fan-out, so the skill is rigid
about Phase 0 (decomposition gate) and Phase 3 (firsthand corroboration) and
flexible about slicing / harness / team size. It deliberately composes rather than
duplicates the scaffold's other tools — the team-scale, runtime sibling of
single-change verification and of `claim-check`'s single-premise investigation —
and ships with an optional deterministic-workflow appendix (fan-out → independent
per-finding corroboration → synthesize, with inline `SLICE_SCHEMA` /
`VERDICT_SCHEMA`). System-agnostic: no product, ticket, path, or harness names in
the skill body. See [`docs/decisions/qa-sweep.md`](decisions/qa-sweep.md).

- Canonical `.claude/skills/qa-sweep/SKILL.md` propagated byte-identical to all
  five mirrors (`.codex`, `.gemini`, `toolkit`, both onboarding reference roots);
  origin doc `docs/skills/qa-sweep.md` written and mirrored; roster, root README,
  toolkit README, and the marketplace-doc Codex skill enumerations updated.
  `toolkit` `0.7.1` → `0.8.0` (new skill = minor), `agent-workshop` `0.1.10` →
  `0.1.11` (onboarding payload mirrors grew). Both `$expectedSkills` arrays in
  `scripts/validate-native-plugin.ps1` widened; the validator passes.

### doc-to-html — house-style-first, deeper findings cards, render-bug fixes

Reworked `doc-to-html` from a second round of lived-in feedback (`toolkit` `0.7.0`
→ `0.7.1`, `agent-workshop` `0.1.9` → `0.1.10`). The biggest change is a new
**Step 0 — match the repo's house style first**: glob `tmp/`/`docs/` for an
existing standalone `.html` report and match its `<style>` and component
vocabulary; the skill's own design system is relabelled **fallback-only** and its
default vocabulary upgraded from the calm-flat look to the richer card-and-chip
one adopters expect. A new *Findings & audit reports* section makes each card
carry, by structure, a concrete **Evidence** line and a **Fix** line with a cost
pill (never a claim without evidence), orders findings **by severity descending**,
and adds prefixed-id grouping plus an optional Method section. Concrete render
bugs are pinned in the reference markup and checklist: styled scrollbars on every
scroll container, section-number badges aligned to their heading
(`align-items:center`), and one consistent cost-pill placement. The
verified-links rule is clarified (enrichment links optional; some doc URLs 404 to
a server-side fetch). The skill stays system-agnostic — all examples use generic
placeholders, no real product/ticket/path names. See the amendment in
[`docs/decisions/doc-to-html.md`](decisions/doc-to-html.md).

- Skill body propagated byte-identical to all five mirrors
  (`.codex`, `.gemini`, `toolkit`, both onboarding reference roots); origin doc
  `docs/skills/doc-to-html.md` updated and re-mirrored.
  `scripts/validate-native-plugin.ps1` passes.

## 2026-06-16

### Renamed the `reviewers` plugin to `toolkit`

The direct-use plugin began as four review/governance agents but has since
accumulated five direct-use skills (only `handoff-review` is review-adjacent), so
the name had outgrown its contents. Renamed `reviewers` → `toolkit` to match its
real identity — direct-use, no-setup, runs in any repo — the contrast to the
`agent-workshop` onboarding plugin that adopts the whole scaffold. Scope is
unchanged: same four agents, same five skills. Agents now resolve as
`toolkit:<agent>`; install via `toolkit@agent-workshop`. Version `0.6.3` →
`0.7.0`; `agent-workshop` `0.1.8` → `0.1.9` (its onboarding payload mirrors the
updated marketplace docs). The switching cost was ~zero (operator's own machines
only). See [`docs/decisions/rename-reviewers-to-toolkit.md`](decisions/rename-reviewers-to-toolkit.md).

- `git mv plugins/reviewers plugins/toolkit` (history preserved); both manifests,
  both marketplaces, the validator, the root and plugin READMEs, and the
  marketplace docs (+ reference mirrors) updated. The validator's `*-reviewer.md`
  agent assertions are untouched — singular `-reviewer` is the agent, plural
  `reviewers` was the plugin. `scripts/validate-native-plugin.ps1` passes.

## 2026-06-16

### claim-check — output trimmed to three parts

Restructured the report after a real run was hard to read (`reviewers` `0.6.2` →
`0.6.3`, `agent-workshop` `0.1.7` → `0.1.8`). The cause was template slots the
model dutifully filled, so the fix deletes them: the report is now **three parts
and nothing else** — Verdict (+ how-verified), Prior/parallel work, Readiness —
written as **plain text, not a blockquote**. The per-claim verdict table is gone
(claims are still investigated atomically; only the conclusion is reported, since
the verdict synthesis and readiness already carry which parts are real or stale);
the echoed `Source` line is gone; and prior/parallel work stays its own section
but is trimmed to what bears on the verdict and lifted back above readiness. An
explicit "Do not" list in the skill pins the four cuts. See the amendment in
[`docs/decisions/claim-check.md`](decisions/claim-check.md).

### claim-check — depth gate and inconclusive verdict

Addressed the central failure mode reported from real runs: two sessions
concluded too early with confident verdicts that only got corrected after the
operator pushed back. Since depth is the skill's whole purpose, `claim-check`
gains a grounding gate (`reviewers` `0.6.1` → `0.6.2`, `agent-workshop` `0.1.6` →
`0.1.7`). A new *Grounding a verdict* section defines an **evidence ladder** (ran
a repro / read the source at the top; subagent summary and inference at the
bottom): a `confirmed`/`refuted` verdict is earned only from the top rungs, a
verdict is only as strong as its weakest load-bearing claim, and a **contest
test** ("would this survive the operator pushing back once?") runs before any
verdict ships. A new sixth verdict, **`inconclusive`** (needs more information),
makes "I genuinely hit a wall" a first-class honest outcome — earned only after a
deep search, required to name the wall and the breaching input, and explicitly
gated so it cannot become a lazy escape from digging. See the amendment in
[`docs/decisions/claim-check.md`](decisions/claim-check.md).

- Skill body propagated to all six mirrors (single shared hash); origin doc
  updated and re-mirrored; `scripts/validate-native-plugin.ps1` passes.

### claim-check — refinements from first runs

Revised `claim-check` from two independent model runs on real tickets plus
operator review (`reviewers` `0.6.0` → `0.6.1`, `agent-workshop` `0.1.5` →
`0.1.6`). The output is now **verdict-first** (verdict + how-verified and
readiness lead; `Source` moves to the bottom) and reports per-claim evidence
**lopsidedly** — settled claims collapse, only contested ones get space, and a
uniform verdict needs no claim list. Two new investigation moves are explicit: a
**provenance** step (check where the premise's evidence came from vs. the repo's
actual source of truth) and **conflict reconciliation** (read disputed lines
yourself when subagents disagree; never average). Depth is right-sized to the
claim's blast radius, and `mis-scoped` gets a corrected-framing slot.

- The terminal boundary moved from "never run anything" to "never implement the
  fix": a repro / falsification test for a falsifiable code claim is now part of
  the search, not implementation. This revises the original terminal-state
  decision for code claims specifically — see the amendment in
  [`docs/decisions/claim-check.md`](decisions/claim-check.md).
- Skill body propagated to all six mirrors (single shared hash); origin doc
  updated and re-mirrored; `scripts/validate-native-plugin.ps1` passes.

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
