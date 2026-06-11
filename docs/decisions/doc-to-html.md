# Decision: add the `doc-to-html` skill

**Date:** 2026-06-11

## Status

Implemented.

## Context

A recurring deliverable across real sessions: a markdown document — research
findings, an audit, a review — that the operator wants as a polished,
standalone HTML page. Built ad hoc each time, the page converges on the same
lessons learned the same expensive way:

1. **Readability failures on dark canvases.** Serif body text reads muddy on
   dark screens; gray-on-dark text is the single biggest readability killer;
   per-block colored boxes and left-border stripes turn a calm report into
   noise.
2. **Structure drift under edits.** Numbered sections, the TOC, element ids,
   and the keyboard-nav order array fall out of sync the first time a section
   is inserted or moved — the page silently breaks in ways nobody re-checks.
3. **Wrong edit strategy.** Restyling markup incrementally toward a *different
   design direction* compounds into a mess every time; and a single "I don't
   like it" gets answered with a whole-design swing instead of turning the one
   failing knob.

Each session that builds such a page without the distilled conventions repeats
the failures. That is the textbook pressure for a skill.

## The shape

`doc-to-html` renders a markdown document as a single self-contained dark
HTML page and governs how that page is edited afterward. Two deliberately
different stances inside one skill:

- **Design system as defaults.** The dark, calm, structured visual language
  (bright sans-serif body, subtle card panels, one sparing accent family,
  readable code chips) is presented as battle-tested defaults — adaptable when
  the document calls for a different mood.
- **Process rules as rigid.** One-pass generation, targeted-edit vs
  clean-rewrite (design-direction changes always rewrite), one-knob-at-a-time
  feedback handling, the renumbering procedure, and the pre-finish checklist
  are non-negotiable — each rule exists because its absence failed in real
  use.

The skill embeds compact reference markup for the two structures sessions
kept reinventing — the card (label → headline → metadata → body) and the
vertical stepper — so future sessions copy instead of improvising.

Content principles ride along: tables over prose walls, verified-links-only
(every external link fetched and annotated with its result), and an evidence
appendix that keeps raw proof out of the body without dropping it.

## Packaging

A scaffold skill, not a plugin skill (it ships through onboarding, not through
`reviewers`):

- Canonical at `.claude/skills/doc-to-html/SKILL.md`; byte-identical mirrors
  at `.codex/` and `.gemini/` per the skill-parity convention (`.opencode/`
  does not mirror skills).
- Onboard references in both reference roots: `references/skills/doc-to-html.md`
  and `references/docs/skills/doc-to-html.md`, plus the re-mirrored
  `references/docs/skills/README.md`.
- Origin doc at `docs/skills/doc-to-html.md`; roster entry in
  `docs/skills/README.md` (ten skills).
- `README.md` skills line gains the new name.
- The new reference files change the `plugins/agent-workshop` payload that
  both the Claude and Codex marketplaces serve, so the onboarding plugin bumps
  `0.1.2` → `0.1.3` in both payload manifests, the root manifest, and the
  Claude marketplace entry. (The Codex marketplace file carries no version
  fields.) This supersedes the handoff-goal precedent of leaving the
  onboarding version untouched on reference-only additions — a changed
  payload should carry a changed version so installs refresh.
- Distribution to Codex is via onboarding only — `doc-to-html` is a scaffold
  skill like the other seven, not an active skill in the `reviewers` plugin;
  Codex sessions get it repo-locally after `agent-workshop-onboard` applies
  it to a target repo.

## Non-goals

- Not a general frontend-design skill — scope is the report/document page
  shape only.
- No external assets, build steps, or frameworks; the page opens from disk.
- The skill does not pick the document's content or structure; it renders and
  maintains what the markdown says.

## Validation

- `scripts/validate-native-plugin.ps1` passes with the new reference files.
- GREEN test: a model given the skill and a revision scenario (insert a
  section mid-document; "the page looks noisy") applies the renumbering
  procedure and the one-knob rule instead of ad-hoc edits or a whole-design
  swing.

## Acceptance criteria

- `/doc-to-html` over a markdown file yields a single self-contained HTML
  page with TOC, keyboard nav, evidence appendix, print stylesheet, and the
  default design system.
- The skill text carries the card and stepper reference markup inline.
- All mirrors and both reference roots are byte-identical to canonical.
- `docs/change-log.md` gets an entry via the `change-log` skill when this
  lands.
