# Cross-Host Agent Wrappers

## Rule

When a project supports multiple agent-capable CLIs (Claude Code, Codex, Gemini, OpenCode), the **canonical agent specs live in `.claude/agents/`** and other hosts use **thin wrappers** that point at the canonical file.

- Canonical: `.claude/agents/<name>.md` — the full spec.
- Codex wrapper: `.codex/agents/<name>.toml` — pointer + minimal scope summary.
- Gemini wrapper: `.gemini/agents/<name>.md` — pointer + minimal scope summary.
- OpenCode wrapper: `.opencode/agents/<name>.md` — pointer + minimal scope summary.

This is different from how skills work. **Skills mirror in full** (see [skill-parity.md](skill-parity.md)) because each host loads SKILL.md content directly. **Agents wrap thin** because non-Claude hosts can be instructed to read the Claude canonical at session start, and this avoids the maintenance burden of keeping multi-hundred-line agent specs in sync across hosts.

## Why thin wrappers, not full-copy mirrors

Three reasons:

1. **Single source of truth.** Update once in `.claude/agents/<name>.md`; every host picks up the change on their next session start. No fan-out commits, no cross-host drift between updates.
2. **Smaller surface to keep in sync.** A 30-line wrapper is easy to audit; a 300-line full copy is not. The chance of leaking an unintended divergence drops sharply.
3. **The canonical spec is the working contract.** Treating Claude as canonical is not because Claude is "first-class" — it's because the spec format (Markdown with YAML frontmatter) is what agents in any host can read directly. The thin wrapper reduces every other host's job to "adopt this canonical and translate any host-specific dispatch wiring."

A full-copy approach is reasonable when the canonical spec doesn't load reliably for a given host (e.g., a host that doesn't read sibling files at session start). When that happens, document the divergence and run periodic parity audits (`vigil` mode `wrappers`) to catch drift.

## Wrapper shape: Codex

A Codex wrapper is a `.toml` file with `description` and `developer_instructions` fields. The `developer_instructions` block reads the Claude canonical and adds a brief scope summary plus host-specific notes:

```toml
name = "<agent-name>"
description = "<one-line description matching the canonical spec's frontmatter>"

developer_instructions = """
You are the <agent-name> wrapper for this project.

Your canonical specification lives at:
`.claude/agents/<agent-name>.md`

Read that file before acting and treat it as the source of truth for the role's behavior, boundaries, workflow, and output expectations.

## Quick scope

- <3-6 bullets summarizing what the agent does, in plain language>
- <Just enough for a Codex session to recognize whether this is the agent it needs without reading the full canonical>

## Codex notes

- <Any host-specific dispatch wiring or sandbox / model preferences>
- <Behaviors that diverge from the canonical because of Codex specifics>
"""
```

Optional frontmatter fields you may add per project:

- `model = "<codex-model>"` — pin a specific Codex model
- `model_reasoning_effort = "high" | "xhigh"` — reasoning budget
- `sandbox_mode = "workspace-write"` — Codex sandbox preference

This scaffold's `.codex/agents/*.toml` files leave those off so adopters set them per project.

## Wrapper shape: Gemini

A Gemini wrapper is a `.md` file with YAML frontmatter and a body:

```markdown
---
name: <agent-name>
description: <one-line description>
tools:
  - read_file
  - grep_search
  - glob
  - run_shell_command
  - replace
  - write_file
  - list_directory
model: gemini-3.1-pro-preview
---

# <Agent Name> (Wrapper)

You are the <agent-name> wrapper for this project.

**CRITICAL:** Before performing any work, you **MUST** read your canonical specification at:
`.claude/agents/<agent-name>.md`

Treat that file as the absolute source of truth for your behavior, boundaries, workflow, and output expectations.

## Quick scope

<Same 3-6 bullets as the Codex wrapper>

## Gemini notes

<Any Gemini-specific dispatch wiring or tool-mapping notes>
```

The Gemini frontmatter includes a `tools` list that maps to Gemini's tool naming. The CRITICAL pointer is what lifts the canonical content into the session.

## Wrapper shape: OpenCode

OpenCode wrappers follow the same Markdown + frontmatter pattern as Gemini, with OpenCode-specific tool naming.

OpenCode is wrapper-only by convention in some projects — agents are wrapped, but skills are not mirrored to `.opencode/skills/`. Decide per project; document the choice in your skill-parity manifest.

## Required scope summary (the "Quick scope" block)

Even though the canonical does the real work, every wrapper carries a brief scope summary in `## Quick scope`. Why:

- A model loading the wrapper hits the scope summary first. If the agent is the wrong tool for the current question, the model can recognize that without spending tokens on the full canonical.
- The summary is a **contract sanity check.** If the canonical's behavior drifts from what the summary claims, the next person reading the wrapper notices.
- The summary is the wrapper's primary maintenance burden. Keep it under 6 bullets.

## Maintenance

- **Canonical changes propagate automatically.** Edit `.claude/agents/<name>.md`; the wrappers' canonical pointers pick up the change next session.
- **Wrapper-only changes** are rare and should be limited to host-specific dispatch wiring or scope-summary updates that reflect canonical changes. Unauthorized wrapper-only divergences are drift; the `vigil` agent in `wrappers` mode catches them.
- **Adding a new agent** to the project: write the canonical at `.claude/agents/<name>.md`, then add wrappers for each supported host. The wrapper pattern above keeps the addition cheap.
- **Removing an agent:** delete the canonical AND every wrapper. A leftover wrapper pointing at a non-existent canonical is a confusing landmine for adopters.

## When to use full-copy mirrors instead

Sometimes the thin-wrapper pattern doesn't work cleanly:

- The host doesn't reliably load sibling files at session start.
- The host's instruction format diverges so much from the canonical that the translation overhead exceeds the maintenance cost of a full copy.
- A specific agent needs heavy host-specific re-shaping that's awkward to express as wrapper notes.

In those cases, accept the full copy and document the divergence per the [skill-parity convention](skill-parity.md). Run periodic `vigil wrappers` audits to catch drift between the full-copy mirror and the canonical.

## In your project's docs

Adopt this convention with a project-specific equivalent at `docs/conventions/cross-host-wrappers.md` if you support multiple hosts. Reference your project's canonical-host choice (Claude is the common default; some projects make Codex canonical instead — both work).

If your project supports only one host, this convention doesn't apply. Skip it.

## Anti-pattern: full-copy mirrors out of habit

The fastest way to set up multi-host agents is to copy the canonical content into every host's wrapper. It works on day 1 and quietly creates a mountain of cross-host drift by month 3. Resist this — pay the small thin-wrapper authoring cost upfront and the maintenance cost stays bounded.

If you discover an existing project has full-copy mirrors that should be thin wrappers, the conversion is mechanical:

1. Strip everything from `developer_instructions` (or the wrapper body) except a 6-bullet scope summary.
2. Add the canonical pointer at the top.
3. Add a `## Codex notes` (or `## Gemini notes`, etc.) block for host-specific divergences only.
4. Run a `vigil wrappers` audit to confirm the wrapper now matches the canonical's actual behavior.

The agents in this scaffold's `.codex/agents/` are the worked example of thin-wrapper shape. Use them as templates.
