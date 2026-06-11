# Agent Workshop

A scaffolding repo of working agent definitions, skills, and the operational discipline that makes them useful in practice.

This is **not a methodology** and **not a framework**. It is a curated drop-in surface — agents, skills, conventions, and origin notes — extracted from real lived-in use across other projects, sanitized so it can be adopted without inheriting any specific project's domain context.

The goal: when you start a new project that wants AI-agent infrastructure, copy the relevant pieces in instead of either re-deriving everything from scratch or pointing models at a different project's docs.

## What's here

- `.claude/agents/` — eight canonical agent definitions (`doc-indexer`, `pattern-reviewer`, `spec-reviewer`, `test-quality-reviewer`, `research`, `vigil`, `visual-implementer`, `wiki-maintainer`).
- `.codex/agents/`, `.gemini/agents/`, `.opencode/agents/` — thin wrappers pointing at the canonical Claude specs, in each host's native format. Worked examples of the cross-host wrapper pattern (see `docs/conventions/cross-host-wrappers.md`).
- `.claude/skills/`, `.codex/skills/`, `.gemini/skills/` — seven working skills (`agent-audit`, `change-log`, `doc-audit`, `doc-to-html`, `push`, `research`, `visual-advisor`), mirrored in full across hosts. OpenCode is wrapper-only by convention and does not carry a `skills/` folder.
- `marketplace/catalog.json` — machine-readable catalog of agent packs, maturity labels, role boundaries, host-wrapper support, and project profile slots.
- `.claude-plugin/marketplace.json` and `.agents/plugins/marketplace.json` — native Claude Code and Codex marketplace metadata. The Claude Code marketplace lists two plugins (`agent-workshop` onboarding and `reviewers` direct-use); the Codex marketplace carries the onboarding plugin only.
- `plugins/agent-workshop/` and `skills/agent-workshop-onboard/` — the slim native plugin payload and root skill copy. Marketplace installs point at `plugins/agent-workshop/`, which exposes only `agent-workshop-onboard`; scaffold agents and skills stay nested non-discoverable references until copied into a target repo by an approved plan.
- `plugins/reviewers/` — a second Claude Code plugin that ships four standalone-capable agents (`spec-reviewer`, `test-quality-reviewer`, `pattern-reviewer`, `vigil`) as active plugin agents for direct use, with no onboarding skill. For people who want to use the agents without adopting the scaffold into a project. See [`docs/marketplace/README.md`](docs/marketplace/README.md).
- `docs/agents/` — origin story per agent: what pressure created it, what problem it solves, how it works in practice, real workflow snippets, observed pitfalls.
- `docs/skills/` — same shape, per skill.
- `docs/conventions/` — portable conventions that govern how the agents and skills compose: reviewer-session continuation, per-task fresh dispatches, cross-host skill parity, doc routing, scripts discipline.
- `docs/examples/` — end-to-end walkthroughs that show the agents and skills working together.
- `docs/setup.md` — how to drop this scaffold into a new project.
- `CLAUDE.md` and `AGENTS.md` — instructions for Claude Code and Codex/other CLIs when they're working **in this repo**, maintaining the scaffold itself.

## Who this is for

- Solo operators starting new projects that want AI-agent infrastructure.
- Teams adopting an agent-driven workflow who want a working baseline rather than a blank page.
- People comparing agent setups; the origin docs make trade-offs explicit.

It is not for: turnkey end-user products, plug-and-play "just install it" experiences, or claims about a new methodology.

## How to use it

The fastest path is the native plugin marketplace.

In a Claude Code session, add this repo once:

```
/plugin marketplace add giostriquer/agent-workshop
```

Then install whichever plugin fits — both live in the `agent-workshop` marketplace:

- **Use the review agents directly, no onboarding** — `/plugin install reviewers@agent-workshop`. Ships four standalone-capable agents (`spec-reviewer`, `test-quality-reviewer`, `pattern-reviewer`, `vigil`) that review specs, tests, code, and the agent/skill layer and never edit your files, plus four direct-use skills (`handoff-review`, `handoff-pr`, `handoff-goal`, `doc-to-html`). See [`plugins/reviewers/README.md`](plugins/reviewers/README.md).
- **Onboard the scaffold into a project** — `/plugin install agent-workshop@agent-workshop`, then invoke `agent-workshop-onboard` in the target repo and let `mode: plan` produce a read-only adoption plan before approving `mode: apply`. (Codex has its own marketplace for this onboarding plugin — see [`docs/marketplace/native-plugin.md`](docs/marketplace/native-plugin.md).)

In Codex on a separate machine, add the same repository as a Codex marketplace
and install the plugin that matches the job:

```powershell
codex plugin marketplace add giostriquer/agent-workshop --ref main
codex plugin add agent-workshop@agent-workshop
codex plugin add reviewers@agent-workshop
```

The Codex marketplace has two installable entries:

- `agent-workshop` — exposes only `agent-workshop-onboard` for scaffold adoption.
- `reviewers` — exposes the `handoff-review`, `handoff-pr`, `handoff-goal`, and
  `doc-to-html` skills. The reviewer agent files are bundled in the payload, but
  Codex custom agents still need repo-local `.codex/agents/` wrappers from
  onboarding.

Manual setup remains available in [`docs/setup.md`](docs/setup.md). It describes the lift-and-shift path (copy `.claude/`, write project-specific `CLAUDE.md` and `AGENTS.md`, drop in the conventions you need) and the more involved path (read the origin docs first, decide which agents earn their keep for your project, omit or replace the rest).

For pack-based adoption, start with [`docs/marketplace/native-plugin.md`](docs/marketplace/native-plugin.md), [`docs/marketplace/README.md`](docs/marketplace/README.md), and [`marketplace/catalog.json`](marketplace/catalog.json), then use [`docs/setup.md`](docs/setup.md) for the manual file-copy mechanics when you do not use the plugin.

If you're trying to understand a specific agent or skill, the matching `docs/agents/<name>.md` or `docs/skills/<name>.md` is the entry point. Each one explains why the agent or skill exists, what problem it solved, and what real workflow instructions look like in the project that originated it.

## A note on origin

Most of this material was extracted from a single project that used these agents and skills in production over many months. The origin docs reference that context where it shaped the design — what failure mode the convention was responding to, what subsequent adaptations refined it. The intent is not to teach that project; it's to make the trade-offs visible so you can decide whether each piece earns its keep for *your* project.

If a piece doesn't earn its keep, omit it. The discipline is "ship the smallest working version and let real use shape what stays" — applied to the scaffold itself, not just to the projects that adopt it.

## Adoption checklist

1. Read [`docs/marketplace/README.md`](docs/marketplace/README.md) and choose the smallest pack set that fits your project.
2. Prefer the native plugin: run `agent-workshop-onboard` with `mode: plan` in the target repo.
3. Review the proposed file set, profile slots, omitted agents, and validation checks.
4. Approve `mode: apply` only when the plan names exact project-local paths.
5. If you are not using the plugin, read [`docs/setup.md`](docs/setup.md) and manually copy the selected `.claude/agents/`, `.claude/skills/`, and host wrappers into your project's repo root.
6. Write your project's own `CLAUDE.md` and `AGENTS.md` — do not copy this repo's; they are for maintaining the scaffold itself.
7. Fill the required profile slots in your project docs and workflow instructions.
8. Read the origin docs for the agents and skills you copied. Sanitize any project-specific paths.
9. Drop in the conventions you'll actually use; skip the rest.
10. Use the agents in real work for a few weeks. Keep what earns its keep, prune what doesn't.

## What this repo does NOT promise

- A methodology with a name.
- That every agent or skill here is right for every project.
- Backward compatibility — the scaffold evolves with use.
- A solution to "agent orchestration" generally; the scope is *durable agent definitions and skills for solo or small-team operators using Claude Code, Codex, and similar CLIs*.
