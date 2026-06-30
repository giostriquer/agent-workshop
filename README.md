# Agent Workshop

Ready-to-use AI agents and skills for Claude Code and Codex, extracted from real projects and packaged as installable plugins. You get review agents that catch problems in specs, tests, and code, plus workflow skills for handoffs and reports — without building any of it yourself.

## Install

This repo doubles as a **plugin marketplace** — a catalog Claude Code can install plugins from directly. In a Claude Code session, add it once:

```
/plugin marketplace add giostriquer/agent-workshop
```

Then install one (or both) of the plugins:

```
/plugin install toolkit@agent-workshop
/plugin install agent-workshop@agent-workshop
```

Using Codex instead:

```powershell
codex plugin marketplace add giostriquer/agent-workshop
codex plugin add toolkit@agent-workshop
codex plugin add agent-workshop@agent-workshop
```

## The plugins

### `toolkit` — use right away

Review agents and direct-use skills, ready immediately after install with nothing to configure:

- **Agents:** `spec-reviewer` (design specs and plans), `code-quality-reviewer` (maintainability and structure of a diff), `test-quality-reviewer` (test code), `pattern-reviewer` (code-pattern conformance), and `vigil` (your agent/skill setup itself). All read-only — they review and report, never edit your files.
- **Skills:** `handoff-review`, `handoff-pr`, and `handoff-goal` hand in-flight work to a fresh session or agent; `doc-to-html` turns a markdown report into a polished dark-themed HTML page; `claim-check` runs an unbiased investigation of a premise (ticket, hunch, or question) and returns a verdict plus a readiness dossier; `qa-sweep` fans a QA team over a broad surface and corroborates every finding firsthand before it counts; `code-quality-review` runs an unusually strict, structure-first maintainability review over a branch's diff and pushes for restructurings that delete complexity.

Details in [`plugins/toolkit/README.md`](plugins/toolkit/README.md).

### `agent-workshop` — adopt the full scaffold

One guided skill, `agent-workshop-onboard`, for adopting the **project-coupled** scaffolding into your own repo — the agents that need adapting to your project (profile slots, conventions) and the workflow skills meant to live in-repo, plus the conventions that tie them together. It inspects the target, produces a read-only adoption plan, and only copies files after you approve. The direct-use review agents and self-contained skills don't need this — install `toolkit` for those.

## Going deeper

- [`docs/agents/`](docs/agents/) and [`docs/skills/`](docs/skills/) — the origin story of every agent and skill: what problem it solved and how it's used in practice.
- [`docs/conventions/`](docs/conventions/) — the portable working rules the agents rely on.
- [`docs/marketplace/README.md`](docs/marketplace/README.md) — the pack catalog, maturity labels, and host support.

Everything here came from months of lived-in use on real projects, sanitized to be portable. It's not a framework or a methodology — adopt the pieces that earn their keep in your project and skip the rest.
