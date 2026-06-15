# Skills

Origin docs for the eleven skills shipped in `.claude/skills/`. Each doc covers:

- **Origin** — the pressure that created the skill.
- **Problem** — what specifically it solves.
- **Solution shape** — how it works.
- **Real invocation snippet** — example use.
- **Pitfalls** — observed mistakes.
- **Adaptation notes** — fit to your project.

The skill files in `.claude/skills/<name>/SKILL.md` are the canonical contracts. These docs explain the *why*.

## Roster

| Skill | One-line role |
|---|---|
| [`change-log`](change-log.md) | Compact entry rules for `docs/change-log.md`; spec/plan landing lifecycle. |
| [`doc-audit`](doc-audit.md) | Proactive 14-check audit across mechanical, threshold, judgment, and code-arch tiers. Report-only. |
| [`agent-audit`](agent-audit.md) | Orchestrates `vigil` for governance audits. Deterministic pre-checks plus advisory review. |
| [`push`](push.md) | Branch-aware commit and push; pulls before staging; uses `change-log` as message source when relevant. |
| [`research`](research.md) | Forward-looking research orchestration; thin skill, heavy `research` agent. |
| [`visual-advisor`](visual-advisor.md) | Visual taste advisor; mode-aware (refinement / exploration / rebaseline) prompt shaping. |
| [`handoff-review`](handoff-review.md) | Produces a self-contained, unbiased review brief (task-vs-code, rules, info-leak, correctness) for a separate agent/session; spawns a reviewer or writes a scratch file. |
| [`handoff-pr`](handoff-pr.md) | Produces a structured PR handoff artifact (title, body, ticket links, status) for a separately-authorized session; never opens the PR. |
| [`handoff-goal`](handoff-goal.md) | Produces a self-contained goal document (goal + definition of done, state, concrete operating rules) for a new session to pursue autonomously across compactions; never pursues the goal itself. |
| [`doc-to-html`](doc-to-html.md) | Renders a markdown report as a standalone dark HTML page; design defaults are adaptable, editing process rules (rewrite-on-direction-change, renumbering, pre-finish checks) are rigid. |
| [`claim-check`](claim-check.md) | Runs an unbiased, evidence-grounded investigation of a premise (ticket / hunch / question) against the current repo; returns a validity verdict with evidence plus a readiness dossier, and never implements the work. |

## Composition

Skills here pair naturally with agents:

- `change-log` is preloaded into `wiki-maintainer` and `visual-implementer` via the `skills:` frontmatter.
- `doc-audit` orchestrates `doc-indexer` for its mechanical tier.
- `agent-audit` orchestrates `vigil`.
- `research` (skill) orchestrates `research` (agent).
- `visual-advisor` is the advisor counterpart to `visual-implementer`.
- `push` stands alone — it's a workflow primitive, not a multi-stage orchestration.
- `doc-to-html` stands alone — a rendering and page-maintenance primitive; it pairs with `visual-advisor` only when the page needs art direction beyond its defaults.
- `handoff-review`, `handoff-pr`, and `handoff-goal` are handoff primitives — each emits a self-contained artifact a *different* session consumes; they stand alone, not orchestrating other skills. The first two hand a finished branch backward (review, PR); `handoff-goal` hands work forward (a goal to pursue).
- `claim-check` is an investigation primitive — it runs the search itself, fanning out to subagents rather than orchestrating other skills. It pairs forward with `handoff-goal`: a `confirmed`, ready-to-work verdict feeds its dossier straight into a goal handoff.

## Adoption

Same discipline as agents: copy what you'll use, drop what doesn't earn its keep, sanitize project-specific paths, document the adaptation in your project's docs.
