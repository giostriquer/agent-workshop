# Agent Marketplace

The marketplace is the catalog view of `agent-workshop`: it groups the canonical
agents into adoption packs, names the profile values an adopting project must
fill, and keeps raw copy decisions out of guesswork.

The canonical data lives in [`marketplace/catalog.json`](../../marketplace/catalog.json).
The docs in this directory explain how to read and apply that catalog.

## Start here

1. Pick one or more packs from [`packs.md`](packs.md).
2. Read the origin docs for the agents in each selected pack.
3. Fill the relevant profile slots from [`agent-profiles.md`](agent-profiles.md)
   in the adopting project's `CLAUDE.md`, `AGENTS.md`, and convention docs.
4. Copy the canonical agent specs and host wrappers for the selected agents.
5. Copy required skills separately when an agent depends on a skill-owned workflow.
6. Use the pack in real work, then prune anything that does not earn its keep.

## Marketplace principles

- Canonical agents stay generic.
- Project-specific policy lives in profiles.
- Packs are adoption bundles, not mandatory tiers.
- High-authority or specialized agents require explicit opt-in.
- The catalog is manifest-first, but no installer is implied yet.

## What the marketplace does not do

- It does not install files automatically.
- It does not move canonical specs out of `.claude/agents/`.
- It does not make all agents default.
- It does not encode private project paths or local domain decisions.
