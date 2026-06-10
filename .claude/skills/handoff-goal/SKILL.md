---
name: handoff-goal
description: Use when a goal — the rest of an in-flight plan, a scoped slice of it, or a brand-new idea — should be handed to a new session to pursue autonomously. Produces a self-contained goal document (`tmp/<YYYY-MM-DD>-<goal-slug>.md`) carrying the goal with its definition of done, current state, and concrete operating rules (branch, commits, push/PR, validation) so the pursuing session behaves consistently across compactions. With no argument it infers the goal from session context and confirms; never pursues the goal itself.
---

# Handoff Goal

Package a goal into a **self-contained goal document** that a new session picks up and pursues autonomously. This skill writes the document; it does **not** pursue the goal.

## When to use

Work should continue beyond this session — the remaining slices of a plan, a scoped piece of one, or something the operator has only just described — and a new session should be able to run with it without re-explaining the goal, the state, or the working rules.

## The one rule that makes this work

The document is the **only context that survives**. The pursuing session starts with zero access to this session and will compact while it works, so everything it needs to behave consistently — goal, state, operating rules — lives in the document, and the document tells the session to keep coming back to it. Anything left in chat instead of the document is gone the first time it's needed.

## Resolving the goal

How the skill was invoked decides where the goal comes from:

- **No argument** — infer the goal from the session's trajectory (the active plan, the work in progress, the stated intent). Present the inferred goal and ask the operator to confirm; if the session offers no clear candidate, ask outright instead of guessing.
- **A reference to existing work** (a plan, slices of it, a spec, a branch) — scope the goal to exactly that reference, reading the referenced material rather than recalling it.
- **A description of something new** — no plan exists yet. Ask only what's needed to make the goal actionable (the outcome, hard constraints, where it lives), then shape it.

Whatever the source, the document states the goal as an **outcome with a definition of done**, not a step list — the pursuing session owns the path and is free to optimize it.

## Steps

1. **Resolve the goal** (above), confirming with the operator when it was inferred or newly described.
2. **Capture current state from the repo, not memory.** Branch, what exists, what's done / half-done, decisions already made. Verify with `git status` / `git log` / the files — session recollection drifts.
3. **Gather the operating rules.** Take what the repo already mandates (`CLAUDE.md` / `AGENTS.md` / convention docs) and what the operator stated this session; ask the operator for whatever is still open — typically: branch or worktree to work in, commit cadence and message style, push policy, PR policy (whether, when, target), validation gates, and what should trigger stop-and-ask. Record **concrete values** ("PRs target `develop`, only after all slices pass"). Never invent a rule the operator didn't state and the repo doesn't mandate.
4. **Assemble the document** from the template and write it to `tmp/<YYYY-MM-DD>-<goal-slug>.md` (today's date, short kebab-case goal name).
5. **Deliver.** Report the path and tell the operator to point a new session at the file. Do not begin pursuing the goal here.

## The goal document template

> # Goal handoff — `<title>` (`<YYYY-MM-DD>`)
>
> **To the pursuing session:** this file is your working contract. Re-read **Operating rules** after every compaction. Append to **Progress** as you land work and record decisions you make along the way — future sessions (and your own post-compaction self) resume from this file, not from memory.
>
> ## Goal
> `<the outcome, plus an explicit definition of done — how the pursuing session knows it's finished>`
>
> ## Context
> `<minimum background a fresh session needs; link to plan / spec files rather than restating them>`
>
> ## Current state
> `<branch, what exists, what's done / half-done, decisions already made — re-derived from the repo>`
>
> ## Operating rules
> - **Branch / worktree:** `<where the work happens>`
> - **Commits:** `<cadence, message style>`
> - **Push / PR:** `<push policy; whether, when, and where a PR opens>`
> - **Validation:** `<gates that must pass, and when>`
> - **Scope / stop-and-ask:** `<boundaries; what must go back to the operator>`
>
> ## Progress
> `<running log — the pursuing session appends entries as work lands>`
>
> ## Start here
> `<the first concrete action>`

## Rules

- Never pursue the goal in this session — write the document and hand off.
- The document must be readable with zero access to this session; no "as discussed."
- State the goal as an outcome with a definition of done; leave the path to the pursuing session.
- Operating rules carry concrete values sourced from the repo's rule files or the operator — never "follow the usual conventions," and never a rule you invented.
- Confirm an inferred or newly-shaped goal with the operator before writing the document.
