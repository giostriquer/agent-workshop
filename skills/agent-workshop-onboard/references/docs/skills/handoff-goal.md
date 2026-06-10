# handoff-goal

## Origin

The third handoff the maintainer kept writing by hand: not handing a finished branch *backward* to a reviewer (`handoff-review`) or a PR opener (`handoff-pr`), but handing work *forward* — "here's the goal, here's where we are, here are the working rules; new session, go pursue it." Written ad hoc, the doc carried the goal but lost the rules: preferences stated once in chat (commit style, push policy, PR target) made it into the file inconsistently, and nothing told the pursuing session what to do when its own context compacted mid-goal.

`handoff-goal` formalizes that forward handoff into a goal document a new session picks up and pursues autonomously.

## Problem

Three failure modes in the ad-hoc flow:

1. **Rules evaporate at compaction.** The pursuing session starts well, compacts, and the operating rules — which lived in its early context — are gone. Behavior drifts mid-goal: pushes that weren't approved, PRs to the wrong base, validation skipped.
2. **Invented rules.** A baseline test showed a model writing a handoff cold will pad the rules with constraints nobody stated ("never rebase") and present them as user-mandated — the pursuing session then over-constrains itself.
3. **Step list instead of outcome.** Without a definition of done, the pursuing session stops early or gold-plates; without an outcome framing it can't optimize the path when the listed steps turn out wrong.

## Solution shape

A document generator, not an executor. It resolves the goal from one of three sources — inferred from the session's trajectory (then confirmed), scoped to referenced existing work (a plan, slices, a spec), or shaped from a brand-new description (asking only what's needed to make it actionable). It re-derives current state from the repo rather than session memory, gathers operating rules (repo rule files + operator statements, asking for what's still open), and writes `tmp/<YYYY-MM-DD>-<goal-slug>.md`.

The document is a *living contract*: it opens by telling the pursuing session to re-read the operating rules after every compaction and to append decisions and landed work to a Progress section — the file, not session memory, is what persists across compactions and sessions. The goal is stated as an outcome with an explicit definition of done; the pursuing session owns and may optimize the path.

## Real invocation snippet

> /handoff-goal

Infers the goal from the session (the active plan, the work in progress), confirms it with the operator, and writes the goal document.

> /handoff-goal slices 3-9 of the relay-sync plan

Scopes the goal to exactly those slices, reading the plan file rather than recalling it.

> /handoff-goal I want a CLI that mirrors issue comments between two trackers...

No plan exists; asks only what's needed to make the goal actionable, then shapes it into the document.

## Pitfalls observed

- **Vague rules.** "Follow the usual conventions" survives compaction as nothing. Rules carry concrete values — the actual branch, the actual PR target — each sourced from a repo rule file or the operator.
- **Invented rules.** The baseline failure above. If neither the repo nor the operator stated it, it doesn't go in the document.
- **Treating it as an executor.** It writes the document; pursuing the goal belongs to the new session. Starting the work in the producing session defeats the handoff.
- **Restating the plan.** The document links to plan / spec files; copying their content in creates a second source of truth that goes stale.

## Adaptation notes

- The operating-rules categories (branch / commits / push-PR / validation / scope) are portable; the *values* come from each project's own rule files and operator, so the skill adapts automatically.
- The scratch path (`tmp/...`) is a default; point it at whatever scratch dir your project uses, and gitignore it.
- Pairs naturally with its siblings: pursue the goal, then `handoff-review` for a fresh-eyes review, then `handoff-pr` to package the PR.
