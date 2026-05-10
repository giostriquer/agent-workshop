# Setup — adopting agent-workshop into a new project

This guide describes how to drop the scaffold's agents, skills, and conventions into a new project. The paths assume your target project's repo root is `<project>/`.

## What you copy

```
agent-workshop/.claude/agents/    →  <project>/.claude/agents/
agent-workshop/.claude/skills/    →  <project>/.claude/skills/
```

The conventions, origin docs, and examples in `agent-workshop/docs/` are reference material for *understanding* the scaffold. Adopting projects do **not** copy them wholesale — they read what they need and write project-specific equivalents.

## What you do NOT copy

- `agent-workshop/README.md`, `CLAUDE.md`, `AGENTS.md` — these govern the scaffold itself, not adopting projects. Each adopting project writes its own.
- `agent-workshop/docs/agents/`, `docs/skills/` — origin docs are reference, not adopted.
- `agent-workshop/docs/examples/` — read for understanding, don't copy.
- `agent-workshop/docs/conventions/` — read what you need; adopt selectively (see below).

## Adoption flow

### 1. Decide which agents and skills earn their keep

Read the origin doc for each agent and skill in `agent-workshop/docs/`. For each, ask:

- Does my project have the problem this agent or skill solves?
- Will I actually invoke it during normal work, or is it speculative?

If the answer is "no" or "not sure", omit it. The scaffold's discipline is "ship the smallest working version and let real use shape what stays" — applied to your project too. You can add more later.

A reasonable starter set for most projects:

- `wiki-maintainer` (most projects need this once docs accumulate)
- `doc-indexer` (worth it once `wiki-maintainer` starts loading for routing questions)
- `change-log` skill (paired with `wiki-maintainer`)
- `push` skill (universal)

Add `spec-reviewer` and `pattern-reviewer` once you adopt a spec-driven development loop. Add `vigil` and `agent-audit` only if you grow to multiple hosts or substantial agent-layer churn. Add `research` and the visual pair only if you have those workflows.

### 2. Copy the canonical specs

```powershell
# Example PowerShell
$src = "E:\dev\agent-workshop"
$dst = "E:\dev\<your-project>"

# Copy only the agents and skills you decided to adopt
Copy-Item -Path "$src\.claude\agents\wiki-maintainer.md" -Destination "$dst\.claude\agents\" -Recurse
Copy-Item -Path "$src\.claude\agents\doc-indexer.md" -Destination "$dst\.claude\agents\" -Recurse
Copy-Item -Path "$src\.claude\skills\change-log" -Destination "$dst\.claude\skills\" -Recurse
Copy-Item -Path "$src\.claude\skills\push" -Destination "$dst\.claude\skills\" -Recurse
```

Adapt the paths to your shell and OS.

### 3. Write your project's `CLAUDE.md` and `AGENTS.md`

Do **not** copy this scaffold's root `CLAUDE.md` and `AGENTS.md`. They govern the scaffold itself.

Your project's `CLAUDE.md` should cover:

- What the project is and what stage it's at.
- Where source-of-truth docs live (your project's docs/ structure).
- External documentation policy (Context7 default).
- Repo layout summary.
- Your domain's specifics (language, framework, build, test).
- Agent dispatch rules — pointing at the agents you copied.
- Documentation maintenance workflow.
- Scope discipline.

Your project's `AGENTS.md` is the host-agnostic counterpart, with workflow rules that fire during sessions inlined (not pointer-only).

The scaffold's `CLAUDE.md` and `AGENTS.md` are not templates for these — they are about maintaining the scaffold. The originating project's `CLAUDE.md` is a closer template if you want one, but it's tightly coupled to that project's domain.

### 4. Sanitize project-specific paths inside the agents and skills

The canonical specs in this scaffold are sanitized of project-specific names but reference *generic shapes* like:

- `docs/conventions/<domain>/` — your project picks the domain names
- `docs/conventions/docs/doc-routing.md` — write or skip
- `scripts/skill-parity.ps1` — write or skip
- `docs/superpowers/specs/`, `docs/superpowers/plans/`, `docs/superpowers/followups/` — adopt the structure or replace

For each agent / skill you copied:

1. Read it in your project's repo.
2. Find any path reference and decide: keep as-is (matches your project's structure), adapt to your project's path, or remove.
3. Write the supporting infrastructure the agent expects (the relevant convention doc, the scripts script, the directory structure).

### 5. Pick which conventions to adopt

Read `agent-workshop/docs/conventions/` and choose:

- **`reviewer-session-continuation.md`** — adopt if you have multi-round reviews (you almost certainly do).
- **`per-task-fresh-dispatches.md`** — adopt if you use subagent-driven development.
- **`skill-parity.md`** — adopt if you mirror skills across multiple hosts.
- **`doc-routing.md`** — adopt if you ship `doc-indexer` and want clear dispatch-vs-read-direct guidance.
- **`scripts-discipline.md`** — adopt if you have a `scripts/` directory with shared discipline expectations.

Write equivalents in your project's `docs/conventions/` rather than copying verbatim — the conventions reference your specific paths.

### 6. Add cross-host wrappers if you target multiple hosts

If your project will be used with Codex, Gemini, or OpenCode in addition to Claude Code, the scaffold's `.codex/agents/*.toml` files are worked examples of the **thin-wrapper** pattern — each points at `.claude/agents/<name>.md` as canonical with a brief scope summary and host-specific notes. Add Gemini and OpenCode wrappers using the same shape.

For skills, the convention is different: skills mirror in full across hosts (`.codex/skills/`, `.gemini/skills/`) because each host loads SKILL.md content directly.

The pattern is documented in [`docs/conventions/cross-host-wrappers.md`](conventions/cross-host-wrappers.md) for agent wrappers and [`docs/conventions/skill-parity.md`](conventions/skill-parity.md) for skill mirroring.

### 7. Use them

Adopt the agents and skills in your daily workflow. Watch which ones earn their keep over the next few weeks of real work.

### 8. Prune what doesn't earn its keep

If after 4–6 weeks an agent or skill hasn't been invoked in real work, remove it. Don't accumulate scaffold for the comfort of having it. The scaffold's discipline is "lived-in proof or nothing."

## A note on multi-project adoption

If you adopt this scaffold into multiple projects you own, you'll naturally diverge per project as each project's domain shapes the agents differently. Keep the *core shape* aligned across projects — same agent names, same role boundaries, same workflow rules — even when the project-specific paths differ. That cross-project consistency is one of the main reasons to start from a scaffold rather than re-deriving each time.

Updates flow back: when you discover a new pitfall or a refined workflow rule in one project, consider whether it generalizes back to this scaffold. The scaffold is meant to evolve with use.

## What this scaffold does NOT include

- `superpowers:*` skills (those live in the Superpowers framework).
- Any host's CLI itself.
- A test harness, CI, or build system.
- Domain-specific infrastructure (game engines, web frameworks, deployment tooling).
- An MCP server or any kind of running service.

The scope is *agent definitions, skills, origin docs, and portable conventions*.
