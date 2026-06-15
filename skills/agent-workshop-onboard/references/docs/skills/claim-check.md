# claim-check

## Origin

A prompt the maintainer rewrote by hand almost daily: hand a session a ticket
from an earlier audit and say, in some new phrasing each time, *"don't assume
this is still true — a previous investigation is done, but the scope may be
stale; spawn agents, never assume, if you're unsure search; and the ticket being
right is a perfectly good answer, we just have to know."* The intent never
changed; the wording drifted every time, and the two halves of the ask — *is it
still true?* and *can we actually tackle it?* — got tangled together differently
on each run.

`claim-check` formalizes that prompt into one repeatable investigation.

## Problem

Three failure modes in the ad-hoc flow:

1. **Trusting a stale premise.** The code moves and tickets age. A premise from
   last quarter's audit may be fully or partly fixed by a merged PR nobody linked
   back to the ticket — and acting on it wastes the work.
2. **Biased toward "the ticket is wrong."** Told to "double-check," a session
   often sets out to *refute*, and over-reports staleness. Confirming the premise
   is the better outcome when it is true; the investigation has to be genuinely
   two-sided.
3. **A verdict you can't act on.** Even a correct "yes, still valid" is useless if
   the session then has no idea where to start. The two questions — *true?* and
   *workable?* — must both be answered, separately.

## Solution shape

A run-it-now investigation, not a brief generator (it is the opposite of the
`handoff-*` skills in that respect). It resolves a premise from any source — a
ticket is the richest and primary case, but a hunch or a bare question works too
— decomposes it into atomic claims, and checks each against the current repo.
Fan-out is recommended for code and doc scanning but not mandated; the main
session orchestrates and keeps subagent briefs neutral and evidence-returning so
the search doesn't drift. It scans for prior or parallel work the premise can't
see, adversarially re-checks both "confirmed" and "obsolete" conclusions, and
returns a **two-axis output**: a validity verdict with evidence, plus a readiness
dossier (or exactly what's missing) when the premise is actionable. It stops
there — it never implements the work.

The load-bearing constraint: every claim is a hypothesis checked against
evidence, never assumed in either direction. "It still holds" and "already
handled" are equally good outcomes — the evidence decides.

For a fuzzy input (a hunch, not a ticket) there is one extra gate: articulate the
premise into concrete claims and confirm them with the operator *before*
searching. Without it, a vague input yields a vague investigation.

## Real invocation snippet

> /claim-check https://tracker/…/CHAR-1234

Fetches the ticket's substance, decomposes its claims, investigates each against
the repo, and returns the verdict + dossier. The ticket being correct is a clean
result — followed by the dossier needed to work it.

> /claim-check I think our drive-item path resolver double-fetches children

No structured claims yet: the skill first restates this as atomic claims
("resolver calls children endpoint twice for nested paths", "the second call is
uncached"), confirms them with the operator, then investigates.

## Pitfalls observed

- **Leading subagent briefs.** "Confirm endpoint X is missing" biases the
  subagent toward the answer. Briefs ask "what does X do?" and return evidence,
  not a verdict to rubber-stamp.
- **Skipping the prior-work scan.** The most common reason a valid-looking premise
  is actually obsolete is a merged PR or sibling ticket — invisible unless you go
  look for it.
- **Stopping at the verdict.** A `confirmed` premise that is also
  `confirmed-but-blocked` needs the blocker surfaced; a `confirmed` premise that's
  ready needs the start-here dossier. The verdict alone isn't the deliverable.
- **Drifting into implementation.** Once the premise checks out, it is tempting to
  just start. That's a separate step the operator owns; the skill hands back.

## Adaptation notes

- The substance-fetch step degrades gracefully across trackers (ClickUp / Linear
  / Jira) — integration if present, operator paste otherwise — the same pattern
  `handoff-review` uses.
- The five-bucket verdict taxonomy (`confirmed` · `partially-confirmed` ·
  `refuted/obsolete` · `mis-scoped` · `confirmed-but-blocked`) is portable; rename
  to match how your team talks about outcomes.
- The artifact is in-chat by default; point the optional persisted copy at
  whatever docs home or scratch dir your project uses, and gitignore the scratch
  path.
- Pairs naturally with `handoff-goal`: when a `confirmed` premise is ready to
  work, the dossier feeds straight into a goal handoff for a fresh session.
