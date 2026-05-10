# Reviewer Session Continuation

## Rule

Multi-round review loops continue the **same reviewer session** across rounds. Do not respawn a fresh reviewer per round.

This applies to:

- `spec-reviewer` (multi-round until PASS on the same spec or plan)
- `pattern-reviewer` (revision rounds on the same task's diff)
- `wiki-maintainer` audit mode (multi-round audit on the same scope)
- `vigil` same-audit re-review (same target, scope, mode)
- `visual-implementer` same visual task across iterations (same asset slot or surface)

## Why

Two reasons:

1. **Cost.** Re-reads of the spec / plan / source files / convention docs cost real context tokens. Re-paying that cost on every round is wasteful and adds latency.
2. **Findings continuity.** Prior findings live in the reviewer's session context. Respawning loses them — the new reviewer can't do a delta walk against findings it never saw.

The "fresh eyes" rule that governs the *first* round (the reviewer should not inherit the author's context) does not extend across revision rounds. Once the reviewer has read the artifact, that reading is the durable cross-round anchor.

## Mechanism

The orchestrator (the model that dispatched the reviewer) uses the host's session-resume mechanism to continue the same agent session across rounds. From the reviewer's side, this looks like a natural follow-up turn — the reviewer trusts its own session context.

In Claude Code with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, this is `SendMessage` to the agent's name or ID. In other hosts, the equivalent mechanism applies (some hosts call this "resume", "continue", or similar).

**Spawn the reviewer with an explicit `name` parameter** (e.g. `name: 'spec-reviewer-<topic-slug>'`) so subsequent rounds can address it via name. Without a name, only ID-based addressing is available — still functional but more fragile across long sessions.

## Caveat: continuation can fail

`SendMessage` (or the host's equivalent) occasionally fails to wake the prior agent. Verify resumption took effect before continuing the round.

If continuation fails:

1. **Try addressing the agent by its agent ID** (returned at spawn time as `agentId: <hash>`) before falling back. Name-based addressing can become invalid while the agent ID still resolves.
2. **Only spawn a fresh reviewer when both name- and ID-based addressing fail.** The prior findings will be lost; carry them as context manually.
3. **Per-round fallback only** — continuation failure on round N does not mean rounds N+1, N+2 must also spawn fresh. Each round attempts continuation against the most-recent agent independently.

## Anti-pattern: cross-task SendMessage-resume

This rule applies to **revision rounds on the same artifact**, not to reuse across different tasks.

Each new task's review is a fresh dispatch. Resuming a prior task's reviewer on a new task's diff is the **cross-artifact mistake** — the prior task's context becomes context rot in the new review.

The harness response `"Agent X had no active task; resumed from transcript"` when you SendMessage to a prior task's reviewer is the signal you've made this mistake. Kill that resumed session and dispatch fresh.

For more on this, see [per-task-fresh-dispatches.md](per-task-fresh-dispatches.md).

## Anti-pattern: cross-mode SendMessage-resume on the same agent

`spec-reviewer` runs once on the spec (one session, multi-round until PASS) and **once on the plan as a separate fresh dispatch** — different artifact, even though the same agent definition. Do not SendMessage-resume the spec-mode session for plan review; that carries spec-mode context as context rot.

Same principle for any agent with multiple modes operating on different artifacts.

## In your project's docs

Adopt this rule by writing a project-specific equivalent under `docs/conventions/reviewer-session-continuation.md` (or wherever your conventions live). Reference your specific host's resume mechanism. Reference the failure mode you've actually observed (the originating project observed `SendMessage` flakiness; your project may have different host quirks).

The shape that matters: **same artifact, multi-round → same session; new artifact → fresh dispatch; failure → fallback by ID first, fresh spawn only as last resort.**
