---
name: handoff-goal
description: Use when a goal — the rest of an in-flight plan, a scoped slice of it, or a brand-new idea — should be handed to a new session to pursue autonomously. Produces a self-contained goal document (`tmp/<YYYY-MM-DD>-<goal-slug>.md`) carrying the goal with its definition of done, current state, and concrete operating rules (branch, commits, push/PR, validation) so the pursuing session behaves consistently across compactions. With no argument it infers the goal from session context and confirms; never pursues the goal itself.
---

# Handoff Goal

Package a goal into a **self-contained goal document** that a new session picks up and pursues autonomously. This skill writes the document; it does **not** pursue the goal.

## When to use

Work should continue beyond this session — the remaining slices of a plan, a scoped piece of one, or something the operator has only just described — and a new session should be able to run with it without re-explaining the goal, the state, or the working rules.

## The two rules that make this work

1. **The document is the only context that survives.** The pursuing session starts with zero access to this session and will compact while it works, so everything it needs to behave consistently — goal, state, operating rules — lives in the document, and the document tells the session to keep coming back to it. Anything left in chat instead of the document is gone the first time it's needed.

2. **The document is the goal's defense against its own pursuer.** A session pursuing a goal under speed pressure is an optimizer, and an optimizer converges on whatever *looks* done — it will weaken a test, narrow the scope, or declare victory on its own say-so when those are the cheapest paths to "done." The document is what stops that: it defines done as checks the pursuer can't fake, forbids the cheap proxies, forces verification the pursuer didn't judge itself, logs the evidence, and names the temptations that mean *escalate, don't reinterpret*. **Do not assume the target repo supplies this discipline** — many repos mandate no gates, no mutation proofs, no "don't weaken tests." The document carries it.

## How much apparatus

Scale the defense to the goal's stakes and the operator's quality posture — don't wrap a one-file utility in a full invariant matrix. **Four parts are always on**, whatever the goal; they are what convert a fast-but-plausible loop into a slower-but-reliable one:

- **Verifiable acceptance checks** — done is a checklist the pursuer can *run*, not prose it can interpret.
- **Integrity rules** — the prohibitions that name reward-hacking for what it is.
- **Independent verification** — done is confirmed by a pass the pursuer didn't make itself.
- **The redefinition tripwire** — "tempted to change the goal, the checks, or the scope to make done reachable" is a stop-and-ask, not a shortcut.

Everything else — an explicit Invariants section, a Non-goals list, a full reviewer-grade independent pass — scales up with stakes. A trivial goal carries the four; a high-stakes one carries all of it.

## Resolving the goal

How the skill was invoked decides where the goal comes from:

- **No argument** — infer the goal from the session's trajectory (the active plan, the work in progress, the stated intent). Present the inferred goal and ask the operator to confirm; if the session offers no clear candidate, ask outright instead of guessing.
- **A reference to existing work** (a plan, slices of it, a spec, a branch) — scope the goal to exactly that reference, reading the referenced material rather than recalling it.
- **A description of something new** — no plan exists yet. Ask only what's needed to make the goal actionable (the outcome, hard constraints, where it lives), then shape it.

Whatever the source, the document states the goal as an **outcome with a definition of done**, not a step list — the pursuing session owns the path and is free to optimize it.

## Steps

1. **Resolve the goal** (above), confirming with the operator when it was inferred or newly described.
2. **Turn the definition of done into acceptance checks.** Not prose ("X works") — a checklist where each check carries *how to verify it*: a command and the evidence that proves it passed. For any behavior change, add the **refutation form** — the mutation that should turn it red ("revert the change → test T fails"). A check with no way to verify it is a proxy the pursuer will game; rewrite it until it's executable, or mark it explicitly as operator-judged.
3. **Capture current state from the repo, not memory.** Branch, what exists, what's done / half-done, decisions already made. Verify with `git status` / `git log` / the files — session recollection drifts.
4. **Gather the operating rules, including the quality posture.** Take what the repo already mandates (`CLAUDE.md` / `AGENTS.md` / convention docs) and what the operator stated this session; ask for whatever is still open — typically: branch or worktree, commit cadence and message style, push policy, PR policy (whether, when, target), validation gates, what triggers stop-and-ask, and the **quality posture** (default: reliability over speed). Record **concrete values** ("PRs target `develop`, only after all checks pass"). Never invent a rule the operator didn't state and the repo doesn't mandate.
5. **Size the integrity apparatus** to the goal (see *How much apparatus*). The always-on four ship in every document; add Invariants / Non-goals and a reviewer-grade independent pass as stakes warrant.
6. **Assemble the document** from the template and write it to `tmp/<YYYY-MM-DD>-<goal-slug>.md` (today's date, short kebab-case goal name).
7. **Deliver.** Report the path and tell the operator to point a new session at the file. Do not begin pursuing the goal here.

## The goal document template

> # Goal handoff — `<title>` (`<YYYY-MM-DD>`)
>
> **To the pursuing session:** this file is your working contract, and it outranks your own recollection. After **every compaction** — and again before you mark any check done — re-read **Goal**, **Acceptance checks**, and **Integrity rules**, and confirm your work still targets the stated outcome, not a reinterpretation that's easier to reach. Append to the **Progress ledger** as you land work; that ledger, not memory, is the record.
>
> ## Goal
> `<the outcome in one or two sentences — what is true when this is done>`
>
> ## Acceptance checks
> Done = every check below independently verified (see Integrity rules). For each:
> - [ ] `<the check — a specific, observable claim>`
>   - **Verify:** `<command to run + the evidence that proves it passed>`
>   - **Refutation:** `<for behavior changes: the mutation that should turn it red — e.g. "revert the change → test T fails">`
>
> ## Integrity rules
> While pursuing this goal you must not:
> - **Weaken the bar to clear it** — don't delete, skip, `.only`/`xit`, loosen, or rename/relocate a test so the runner stops collecting it, to make the goal "pass." Make the *real* thing pass — fixing the code under test, including pointing the test at the corrected module or a proper new seam, is a fix, not a dodge.
> - **Move the goalposts** — don't narrow scope, redefine done, or reinterpret the goal to make it reachable. If it can't be reached as stated, **escalate** (see *When to stop*).
> - **Claim without evidence** — don't mark a check done without showing the verifying output. No "should work," no "probably fine."
> - **Hide failures** — a failing step is reported failing, in the ledger, even when inconvenient. A surprising pass is suspect until verified.
>
> ## Context
> `<minimum background a fresh session needs; link to plan / spec files rather than restating them>`
>
> ## Current state
> `<branch, what exists, what's done / half-done, decisions already made — re-derived from the repo>`
>
> ## Invariants / must-not-break  <!-- include for non-trivial goals -->
> `<what must stay true while the goal is pursued — behaviors, contracts, data, gates a passing goal must not regress>`
>
> ## Non-goals  <!-- include when scope could drift -->
> `<what is explicitly out of scope — so "done" can't quietly expand or contract>`
>
> ## Operating rules
> - **Branch / worktree:** `<where the work happens>`
> - **Commits:** `<cadence, message style>`
> - **Push / PR:** `<push policy; whether, when, and where a PR opens>`
> - **Validation:** `<gates that must pass, and when>`
> - **Quality posture:** `<operator-set — default: reliability over speed: never skip a gate or weaken a check to save time; a slower correct path beats a fast plausible one; when uncertain, verify or ask rather than guess>`
> - **Scope / stop-and-ask:** `<boundaries; what must go back to the operator>`
>
> ## When to stop
> - **Done** when every acceptance check is independently verified — not before.
> - **Stop and ask** on: outcome-changing ambiguity; a required gate that FAILs and can't be fixed in scope; no progress in `<N>` iterations; or — the tripwire — **you notice you're tempted to change the goal, the acceptance checks, or the scope to make "done" reachable.** That temptation means escalate, not edit.
>
> ## Progress ledger
> `<append-only. Each entry: which acceptance check it advanced · the verification run (command + result) · any decision + why. An entry that advances no check needs a reason. This ledger outranks post-compaction recollection.>`
>
> ## Start here
> Work the loop, not a straight line: **act → verify with an independent pass → record evidence in the ledger → repeat** until every acceptance check passes. An "independent pass" means the check is confirmed by something other than the judgment that did the work — a fresh subagent prompted to *refute* done, or at minimum a clean re-run from the Verify command — never just "I believe it works."
>
> `<the first concrete action>`

## Rules

- Never pursue the goal in this session — write the document and hand off.
- The document must be readable with zero access to this session; no "as discussed."
- Done is **verifiable acceptance checks, not prose** — each check states how to verify it, and behavior changes state how to refute it. State the goal as an outcome; leave the path to the pursuing session.
- The **always-on four** ship in every document: verifiable acceptance checks, integrity rules, independent verification, and the redefinition tripwire. Invariants / Non-goals and a reviewer-grade independent pass scale with stakes.
- **Inject the discipline into the document** — don't assume the target repo mandates gates, mutation proofs, or "no weakening tests."
- Operating rules carry concrete values sourced from the repo's rule files or the operator — never "follow the usual conventions," and never a rule you invented. The quality posture is operator-set; default to reliability over speed.
- Confirm an inferred or newly-shaped goal with the operator before writing the document.
