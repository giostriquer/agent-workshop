# get-pr-comments

## Origin

PR feedback arrives scattered across three surfaces — the conversation tab, review
summaries, and inline comments pinned to diff lines — and reading it in the GitHub
UI to figure out "what do I actually have to change" is slow and easy to do
incompletely. `get-pr-comments` collapses that into one pass: it pulls all three
via `gh`, groups the feedback by how much it matters and how actionable it is, and
hands back a prioritized action list plus the questions still waiting on a human.

The load-bearing design choice is a **boundary, not a feature**: the skill reads and
summarizes, and it must **not** reply to, resolve, or react to any comment unless the
operator explicitly asks. Summarizing feedback and *answering* it are different acts
with different stakes — auto-replying on someone's PR is exactly the kind of
outward-facing action that should never happen as a side effect of "show me the
comments."

## Problem

Triaging PR feedback by hand has predictable failure modes:

1. **Scatter.** Conversation comments, review verdicts, and inline diff comments live
   in different places; reading one and missing another is easy.
2. **Flat priority.** A blocking change-request and a nit read the same in a long
   thread until you sort them — and the thing you most need is "what blocks merge."
3. **Questions buried as comments.** Some feedback isn't a change to make but a
   question to answer; treating it as a checkbox loses the fact that a human is
   waiting on you.
4. **Over-reach.** A tool that can fetch comments can also *post* them — and an agent
   that helpfully replies to reviewers without being asked creates outward-facing
   noise (or worse) on a shared PR.

## Solution shape

A small, self-contained, **read-only** triage skill:

- **One pass, all surfaces.** Resolve the active PR, then fetch conversation
  comments + review summaries (`gh pr view --json comments,reviews`) and inline diff
  comments (`gh api .../pulls/<n>/comments`).
- **Grouped, prioritized.** Sort by severity (blocking / should-fix / nit) and
  actionability (clear change vs. open question); return an action list ordered by
  priority.
- **Questions surfaced separately.** Open questions that need a human answer are
  called out, not folded into the action checklist.
- **Hard no-reply boundary.** It never replies, resolves, reacts, or comments unless
  the operator explicitly asks for that specific action. Reading ≠ responding.
- **Self-contained.** Just `gh` against the current branch's PR — no project profile,
  so it ships **direct-use in the `toolkit` plugin**, not the onboarding set.

## Real invocation snippet

> /get-pr-comments

Resolves the branch's PR, pulls conversation + review + inline comments, and returns
a severity-grouped action list with the open questions split out — without touching
the PR. Replying to any of it is a separate, explicit instruction.

## Pitfalls observed

- **Replying unbidden.** The whole point of the boundary: never post, resolve, or
  react to a comment as a side effect of summarizing. Wait for an explicit ask.
- **Reading only the conversation tab.** Inline diff comments and review verdicts are
  separate API surfaces; miss them and the summary is wrong.
- **Flattening severity.** A summary that doesn't separate blocking from nit doesn't
  save the reader the triage they came for.
- **Losing the questions.** Feedback phrased as a question is a different obligation
  than a change request; keep them distinct.

## Adaptation notes

- Assumes **GitHub + `gh`**. For another review host, swap the fetch commands for that
  host's API; the group-by-severity-and-actionability shape is host-agnostic.
- The severity buckets (blocking / should-fix / nit) are a sensible default — adjust
  the labels to match how your team triages.
- Keep it read-only. A variant that *posts* replies is a different, higher-authority
  tool and should be opted into explicitly, never merged into the summarizer.
