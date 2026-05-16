# Agents

Origin docs for the eight agents shipped in `.claude/agents/`. Each doc covers:

- **Origin** — the pressure that created the agent.
- **Problem** — what specifically it solves.
- **Solution shape** — how it works in practice.
- **Real workflow snippet** — example `CLAUDE.md` or `AGENTS.md` lines that wire the agent into a project.
- **Pitfalls** — mistakes observed in lived-in use.
- **Adaptation notes** — how to fit it to your project.

The agent specs in `.claude/agents/<name>.md` are the canonical contracts. These docs explain the *why*.

## Roster

| Agent | One-line role |
|---|---|
| [`wiki-maintainer`](wiki-maintainer.md) | Repo-local documentation owner; diff-driven by default, audit-mode on request. |
| [`doc-indexer`](doc-indexer.md) | Routing and audit helper; reduces context burden on `wiki-maintainer`. |
| [`pattern-reviewer`](pattern-reviewer.md) | Diff-driven implementation-pattern compliance check after code-quality review. |
| [`spec-reviewer`](spec-reviewer.md) | Pre-implementation gate for design specs and implementation plans. |
| [`test-quality-reviewer`](test-quality-reviewer.md) | Diff-driven test-code trustworthiness review; the fourth review stage, audit-mode on request. |
| [`research`](research.md) | Forward-looking research notes with structured scoring; dispatched by the `research` skill. |
| [`vigil`](vigil.md) | Advisory review of the agent / skill / workflow-instruction layer itself. |
| [`visual-implementer`](visual-implementer.md) | Execution agent for approved AI-generated visual assets. |

## Roles that compose

These agents are designed to compose, not duplicate:

- **Documentation:** `wiki-maintainer` owns; `doc-indexer` retrieves and audits.
- **Pre-implementation review:** `spec-reviewer` (specs and plans, before code).
- **Implementation review:** the project's code-quality reviewer, then `pattern-reviewer`, then `test-quality-reviewer` (after code).
- **Forward-looking research:** `research` (skill) → `research` (agent).
- **Visual execution:** `visual-advisor` (skill, taste) → `visual-implementer` (agent, execution).
- **Governance:** `vigil` audits the agent layer itself.

## Adoption

Read the origin doc for each agent before adopting. If a problem doesn't exist in your project (e.g., you don't have a layered code-architecture surface, you don't have AI-generated visual assets), the corresponding agent is probably not earning its keep — leave it out.

The discipline: copy what you'll actually use, sanitize project-specific paths, document the adaptation in your project's `CLAUDE.md` and `AGENTS.md`.
