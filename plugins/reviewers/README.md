# reviewers

A direct-use Claude Code plugin from [Agent Workshop](https://github.com/giostriquer/agent-workshop):
four curated review agents you can run in any repo with **no setup**. They read your
code, specs, and tests and report findings — they never modify your files.

Agents install namespaced under the plugin, e.g. `reviewers:spec-reviewer`.

## Agents

| Agent | Reviews |
| --- | --- |
| `spec-reviewer` | a design spec or implementation plan for gaps, before you build |
| `test-quality-reviewer` | a test diff (or existing tests) for trustworthiness and risk coverage |
| `pattern-reviewer` | a code diff for implementation-pattern conformance; with no documented conventions it infers patterns from sibling files and labels findings lower-confidence |
| `vigil` | a repo's agent / skill / workflow layer for governance drift |

All four are advisory and read-only (`Read, Grep, Glob, Bash`) — no `Edit`/`Write`.

## Not included

No skills, MCP servers, or hooks. The `agent-workshop-onboard` skill and the
profile-dependent or edit-capable agents (`doc-indexer`, `wiki-maintainer`,
`visual-implementer`, `research`) live in the separate `agent-workshop` plugin,
which adopts the full scaffold into a project.
