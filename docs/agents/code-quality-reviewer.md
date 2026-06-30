# code-quality-reviewer

## Origin

The scaffold's implementation-review loop always named three stages — **code
quality**, then pattern conformance, then test trustworthiness — but only the last
two shipped as agents (`pattern-reviewer`, `test-quality-reviewer`). The
code-quality stage was left as "the project's own code-quality reviewer": every
adopting project was expected to supply it, and `pattern-reviewer` even documents
that it runs *after code-quality review*. `code-quality-reviewer` fills that gap
with a portable agent.

It pairs with the `code-quality-review` skill: the **skill is the rubric** (the
strict standards, the 1k-line rule, the spaghetti and code-judo rules, the approval
bar and output ordering), and the **agent is the dispatchable reviewer** that loads
that rubric and applies it to a diff in its own subagent context. The agent spec
was operator-provided and adapted into the scaffold — sanitized to be
host-agnostic and pointed at the bundled skill rather than any one host's plugin.

## Problem

Running the code-quality pass inline in the main session has two costs. First, the
full diff plus the changed files' contents flood the parent's context, crowding out
the work the parent is actually doing. Second, a reviewer that shares the
implementer's context inherits its framing — it is primed to agree the code is
fine, because it just watched it get written.

The deeper problem is the one the skill exists for: a correctness-first review
approves working code and lets the codebase rot — a file crosses 1000 lines, a
special-case branch lands in an unrelated flow, feature logic leaks into a shared
path. None of it is a bug; all of it is debt. The stage needs an agent whose whole
job is to hold that structural bar, in a fresh context, before the change merges.

## Solution shape

A **review-only subagent** dispatched as the code-quality stage of an
implementation review:

- **Rubric by reference.** It loads the `code-quality-review` skill's `SKILL.md`
  and treats it as the complete rubric — tone, approval bar, priority ordering, and
  the code-judo / 1k-line / spaghetti rules — so the agent and any inline use of the
  skill stay in lockstep. A built-in fallback keeps it useful if the skill isn't
  present.
- **Diff-scoped input.** A parent typically pre-collects `git diff <base>...HEAD`
  (default base `main`) and the changed files' contents and passes them in labeled
  `### Git / diff output` and `### Changed file contents` sections; the agent
  reviews only what those show, and gathers the diff itself if nothing is supplied.
- **Fresh context.** Running in its own subagent window keeps the diff out of the
  parent's context and lets the code-quality, pattern, and test-quality stages run
  as separate, focused dispatches.
- **Review-only.** It surfaces structural problems and pushes for a cleaner design;
  it never patches, commits, or pushes. The implementer owns the fix.

## Real workflow snippet

Wire it into an adopting project's `CLAUDE.md` / `AGENTS.md` implementation-review
section:

> After implementation, run the review stages as separate dispatches, in order:
> 1. `code-quality-reviewer` — collect `git diff main...HEAD` and the changed
>    files' contents, then dispatch with `### Git / diff output` and
>    `### Changed file contents` sections. It loads the `code-quality-review`
>    rubric and reports structural findings.
> 2. `pattern-reviewer` — implementation-pattern conformance.
> 3. `test-quality-reviewer` — test trustworthiness (`mode: diff`).

## Pitfalls observed

- **Combining stages.** Folding code-quality, pattern, and test review into one
  dispatch produces a shallow pass on all three. Keep them separate.
- **Nit flooding.** The agent inherits the skill's discipline: a long list of
  cosmetic notes when a structural problem exists is a failure, not thoroughness.
- **Reviewing without the diff.** If no change set is supplied and the agent can't
  resolve a base, it should say so rather than audit the whole tree — its bar is
  written for "should this change land."
- **Treating it as a fixer.** It is review-only; routing its findings into edits is
  a separate step the implementer owns.

## Adaptation notes

- The agent depends on the `code-quality-review` skill for its rubric. Adopt the
  two together; if you adopt the agent alone, its fallback still works but you lose
  the single-source-of-truth rubric.
- The default diff base is `main`; change it to your trunk name. The labeled input
  sections (`### Git / diff output`, `### Changed file contents`) are a convention —
  rename them if your orchestration prefers other labels, and update the wrappers to
  match.
- It is read-only (`Read, Grep, Glob, Bash`) like the other review agents. The host
  wrappers (`.codex`, `.gemini`, `.opencode`) are thin pointers to the canonical
  `.claude/agents/code-quality-reviewer.md`; keep them in sync when the canonical
  spec changes.
