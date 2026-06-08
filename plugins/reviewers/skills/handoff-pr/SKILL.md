---
name: handoff-pr
description: Use when a branch is ready for a PR but the current session is not authorized to open one. Produces a structured PR handoff artifact (title, body, ticket links, validation and review status) for a separately-authorized session or agent to open. Auto-detects the ClickUp / Linear / Jira ticket and asks to confirm. Never opens the PR itself.
---

# Handoff PR

Package a finished branch into a **structured PR artifact** that a separately-authorized session or agent opens. This skill produces the artifact; it **never** runs `gh pr create`.

## When to use

The work is ready for a PR, but the current session does not hold PR-write authorization (or you deliberately want a clean, authorized session to open it). Hand it off instead of opening it here.

## The one rule that makes this work

The artifact must **stand alone**. A separately-authorized session opens the PR with no access to this session, so every field — summary, ticket, status — is re-derived from the **branch diff and the ticket**, never from "what we discussed this session."

## Steps

1. **Detect branch and base.** Run `git branch --show-current` and determine the base branch (default `main` unless the repo says otherwise). Summarize the change from `git diff <base>...HEAD` and the commit list — do not rely on session memory.
2. **Identify the ticket.** Scan the branch name, commit messages, and any existing PR description for a ClickUp / Linear / Jira id or URL. Present what you found and ask the operator to confirm or supply the right one. If none is found, ask. Capture the full ticket **link**, not just the id; if only an id is available, ask the operator for the full URL — do not synthesize one.
3. **Capture status fields:**
   - **Validation / tests:** what was run and the result (or "not run").
   - **Review:** whether a `handoff-review` pass ran and its outcome; link the findings if available. Do not block on it — record honestly if no review ran.
4. **Assemble the artifact** using the template below.
5. **Deliver:** print the artifact inline. Also write it to `tmp/handoff-pr-<branch-slug>.md` (sanitize the branch name: `/` → `-`) and report the path, so the authorized session can read it.
6. **Stop.** State plainly that opening the PR is the authorized session's job: it runs `gh pr create` with the title and body below. Do not run it.

## The PR artifact template

> **PR handoff — `<branch>` → `<base>`**
>
> **Title:** `<conventional-style subject, e.g. feat: ...>`
>
> **Body:**
>
> ## Summary
> `<what changed and why, grounded in the diff>`
>
> ## Ticket
> `<ClickUp / Linear / Jira link(s)>`
>
> ## Validation
> `<tests / checks run and results, or "not run">`
>
> ## Review
> `<handoff-review outcome + link, or "no review run">`
>
> ## Caveats / follow-ups
> `<anything the reviewer / merger should know; "none" if none>`
>
> **To open:** an authorized session runs `gh pr create --base <base> --head <branch>` with the title and body above.

## Rules

- Never run `gh pr create` (or any PR-opening command) — produce the artifact only.
- Always carry a real ticket link; if you cannot find or confirm one, ask rather than omit it.
- Ground the summary in the actual diff, not session memory — the artifact may be opened by a session with no shared context.
