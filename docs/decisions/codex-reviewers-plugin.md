# Decision: add Codex reviewers plugin counterpart

**Date:** 2026-06-08

## Status

Accepted.

## Context

The Claude Code marketplace ships `reviewers`, a direct-use plugin with four
standalone review agents and two handoff skills. The Codex marketplace initially
shipped only the `agent-workshop` onboarding plugin.

Current Codex plugin packaging supports skills, apps, and MCP servers. Codex
custom agents are loaded as `.codex/agents/*.toml` project or personal files,
not as plugin manifest entries.

## Decision

Add a Codex manifest and marketplace entry for the existing `reviewers` plugin.

It packages:

- `handoff-review` and `handoff-pr` as active Codex skills from the existing
  `plugins/reviewers/skills/` payload.
- `spec-reviewer`, `test-quality-reviewer`, `pattern-reviewer`, and `vigil` as
  bundled top-level agent files for Claude Code and reference, not as active
  Codex plugin agents.

The existing Claude Code `reviewers` payload stays shared. Claude Code continues
to expose those roles as active plugin agents; Codex exposes only the skills that
its plugin manifest supports.

## Consequences

- Codex users can install review workflows from the same `agent-workshop`
  marketplace on a separate machine with `codex plugin add
  reviewers@agent-workshop`.
- The Codex package is skill-based, not a standalone custom-agent package.
- Users who need true Codex subagent files still use `agent-workshop-onboard` to
  copy `.codex/agents/*.toml` wrappers into the target repo.
