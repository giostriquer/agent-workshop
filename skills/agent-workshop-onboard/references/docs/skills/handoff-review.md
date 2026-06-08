# handoff-review

## Origin

A prompt the maintainer rewrote by hand at the end of nearly every branch: "give this a fresh, unbiased review before we open the PR — does the code match the task, does it follow our rules, did we leak anything." Written ad hoc, it drifted: different wording each time, the leak check sometimes dropped, the review sometimes run by the same session that wrote the code (the worst possible judge).

`handoff-review` formalizes that prompt into a self-contained review brief that a *different* agent or session runs.

## Problem

Two failure modes in the ad-hoc flow:

1. **Biased reviewer.** The implementing session "knows" the intent and reads it into the diff, so it confirms its own work. A genuinely fresh review has to re-derive the task from the ticket and the diff.
2. **Hollow task-vs-code check.** Handed only a ticket id, a fresh reviewer can't open it and silently falls back to reviewing commits alone — gutting the most important dimension.

## Solution shape

A brief generator, not a reviewer. It gathers branch + base + diff, identifies the ticket, and — critically — pulls the ticket's *acceptance criteria* into the brief (tracker fetch → operator paste → labeled "implementer's claim" fallback). The brief names four review dimensions (task-vs-code, rules conformance, information leak, correctness) and prescribes no tools. Two modes: spawn a fresh agent, or write the brief to a scratch file for a new session.

The load-bearing constraint: the brief stands alone. "Zero shared context" excludes the author's interpretation (the bias) but includes the ticket's ground truth (what the reviewer checks against).

## Real invocation snippet

> /handoff-review

Spawns a fresh reviewer with a brief built from the branch diff and the confirmed ticket's acceptance criteria.

> /handoff-review handoff

Writes the brief to `tmp/handoff-review-<branch-slug>.md` and prints it for copy-paste into a new session; spawns nothing. (`/handoff-review session` is an accepted alias.)

## Pitfalls observed

- **Letting the implementing session's paraphrase stand in for the ticket.** That paraphrase is exactly the bias being removed; it ships only under the explicit "implementer's claim, verify" label.
- **Naming tools in the brief.** The consuming agent owns tool choice. Naming `code-review` / `security-review` couples the brief to one session's toolset and defeats portability.
- **Treating it as a reviewer.** It produces the brief; it never reviews.

## Adaptation notes

- The four review dimensions are portable; the **rules / conventions** dimension points the reviewer at the repo's own `CLAUDE.md` / `AGENTS.md` / convention docs rather than restating rules, so it adapts to any project automatically.
- Ticket trackers vary (ClickUp / Linear / Jira). The substance-fetch step degrades gracefully when no tracker integration is present.
- The scratch path (`tmp/...`) is a default; point it at whatever scratch dir your project uses, and gitignore it.
