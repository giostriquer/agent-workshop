# Agent Workshop

Ready-to-use AI agents and skills for Claude Code and Codex, extracted from real projects and packaged as installable plugins. You get review agents that catch problems in specs, tests, and code, plus workflow skills for handoffs and reports — without building any of it yourself.

## Install

This repo doubles as a **plugin marketplace** — a catalog Claude Code can install plugins from directly. In a Claude Code session, add it once:

```
/plugin marketplace add giostriquer/agent-workshop
```

Then install one (or both) of the plugins:

```
/plugin install reviewers@agent-workshop
/plugin install agent-workshop@agent-workshop
```

Using Codex instead:

```powershell
codex plugin marketplace add giostriquer/agent-workshop --ref main
codex plugin add reviewers@agent-workshop
codex plugin add agent-workshop@agent-workshop
```

(On Codex, the `reviewers` plugin exposes the four skills; its reviewer agents need the repo-local wrappers that onboarding sets up.)

## The plugins

### `reviewers` — use right away

Review agents and direct-use skills, ready immediately after install with nothing to configure:

- **Agents:** `spec-reviewer` (design specs and plans), `test-quality-reviewer` (test code), `pattern-reviewer` (code-pattern conformance), and `vigil` (your agent/skill setup itself). All read-only — they review and report, never edit your files.
- **Skills:** `handoff-review`, `handoff-pr`, and `handoff-goal` hand in-flight work to a fresh session or agent; `doc-to-html` turns a markdown report into a polished dark-themed HTML page.

Details in [`plugins/reviewers/README.md`](plugins/reviewers/README.md).

### `agent-workshop` — adopt the full scaffold

One guided skill, `agent-workshop-onboard`, for when you want the whole working setup in your own project — eight agents, seven skills, and the conventions that tie them together. Run it in the target repo: it first produces a read-only adoption plan, and only copies files after you approve.

## Going deeper

- [`docs/setup.md`](docs/setup.md) — manual adoption: copy the files yourself, no plugin.
- [`docs/agents/`](docs/agents/) and [`docs/skills/`](docs/skills/) — the origin story of every agent and skill: what problem it solved and how it's used in practice.
- [`docs/conventions/`](docs/conventions/) — the portable working rules the agents rely on.
- [`docs/marketplace/README.md`](docs/marketplace/README.md) — the pack catalog, maturity labels, and host support.

Everything here came from months of lived-in use on real projects, sanitized to be portable. It's not a framework or a methodology — adopt the pieces that earn their keep in your project and skip the rest.
