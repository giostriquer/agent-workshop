# Decision: add the `claim-check` skill

**Date:** 2026-06-15

## Status

Implemented (2026-06-15). `validate-native-plugin.ps1` passes.

A completeness sweep during execution caught two skill-set enumerations the
packaging list below had missed: `docs/marketplace/native-plugin.md` and
`docs/marketplace/README.md` (each mirrored into both reference roots). Both
name the Codex reviewers skill surface and were updated to include
`claim-check`, then re-mirrored. The lesson for the next skill addition: the
reviewers skill set is enumerated in the marketplace docs too, not only the
plugin manifests and READMEs.

## Context

A recurring task across real sessions: the operator hands the session a
**premise** — most often a tracker ticket, but sometimes a hunch they are
carrying or a bare question — and wants it investigated *before* anyone acts on
it. The premise cannot be trusted at face value: the code may have moved, a
sibling ticket or merged PR may have addressed it in full or in part, or the
framing may simply be stale. But it also cannot be assumed wrong — **the premise
still holding is a perfectly good, often the best, outcome.**

The operator has been hand-rolling this prompt repeatedly. The wording drifts
every time ("spawn agents to explore," "never assume, if you are unsure,
search," "the ticket being correct is a fine answer," "gather context so we can
work it reliably"), but the intent is stable. That drift across a stable intent
is the textbook pressure for a skill: capture the invariant once, stop
re-deriving the prompt.

The investigation answers **two separate questions** the operator keeps asking
together:

1. Is the premise still true, given the current repo?
2. If it is actionable, what do we need to know to work it reliably — or what is
   missing that blocks it?

## The shape

`claim-check` is an **unbiased, evidence-grounded investigation skill** the main
session invokes with a premise. It is generalized over input source — a ticket
is the richest and primary worked example, not the skill's identity.

**Load-bearing rule (the invariant that makes it work):** every claim is a
*hypothesis to be checked against current repo reality* — not assumed true, not
assumed false. The skill is not trying to prove the premise wrong *or* to
rubber-stamp it; "the premise still holds" is a first-class outcome.
Conclusions come only from evidence the session went and found. Anything unknown
resolves to "go search," never "probably."

**Input front-end (resolve the premise by source):**

- **A ticket / doc (link or pasted):** fetch its substance — tracker MCP / web
  if reachable, else ask the operator to paste the body + acceptance criteria.
  Its claims arrive pre-articulated. (Same graceful fallback as `handoff-review`
  for getting the ticket's substance, not just its link.)
- **A hunch / context the operator is carrying, or a bare question:** no claims
  are stated yet, so **articulate the premise into atomic, checkable claims and
  confirm them with the operator before investigating.** This articulation step
  is the guardrail that keeps generality from becoming mush — the investigation
  always operates on concrete hypotheses regardless of how fuzzy the input was.

**Investigation:**

1. Decompose the premise into atomic claims (the hypotheses).
2. Check each claim against the current repo. **Fan-out is the recommended tool
   here — not a mandate** — strongest for code/doc *scanning*; the main session
   orchestrates and may search directly. **Subagent briefs must be neutral and
   specific** ("what does the code at X currently do?", not "confirm X is
   missing") and must return **evidence, not judgments.** That neutrality plus
   tight scoping is what keeps the fan-out from drifting loose — the operator's
   stated concern.
3. Scan for prior / parallel work — commits, merged PRs, sibling tickets — that
   already addressed the premise in full or in part. (The "another ticket fixed
   it" case the premise itself can't see.)
4. **Adversarially re-check** any conclusion that came back "confirmed" *or*
   "obsolete" — a second pass that tries to falsify it. This guards against both
   a wrong "it's already handled" and a lazy rubber-stamp.

**Two-axis output** (kept separate so a valid premise can still be "not ready"):

- **Validity verdict** — one of:
  - `confirmed` — the premise holds; worth acting on.
  - `partially-confirmed` — part holds, part is already addressed or false.
  - `refuted / obsolete` — no longer holds (already fixed, or never matches
    current reality).
  - `mis-scoped` — points at something real but its framing / scope is wrong;
    the actual situation differs.
  - `confirmed-but-blocked` — holds and actionable, but needs more info or a
    decision before it can be worked reliably.

  Each verdict carries its **evidence**: `file:line`, commits, related
  tickets / PRs.
- **Readiness** — if actionable, a **dossier**: where to start, the relevant
  code / docs, gotchas, dependencies, open unknowns. If not ready, **exactly
  what is missing** to make it workable.

**Terminal state:** deliver verdict + dossier, hand control back. The skill
**never implements** the work — that is a separate, deliberate step the operator
owns.

**Artifact:** structured in-chat report by default. The session *may* persist it
where it naturally belongs — a repo documentation home if one fits the existing
pattern, or `tmp/<YYYY-MM-DD>-<slug>-claim-check.md` when durability or handoff
is wanted. Not forced either way; the session judges by the repo's conventions
and the operator's intent.

**Rules section will pin:** never conclude from assumption; unbiased
(confirming the premise is a win); articulate fuzzy input into confirmed claims
before investigating; subagent briefs neutral + evidence-returning; stop at the
dossier, never implement.

## Skill body outline

Matches the reviewers-plugin house style (statement of what it does / doesn't →
*When to use* → *The one rule that makes this work* → *Resolving the premise* →
*Steps* → *Output* template → *Rules*). The ticket case is the inline worked
example.

## Packaging

Full `doc-to-html`-equivalent landing: core parity + the `reviewers` direct-use
channel + the onboarding reference mirrors (forced by the validation script) +
both plugin version bumps. The marketplace `catalog.json` is **not** touched —
it indexes agents only. The Codex marketplace file (`.agents/plugins/marketplace.json`)
is **not** touched — it carries no version or skill-list fields for either
plugin.

**Core parity (6):**

- Canonical: `.claude/skills/claim-check/SKILL.md`.
- Byte-identical mirrors: `.codex/skills/claim-check/SKILL.md`,
  `.gemini/skills/claim-check/SKILL.md` (per the skill-parity convention;
  `.opencode/` does not mirror skills).
- Origin doc: `docs/skills/claim-check.md`.
- Roster entry in `docs/skills/README.md` (count grows by one).
- `README.md` skills lines — both the reviewers skills line and the scaffold
  skill count — gain `claim-check`.

**`reviewers` channel (5) — version `0.5.0` → `0.6.0`:**

- Byte-identical payload: `plugins/reviewers/skills/claim-check/SKILL.md`.
- `plugins/reviewers/README.md` — skills table + prose (four skills → five).
- `plugins/reviewers/.claude-plugin/plugin.json` — version.
- `plugins/reviewers/.codex-plugin/plugin.json` — version + `longDescription` +
  `defaultPrompt` (name the fifth skill).
- `.claude-plugin/marketplace.json` — `reviewers` entry version (+ description if
  it enumerates skills). Must equal the manifest version (validation asserts).

**Onboarding reference mirrors (6) — forced by `validate-native-plugin.ps1`:**

The script asserts every `.claude/skills/*` and every `docs/skills/*` has a
byte-identical mirror in **both** reference roots. Adding the canonical skill and
origin doc therefore requires, in each of the root reference root
(`skills/agent-workshop-onboard/references`) and the Codex reference root
(`plugins/agent-workshop/skills/agent-workshop-onboard/references`):

- `references/skills/claim-check.md` (== canonical SKILL.md).
- `references/docs/skills/claim-check.md` (== origin doc).
- `references/docs/skills/README.md` (re-mirror, since the roster changed).

**Onboarding plugin version bump (`agent-workshop` `0.1.4` → `0.1.5`) — payload
changed, so installs should refresh:**

- `.claude-plugin/plugin.json` (root manifest).
- `plugins/agent-workshop/.claude-plugin/plugin.json` (Claude payload manifest;
  validation asserts it equals the root manifest).
- `plugins/agent-workshop/.codex-plugin/plugin.json` (Codex payload manifest;
  validation asserts it equals the root manifest).
- `.claude-plugin/marketplace.json` — `agent-workshop` entry version (must equal
  the manifest version).

**Validation + change log (2):**

- `scripts/validate-native-plugin.ps1` — the two `$expectedSkills` arrays
  (`Assert-ReviewersPlugin`, `Assert-CodexReviewersPlugin`) widen to
  `@("claim-check", "doc-to-html", "handoff-goal", "handoff-pr", "handoff-review")`.
- `docs/change-log.md` — entry via the `change-log` skill when this lands.

## Non-goals

- Not a research / deep-research skill. Those face outward and forward (what's
  out there, what's coming); `claim-check` faces inward and present (is this
  true, here, now). It does not do web-survey research as its purpose.
- It does not implement the work it validates. The dossier is the terminal
  deliverable; acting on it is a separate step the operator triggers.
- It does not pick the premise for the operator. With no clear input it asks,
  rather than inventing a claim to check.
- It is not an agent. The main session orchestrates and fans out to subagents; a
  single dispatched agent cannot drive that fan-out.

## Validation

- `scripts/validate-native-plugin.ps1` passes (both `$expectedSkills` arrays
  widened; all mirrors byte-identical; both version bumps consistent across
  manifests and the Claude marketplace).
- GREEN test: a model given the skill and a premise that is *already addressed
  by a merged change* reports `refuted / obsolete` **with the addressing commit
  / PR as evidence**, rather than either assuming the premise true or
  rubber-stamping it.
- GREEN test: a model given the skill and a *fuzzy hunch* (not a ticket) first
  articulates atomic claims and confirms them before investigating, rather than
  investigating the vague statement directly.

## Acceptance criteria

- `/claim-check <ticket | claim | question>` runs the investigation and returns
  the two-axis output (validity verdict with evidence + readiness dossier or
  what's-missing), and stops without implementing.
- The skill text carries the neutral-subagent-brief rule and the
  articulate-before-investigating guardrail explicitly.
- All mirrors (`.codex`, `.gemini`, `plugins/reviewers`, both onboarding
  reference roots) are byte-identical to canonical / source.
- `reviewers` is at `0.6.0` and `agent-workshop` at `0.1.5`, consistent across
  every manifest and the Claude marketplace entry.
- `docs/change-log.md` gets an entry via the `change-log` skill when this lands.
