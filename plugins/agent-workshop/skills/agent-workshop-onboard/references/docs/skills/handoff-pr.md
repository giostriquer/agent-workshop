# handoff-pr

## Origin

The other half of the end-of-branch prompt: "open a PR on our behalf with the right ticket links." Often the implementing session is not the one authorized to open the PR, so the work has to be packaged and handed to a session that is. Done by hand, the ticket link got forgotten, the body drifted from the diff, and the review status went unrecorded.

`handoff-pr` formalizes that into a structured PR artifact a separately-authorized session opens.

## Problem

Three failure modes in the ad-hoc flow:

1. **Unauthorized opener.** The session that wrote the code cannot open the PR; the context has to travel to one that can.
2. **Missing ticket link.** Hand-written PR bodies dropped the ClickUp / Linear / Jira link, breaking traceability.
3. **Session-memory drift.** The summary described what the author remembered doing, not what the diff actually changed.

## Solution shape

An artifact generator, not a PR opener. It detects branch + base, summarizes from the real diff, auto-detects and confirms the ticket link, and records validation + review status into a structured body. It prints the artifact and writes it to a scratch file. It explicitly never runs `gh pr create` — that is the authorized session's job.

## Real invocation snippet

> /handoff-pr

Builds the PR artifact, confirms the ticket, writes `tmp/handoff-pr-<branch-slug>.md`, and stops short of opening the PR.

## Pitfalls observed

- **Opening the PR anyway.** The skill is artifact-only by design; the current session lacks authorization. Running `gh pr create` defeats the handoff.
- **Summarizing from memory.** The artifact may be opened by a session with no shared context, so the summary must come from the diff.
- **Omitting the ticket when none is auto-detected.** Ask for it rather than shipping a PR with no traceability.

## Adaptation notes

- The artifact body sections (Summary / Ticket / Validation / Review / Caveats) are portable; trim or extend to match your PR template.
- Ticket detection scans branch / commits / PR description; adjust the patterns to your tracker's id format.
- Pairs with `handoff-review`: the **Review** field records that outcome. The coupling is light — `handoff-pr` does not enforce that a review ran.
