# handoff-pr

## Origin

The other half of the end-of-branch prompt: "open a PR on our behalf with the right ticket links." Often the implementing session is not the one authorized to open the PR, so the work has to be packaged and handed to a session that is. Done by hand, the ticket link got forgotten, the body drifted from the diff, the review status went unrecorded — and the body ignored the repo's own PR template, so the PR didn't match the sections and checklist the team expected.

`handoff-pr` formalizes that into a structured PR artifact a separately-authorized session opens.

## Problem

Four failure modes in the ad-hoc flow:

1. **Unauthorized opener.** The session that wrote the code cannot open the PR; the context has to travel to one that can.
2. **Missing ticket link.** Hand-written PR bodies dropped the ClickUp / Linear / Jira link, breaking traceability.
3. **Session-memory drift.** The summary described what the author remembered doing, not what the diff actually changed.
4. **Reinvented body.** Hand-written bodies ignored the repo's `pull_request_template.md`, so the PR was missing the checklist the team asked for and carried sections the team never wanted — and handoff bookkeeping (validation provenance, review status) leaked into the public description.

## Solution shape

An artifact generator, not a PR opener. It detects branch + base, summarizes from the real diff, auto-detects and confirms the ticket link, and — before assembling anything — looks for the repo's own PR template. When one exists, the PR body *is* that template filled in verbatim (headings, order, checkboxes, and `<!-- markers -->` preserved); otherwise it falls back to a built-in Summary / Ticket / Caveats structure. The artifact is two visibly separate blocks: a paste-ready **PR body** (the only part that goes in the PR description) and **handoff notes** that carry the opener-only fields — which template was chosen, validation provenance, review status, and the `gh pr create` command — so process fields never leak into the public PR. It prints the artifact and writes it to a scratch file. It explicitly never runs `gh pr create` — that is the authorized session's job.

## Real invocation snippet

> /handoff-pr

Finds the repo's PR template, builds the PR body to its shape (or the built-in fallback), confirms the ticket, writes `tmp/handoff-pr-<branch-slug>.md`, and stops short of opening the PR.

## Pitfalls observed

- **Opening the PR anyway.** The skill is artifact-only by design; the current session lacks authorization. Running `gh pr create` defeats the handoff.
- **Reinventing the body.** When the repo ships a PR template, the body must be that template filled in — not a parallel set of sections the team didn't ask for. Don't add, drop, or rename its sections.
- **Leaking process fields.** Validation provenance and review status are handoff bookkeeping; pasted into the public PR body they read as noise and can expose internal scratch paths. They live in the opener-only notes.
- **Summarizing from memory.** The artifact may be opened by a session with no shared context, so the summary must come from the diff.
- **Omitting the ticket when none is auto-detected.** Ask for it rather than shipping a PR with no traceability.

## Adaptation notes

- The body shape is no longer hardcoded — it follows the repo's PR template when one exists (root / `.github/` / `docs/`, including a `PULL_REQUEST_TEMPLATE/` directory of named variants, matched case-insensitively). The built-in Summary / Ticket / Caveats structure is only the fallback. Adjust template detection if your host honors other locations.
- When multiple templates exist (default vs `hotfix` / `release`), selection is by branch name / change intent; tune that heuristic to your branching model.
- Ticket detection scans branch / commits / PR description; adjust the patterns to your tracker's id format.
- Pairs with `handoff-review`: the **Review status** field (in the opener-only notes, not the public body) records that outcome. The coupling is light — `handoff-pr` does not enforce that a review ran.
