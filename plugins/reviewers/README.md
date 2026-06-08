# reviewers

A direct-use Claude Code plugin from [Agent Workshop](https://github.com/giostriquer/agent-workshop):
four curated review agents plus two PR/review handoff skills you can run in any repo with **no setup**.
The agents read your code, specs, and tests and report findings — they never modify your files.
The skills produce structured handoff artifacts for review briefs and PR opens.

## Install

In a Claude Code session, add this repo as a marketplace, then install the plugin:

```
/plugin marketplace add giostriquer/agent-workshop
/plugin install reviewers@agent-workshop
```

(Terminal equivalent for the first step: `claude plugin marketplace add giostriquer/agent-workshop`.)

After install, the four agents are available, namespaced `reviewers:<agent>` —
e.g. `reviewers:spec-reviewer`. The two skills are available as `handoff-review` and
`handoff-pr` (skills are invoked by name, not namespaced). The same marketplace also
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

## Not included

No MCP servers or hooks. The `agent-workshop-onboard` skill and the
profile-dependent or edit-capable agents (`doc-indexer`, `wiki-maintainer`,
`visual-implementer`, `research`) live in the separate `agent-workshop` plugin,
which adopts the full scaffold into a project.
