# Per-Task Fresh Dispatches

## Rule

In subagent-driven development with multiple sequential tasks, each new task's review stages are **fresh dispatches** per stage per task. Do not SendMessage-resume a reviewer that completed a prior task's review on a new task's diff.

The reviewer-session-continuation rule applies to **revision rounds on the same artifact**, not to reuse across SDD tasks.

## Why

Cross-task continuation is the **cross-artifact mistake** even when the role is identical. Resuming Task 3's spec-compliance reviewer to review Task 5's diff carries Task 3's context as context rot — the reviewer's working memory is now polluted with the prior task's spec, plan, and findings, none of which apply to Task 5.

Each task is a fresh artifact. Each artifact deserves a fresh review.

## The signal you've made this mistake

The harness response `"Agent X had no active task; resumed from transcript"` when you SendMessage to a prior task's reviewer is the cross-artifact-mistake signal.

When you see this:

1. Kill the resumed session.
2. Dispatch a fresh reviewer for the new task.

## Applies across review stages

In an SDD task with four review stages (spec compliance → code quality → pattern review → test quality), each stage is a separate dispatch. None of them carry across to the next task:

- Task 1: fresh spec-compliance reviewer → fresh code-quality reviewer → fresh pattern-reviewer → fresh test-quality-reviewer.
- Task 2: fresh spec-compliance reviewer → fresh code-quality reviewer → fresh pattern-reviewer → fresh test-quality-reviewer.
- Task 3: same.

Within a single task's revision rounds, the *same* stage's reviewer continues across rounds (per `reviewer-session-continuation.md`). But across tasks, every stage starts fresh.

## Applies to visual-implementer too

The same discipline governs `visual-implementer`. The artifact is the visual asset slot or presentation surface being worked on, not the agent's role.

- **Same visual task across iterations** (advisor asked for `adjust import/scale/pivot/timing`, requested `regenerate` for the same slot, the agent reported `pending runtime proof` and the next round adds the harness scenario, or the agent landed a candidate and is now promoting it via the same prompt's path) → continue the same `visual-implementer` session by SendMessage.
- **New visual task** (different actor sprite family, different presentation surface, a new approved prompt that does not narratively continue the prior task) → fresh `visual-implementer` session.

## Applies to vigil too

Each new audit target / scope / mode is a fresh `vigil` dispatch. Continuation applies only to revision rounds on the same audit (e.g., the scaffold owner re-reviewing after a round-1 finding has been addressed).

## In your project's docs

Adopt this rule with a project-specific equivalent. Reference your specific orchestration mechanism. Reference the harness signal your host emits when you've made the mistake (the originating project's signal is `"Agent X had no active task; resumed from transcript"`; your host may differ).

The shape that matters: **same artifact, revision rounds → continue; new artifact (new task, new mode, new target) → fresh dispatch.** The temptation to "save context by reusing the reviewer" is exactly the wrong instinct; the cost of resumption is real, but the cost of cross-artifact context rot is higher.
