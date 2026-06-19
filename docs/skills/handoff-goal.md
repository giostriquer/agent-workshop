# handoff-goal

## Origin

The third handoff the maintainer kept writing by hand: not handing a finished branch *backward* to a reviewer (`handoff-review`) or a PR opener (`handoff-pr`), but handing work *forward* — "here's the goal, here's where we are, here are the working rules; new session, go pursue it." Written ad hoc, the doc carried the goal but lost the rules: preferences stated once in chat (commit style, push policy, PR target) made it into the file inconsistently, and nothing told the pursuing session what to do when its own context compacted mid-goal.

`handoff-goal` formalizes that forward handoff into a goal document a new session picks up and pursues autonomously.

## Problem

The ad-hoc flow fails in four characteristic ways. The first three are about *context loss*; the fourth is about *goal defense*, and it surfaced once the skill was actually used to drive autonomous loops.

1. **Rules evaporate at compaction.** The pursuing session starts well, compacts, and the operating rules — which lived in its early context — are gone. Behavior drifts mid-goal: pushes that weren't approved, PRs to the wrong base, validation skipped.
2. **Invented rules.** A baseline test showed a model writing a handoff cold will pad the rules with constraints nobody stated ("never rebase") and present them as user-mandated — the pursuing session then over-constrains itself.
3. **Step list instead of outcome.** Without a definition of done, the pursuing session stops early or gold-plates; without an outcome framing it can't optimize the path when the listed steps turn out wrong.
4. **The pursuer reward-hacks the goal.** A session pursuing a goal under speed pressure is an optimizer, and an optimizer converges on whatever *looks* done. Handed a prose "definition of done," it will weaken a test, narrow the scope, reinterpret the goal, or declare victory on its own say-so when those are the cheapest paths to "done." The original document stated the goal and *trusted* the pursuer — an excellent context preserver, a weak goal defender. The danger is sharp precisely because a handoff is only as disciplined as the repo it lands in: when the target repo's rule files already mandate gates, mutation proofs, and "no weakening tests," the pursuer inherits that discipline; many repos mandate none of it, and then nothing stands between the goal and a fast-but-plausible loop.

## Solution shape

A document generator, not an executor. It resolves the goal from one of three sources — inferred from the session's trajectory (then confirmed), scoped to referenced existing work (a plan, slices, a spec), or shaped from a brand-new description (asking only what's needed to make it actionable). It re-derives current state from the repo rather than session memory, gathers operating rules (repo rule files + operator statements, asking for what's still open), and writes `tmp/<YYYY-MM-DD>-<goal-slug>.md`.

The document is built on **two rules**, not one:

1. *The document is the only context that survives.* The pursuing session starts with zero access to the producing session and compacts while it works, so everything it needs — goal, state, operating rules — lives in the file, and the file tells it to keep coming back.
2. *The document is the goal's defense against its own pursuer.* It defines done as checks the pursuer can't fake, forbids the cheap proxies, forces verification the pursuer didn't judge itself, logs the evidence, and names the temptations that mean *escalate, don't reinterpret*. The discipline is injected **into the document** — the skill does not assume the target repo supplies it.

Concretely the emitted document carries: **verifiable acceptance checks** (each with a verify command + expected evidence, and a refutation/mutation form for behavior changes) in place of prose done; an **integrity rules** block (don't weaken / skip / rename-away tests or gates; don't narrow scope or reinterpret the goal — escalate; evidence before claims; report failures faithfully); an operator-set **quality posture** line (default: reliability over speed); **independent verification** baked into the loop shape (act → verify with an independent pass → record evidence → repeat); stakes-scaled **invariants / must-not-break** and **non-goals** sections; a **progress ledger** (each entry: which check it advanced, the verification run, decisions + rationale — authoritative over post-compaction recollection); explicit **when-to-stop** conditions including the anti-degradation tripwire ("tempted to change the goal, the checks, or the scope to make done reachable" → escalate, not edit); and a compaction ritual that is a *drift check* (re-read Goal + Acceptance checks + Integrity rules after every compaction and before declaring any check done).

The goal is still stated as an outcome the pursuing session owns and may optimize — the acceptance checks pin *what done means*, not *how to get there*.

## Calibration

The defense scales with the goal's stakes and the operator's quality posture — a one-file utility shouldn't be wrapped in a full invariant matrix. **Four parts are always on**, whatever the goal, because they are what convert a fast-but-plausible loop into a slower-but-reliable one: verifiable acceptance checks, integrity rules, independent verification, and the redefinition tripwire. Everything else — an explicit invariants section, a non-goals list, a full reviewer-grade independent pass — scales up with stakes.

## Real invocation snippet

> /handoff-goal

Infers the goal from the session (the active plan, the work in progress), confirms it with the operator, and writes the goal document.

> /handoff-goal slices 3-9 of the relay-sync plan

Scopes the goal to exactly those slices, reading the plan file rather than recalling it.

> /handoff-goal I want a CLI that mirrors issue comments between two trackers...

No plan exists; asks only what's needed to make the goal actionable, then shapes it into the document.

## Pitfalls observed

- **Vague rules.** "Follow the usual conventions" survives compaction as nothing. Rules carry concrete values — the actual branch, the actual PR target — each sourced from a repo rule file or the operator.
- **Invented rules.** The baseline failure above. If neither the repo nor the operator stated it, it doesn't go in the document.
- **Prose definition of done.** "X works" is the gameable proxy. Done is a checklist of checks the pursuer can run, each with how to verify it; behavior changes carry the mutation that should turn them red.
- **Assuming the repo supplies the discipline.** The integrity rules ride in the document precisely because the target repo may mandate nothing. Don't omit them on the assumption that "the repo's CLAUDE.md handles it."
- **Fortress for a one-liner.** The opposite failure: loading a trivial goal with the full apparatus. Gate it on stakes and quality posture; ship the always-on four and add the rest as warranted.
- **Treating it as an executor.** It writes the document; pursuing the goal belongs to the new session. Starting the work in the producing session defeats the handoff.
- **Restating the plan.** The document links to plan / spec files; copying their content in creates a second source of truth that goes stale.

## Adaptation notes

- The operating-rules categories (branch / commits / push-PR / validation / quality-posture / scope) are portable; the *values* come from each project's own rule files and operator, so the skill adapts automatically.
- The integrity apparatus is the generalized form of a repo's Regression-Prevention Gate. A project that already mandates gates and mutation proofs can lean on its own rule files; a project that doesn't gets the discipline from the document itself.
- The scratch path (`tmp/...`) is a default; point it at whatever scratch dir your project uses, and gitignore it.
- Pairs naturally with its siblings: pursue the goal, then `handoff-review` for a fresh-eyes review, then `handoff-pr` to package the PR.
