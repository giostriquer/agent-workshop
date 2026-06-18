# toolkit

A direct-use Claude Code plugin from [Agent Workshop](https://github.com/giostriquer/agent-workshop):
four curated review agents plus six direct-use skills you can run in any repo with **no setup**.
The agents read your code, specs, and tests and report findings — they never modify your files.
Three skills produce structured handoff artifacts (review briefs, PR opens, and goal documents
for a new session to pursue); `doc-to-html` renders a markdown report as a standalone dark HTML page;
`claim-check` runs an unbiased, evidence-grounded investigation of a premise and returns a verdict plus a readiness dossier;
`qa-sweep` fans a QA team over a broad surface and corroborates every finding firsthand before it counts.

## Install

In a Claude Code session, add this repo as a marketplace, then install the plugin:

```
/plugin marketplace add giostriquer/agent-workshop
/plugin install toolkit@agent-workshop
```

(Terminal equivalent for the first step: `claude plugin marketplace add giostriquer/agent-workshop`.)

For Codex, use the skill-based counterpart:

```powershell
codex plugin marketplace add giostriquer/agent-workshop --ref main
codex plugin add toolkit@agent-workshop
```

Codex plugins do not currently expose standalone custom agents from plugin
manifests. The Codex `toolkit` package exposes `handoff-review`, `handoff-pr`,
`handoff-goal`, `doc-to-html`, `claim-check`, and `qa-sweep` as skills and bundles the reviewer agent files inertly; use the
`agent-workshop` onboarding plugin when you want to copy true `.codex/agents/`
wrappers into a target repo.

After install, the four agents are available, namespaced `toolkit:<agent>` —
e.g. `toolkit:spec-reviewer`. The six skills are available as `handoff-review`,
`handoff-pr`, `handoff-goal`, `doc-to-html`, `claim-check`, and `qa-sweep` (skills are invoked by name, not namespaced). The same marketplace also
hosts the `agent-workshop` onboarding plugin (`/plugin install agent-workshop@agent-workshop`)
for the full scaffold-adoption flow.

## Agents

| Agent | Reviews |
| --- | --- |
| `spec-reviewer` | a design spec or implementation plan for gaps, before you build |
| `test-quality-reviewer` | a test diff (or existing tests) for trustworthiness and risk coverage |
| `pattern-reviewer` | a code diff for implementation-pattern conformance; with no documented conventions it infers patterns from sibling files and labels findings lower-confidence |
| `vigil` | a repo's agent / skill / workflow layer for governance drift |

All four are advisory and read-only (`Read, Grep, Glob, Bash`) — no `Edit`/`Write`.

## Skills

| Skill | Produces |
| --- | --- |
| `handoff-review` | a self-contained, unbiased review brief (task-vs-code, rules, info-leak, correctness) for a separate agent/session to run before a PR |
| `handoff-pr` | a structured PR handoff artifact (title, body, ticket links, status) for a separately-authorized session to open — never opens the PR itself |
| `handoff-goal` | a self-contained goal document (goal + definition of done, current state, concrete operating rules) for a new session to pursue autonomously across compactions — never pursues the goal itself |
| `doc-to-html` | a standalone dark-themed HTML page rendered from a markdown report / audit / findings doc (TOC, keyboard nav, evidence appendix, print stylesheet), with a rigid editing discipline for later revisions |
| `claim-check` | an unbiased, evidence-grounded investigation of a premise (ticket / hunch / question) against the current repo — a validity verdict with evidence plus a readiness dossier (or exactly what's missing); never implements the work |
| `qa-sweep` | a team-scale QA pass over a decomposable surface — fans one agent per slice against the real running artifact, reproduces every verdict-moving finding firsthand before it counts, separates regressions from pre-existing bugs, and returns a verdict-first, confidence-tagged report; never fixes what it finds |

## Not included

No MCP servers or hooks. The `agent-workshop-onboard` skill and the
profile-dependent or edit-capable agents (`doc-indexer`, `wiki-maintainer`,
`visual-implementer`, `research`) live in the separate `agent-workshop` plugin,
which adopts the full scaffold into a project.
