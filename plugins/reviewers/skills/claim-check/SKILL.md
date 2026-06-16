---
name: claim-check
description: Use when you have a premise to verify before acting on it — most often a tracker ticket, but also a hunch you are carrying or a bare question — and you want an unbiased, evidence-grounded investigation rather than a guess. Checks each claim against the current repo (the premise still holding is a fine outcome, not a failure), scans for work that already addressed it, and returns a validity verdict with evidence plus, if it is actionable, a readiness dossier (where to start, gotchas, dependencies) — or exactly what is missing. Never implements the work; stops at the verdict + dossier.
---

# Claim Check

Investigate a **premise** — a ticket, a hunch, a question — against the current
state of the repo, and report whether it still holds and whether it can be acted
on. This skill **runs the investigation** and stops at a verdict; it does **not**
implement the work the premise describes.

## When to use

Someone hands you something to act on and you should not take it at face value
first: a tracker ticket from an earlier audit, a suspicion you are carrying ("I
think our cache double-fetches"), or an open question about the code. The code
may have moved, a merged change may have addressed it in full or in part, or the
framing may be stale — and equally, it may be exactly right. You want to **know**
before anyone builds on it.

## The one rule that makes this work

Every claim is a **hypothesis to be checked against current repo reality** — not
assumed true, not assumed false. You are not trying to prove the premise wrong,
and you are not trying to rubber-stamp it: **"the premise still holds" is a
first-class outcome**, as good as "already handled." Conclusions come only from
evidence you went and found. Anything you cannot show is unknown, and unknown
means *go search* — never "probably." Do not under-search; an unverified claim is
not a finding.

## Resolving the premise

Where the claims come from depends on the input:

- **A ticket or doc (link or pasted).** Get its *substance, not just its link* —
  fetch the body and acceptance criteria via a tracker integration or the URL if
  reachable; otherwise ask the operator to paste them. Its claims arrive
  pre-articulated; read them as written rather than recalling them.
- **A hunch you are carrying, or a bare question.** No claims are stated yet.
  **Articulate the premise into atomic, checkable claims and confirm them with
  the operator before investigating.** This step is what keeps a fuzzy input from
  producing a fuzzy investigation — everything downstream operates on concrete
  hypotheses.
- **Nothing clear to check.** Ask. Do not invent a claim to investigate.

## Steps

1. **Resolve the premise** (above) and state the atomic claims you are about to
   check. For a hunch or question, get the operator's nod on the claim list
   first.
2. **Check each claim against the current repo.** Fan-out is the recommended
   tool — especially for code and doc *scanning* — but you orchestrate it and may
   search directly when that is tighter. When you dispatch a subagent, its brief
   must be **neutral and specific** ("what does the handler at `X` currently
   do?", not "confirm `X` is missing") and must return **evidence, not a
   judgment** (`file:line`, a snippet, a commit). Keep briefs scoped to one claim
   or one scan so the context stays tight.
3. **Scan for prior or parallel work** — the case the premise itself cannot see.
   Always search the repo's git history for commits and merged PRs that already
   address it in full or in part. If the tracker is queryable (the same
   integration or web access used to fetch the premise), also search it for
   sibling or duplicate tickets; if it is not reachable, say the backlog was not
   swept rather than implying it was. Record what you searched, so "none found"
   means something.
4. **Adversarially re-check your conclusions.** For anything that came back
   *confirmed* and anything that came back *obsolete*, take a second pass that
   tries to falsify it. This guards equally against a wrong "it's already handled"
   and a lazy rubber-stamp.
5. **Synthesize the two-axis output** below.

## Output

Default to a structured in-chat report in this shape. You *may* also persist it —
to a documentation home if the repo has one that fits the pattern, or to
`tmp/<YYYY-MM-DD>-<slug>-claim-check.md` when durability or a handoff is wanted —
but that is a judgment call, not a requirement.

> **Claim-check — `<premise in one line>`**
>
> **Source:** `<ticket id / url · operator's hunch · question>`
>
> **Claims checked:**
> 1. `<atomic claim>` — **`<holds / partial / refuted / mis-scoped / unknown>`** — `<evidence: file:line, snippet, commit, PR, ticket>`
> 2. `<…>`
>
> **Prior / parallel work:** `<commits, merged PRs, sibling tickets that already address this in full or part — or "none found", with what was searched>`
>
> **Verdict:** `<confirmed · partially-confirmed · refuted/obsolete · mis-scoped · confirmed-but-blocked>` — `<one-line synthesis>`
>
> **Readiness:**
> - *If actionable:* `<where to start, the relevant code / docs, gotchas, dependencies, open unknowns>`
> - *If not:* `<exactly what is missing, or what decision is needed, to make it workable>`

The two axes are independent: a `confirmed` premise can still be
`confirmed-but-blocked` on readiness, and that is the most important thing to
surface when it is true.

## Rules

- Never conclude from assumption. Every verdict cites evidence you found; unknown
  resolves to *search*, not to a guess.
- Stay unbiased. You are not out to refute the premise or to bless it — confirming
  it and refuting it are equally good outcomes, decided by the evidence.
- Articulate before investigating. A fuzzy input becomes confirmed atomic claims
  *before* the search starts; a ticket that already states its claims skips this.
- Subagent briefs are neutral, specific, and return evidence — never a leading
  question, never a verdict handed to the subagent to confirm.
- Re-check both "confirmed" and "obsolete" conclusions adversarially before
  reporting them.
- Stop at the verdict + dossier. This skill does not implement the work — acting
  on the findings is a separate step the operator owns.
