---
name: handoff-review
description: Use when implementation on a branch is done (or mid-way) and you want a fresh, unbiased review before opening a PR. Produces a self-contained review brief (task-vs-code, rules conformance, information leak, correctness) for a separate agent or session to run. Default mode spawns a fresh reviewer; handoff mode (`handoff-review handoff`, alias `session`) writes the brief to a scratch file for a new session.
---

# Handoff Review

Produce a **self-contained, unbiased review brief** for a separate agent or session to run before a PR is opened. This skill writes the brief; it does **not** perform the review and does **not** prescribe which tools the reviewer uses — tool choice belongs to whoever picks up the brief.

## When to use

Implementation on a branch is done, or far enough along, and you want a fresh pair of eyes before opening a PR: confirming the code matches the task, conforms to the repo's rules, leaks nothing, and is correct.

## The one rule that makes this work

The brief must **stand alone**. A reviewer who shares this session's context inherits its blind spots, so the brief re-derives the task from the **ticket + diff**, never from "what we discussed this session."

"Stand alone" cuts one way only: exclude the implementing session's *interpretation* of the task (that is the bias being removed), but **include the ticket's acceptance criteria** (the ground truth the reviewer judges against). Those are different inputs — drop the first, carry the second.

## Steps

1. **Detect branch and base.** Run `git branch --show-current` and determine the base branch (default `main` unless the repo says otherwise). Capture the diff range with `git diff <base>...HEAD --stat` and the commit list.
2. **Identify the ticket.** Scan the branch name, commit messages, and any existing PR description for a ClickUp / Linear / Jira id or URL. Present what you found and ask the operator to confirm or supply the right one. If none is found, ask.
3. **Get the ticket's substance, not just its link** — this is what makes the task-vs-code check real:
   - If a tracker integration is reachable (ClickUp / Linear / Jira MCP, or web access to the ticket URL), fetch the ticket body / acceptance criteria and embed it verbatim in the brief.
   - Else, ask the operator to paste the acceptance criteria.
   - Else, write a short task summary and label it explicitly **"implementer's claim — verify against the actual ticket."** Never present a session-derived paraphrase as ground truth.
4. **Assemble the brief** using the template below. It names *what* to review, never *how* — no tool or skill names.
5. **Deliver by mode:**
   - **default (spawn):** dispatch a fresh agent (the host's general-purpose agent) with the brief as its entire prompt — no session history — and return its findings.
   - **handoff** (invoked as `handoff-review handoff` or `handoff-review session`): write the brief to `tmp/handoff-review-<branch-slug>.md` (sanitize the branch name: `/` → `-`), tell the operator the path, and print the brief for copy-paste into a new session. Do not spawn an agent.

## The review brief template

> **Review brief — `<branch>` vs `<base>`**
>
> **Task (from ticket `<id / url>`):**
> `<acceptance criteria, verbatim from the ticket — or, if unavailable, the labeled "implementer's claim, verify against the ticket" summary>`
>
> **Diff scope:** `<files / stat summary>` — see it with `git diff <base>...HEAD`.
>
> **Review the following, forming your own judgment from the diff — do not trust any summary above:**
> 1. **Task vs. code** — does the diff actually deliver the acceptance criteria? Call out anything asked-for-but-missing and anything done-but-not-asked.
> 2. **Rules / conventions** — read this repo's own `CLAUDE.md` / `AGENTS.md` / convention docs and check the diff against them. (This brief does not restate the rules; read them.)
> 3. **Information leak** — secrets / keys / tokens, internal hostnames or absolute paths, and private domain content that should not ship.
> 4. **Correctness / quality** — bugs, missing error handling, untested risk.
>
> **Report:** findings grouped by severity (blocker / major / minor / nit), each with `file:line` and a concrete fix, then an overall **go / no-go**.

## Rules

- Never run the review yourself; never name tools or skills for the reviewer to use.
- Never let the implementing session's interpretation stand in for the ticket's acceptance criteria.
- The brief must be readable with zero access to this session.
