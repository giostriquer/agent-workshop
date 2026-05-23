# Agent Marketplace

The marketplace is the catalog view of `agent-workshop`: it groups the canonical
agents into adoption packs, names the profile values an adopting project must
fill, and keeps raw copy decisions out of guesswork.

The canonical data lives in [`marketplace/catalog.json`](../../marketplace/catalog.json).
The docs in this directory explain how to read and apply that catalog.

For Claude Code and Codex, the preferred guided path is the native plugin
described in [`native-plugin.md`](native-plugin.md). It exposes only
`agent-workshop-onboard`; `mode: plan` is read-only by default, and `mode: apply`
writes only an explicitly approved project-local file set.

## Start here

1. Use the native plugin when Claude Code or Codex is available, or use this
   guide manually for other hosts.
2. Pick one or more packs from [`packs.md`](packs.md).
3. Read the origin docs for the agents in each selected pack.
4. Fill the relevant profile slots from [`agent-profiles.md`](agent-profiles.md)
   in the adopting project's `CLAUDE.md`, `AGENTS.md`, and convention docs.
5. Copy the canonical agent specs and host wrappers for the selected agents, or
   approve `agent-workshop-onboard` `mode: apply` after reviewing its exact file
   set.
6. Copy required skills separately when an agent depends on a skill-owned
   workflow, or include them in the approved plugin plan.
7. Use the pack in real work, then prune anything that does not earn its keep.

## Marketplace principles

- Canonical agents stay generic.
- Project-specific policy lives in profiles.
- Packs are adoption bundles, not mandatory tiers.
- High-authority or specialized agents require explicit opt-in.
- The catalog is manifest-first; the native plugin is a guided onboarding layer,
  not a global installer for every scaffold agent.

## What the marketplace does not do

- It does not install files automatically without an approved `mode: apply` plan.
- It does not move canonical specs out of `.claude/agents/`.
- It does not make all agents default.
- It does not encode private project paths or local domain decisions.
