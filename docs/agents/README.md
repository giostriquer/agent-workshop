# Agents

Origin docs for the nine agents the scaffold ships (across the `toolkit` and `agent-workshop` plugins). Each doc covers:

- **Origin** — the pressure that created the agent.
- **Problem** — what specifically it solves.
- **Solution shape** — how it works in practice.
- **Real workflow snippet** — example `CLAUDE.md` or `AGENTS.md` lines that wire the agent into a project.
- **Pitfalls** — mistakes observed in lived-in use.
- **Adaptation notes** — how to fit it to your project.

Each agent's canonical spec lives in the plugin that ships it — `plugins/toolkit/agents/<name>.md` for the direct-use reviewers, the onboarding bundle (`plugins/agent-workshop/.../references/agents/<name>.md`) for the adoptable ones. These docs explain the *why*.

Pack metadata lives in the onboarding plugin's bundled catalog (`plugins/agent-workshop/skills/agent-workshop-onboard/references/catalog.json`), with operator-facing guidance in [`../marketplace/`](../marketplace/). The roster below explains agent roles; the marketplace docs explain adoption bundles and required project profiles.

## Roster

| Agent | Pack | One-line role |
|---|---|---|
| [`wiki-maintainer`](wiki-maintainer.md) | `docs-core` | Repo-local documentation owner; diff-driven by default, audit-mode on request. |
| [`doc-indexer`](doc-indexer.md) | `docs-core` | Routing and audit helper; reduces context burden on `wiki-maintainer`. |
| [`code-quality-reviewer`](code-quality-reviewer.md) | `review-core` | Strict, structure-first code-quality audit over a diff; the code-quality stage before pattern-reviewer. Loads the `code-quality-review` skill's rubric. |
| [`pattern-reviewer`](pattern-reviewer.md) | `review-core` | Diff-driven implementation-pattern compliance check after code-quality review. |
| [`spec-reviewer`](spec-reviewer.md) | `review-core` | Pre-implementation gate for design specs and implementation plans. |
| [`test-quality-reviewer`](test-quality-reviewer.md) | `review-core` | Test-code trustworthiness, risk coverage, and test-strategy review; diff, audit, and strategy modes. |
| [`research`](research.md) | `specialized` | Forward-looking research notes with structured scoring; dispatched by the `research` skill. |
| [`vigil`](vigil.md) | `governance` | Advisory review of the agent / skill / workflow-instruction layer itself. |
| [`visual-implementer`](visual-implementer.md) | `specialized` | Execution agent for approved AI-generated visual assets. |

## Roles that compose

These agents are designed to compose, not duplicate:

- **Documentation:** `wiki-maintainer` owns; `doc-indexer` retrieves and audits.
- **Pre-implementation review:** `spec-reviewer` (specs and plans, before code).
- **Implementation review:** `code-quality-reviewer` (maintainability and structure), then `pattern-reviewer` (pattern conformance), then `test-quality-reviewer` (test trustworthiness; use `mode: strategy` separately for project-level test-quality profiles).
- **Forward-looking research:** `research` (skill) → `research` (agent).
- **Visual execution:** `visual-advisor` (skill, taste) → `visual-implementer` (agent, execution).
- **Governance:** `vigil` audits the agent layer itself.

## Adoption

Read the origin doc for each agent before adopting. If a problem doesn't exist in your project (e.g., you don't have a layered code-architecture surface, you don't have AI-generated visual assets), the corresponding agent is probably not earning its keep — leave it out.

The discipline: copy what you'll actually use, sanitize project-specific paths, document the adaptation in your project's `CLAUDE.md` and `AGENTS.md`.
