# test-quality-reviewer

## Origin

The originating project's implementation-review loop had three stages: spec compliance, code quality, and pattern review. Over time a recurring failure slipped through all three: weak, trivially-passing, and misleading tests kept landing. A test that compiles, runs green, and asserts almost nothing reads as "covered" — and a green checkmark is easy to wave through in a code-quality pass that is focused on the production code.

The cost showed up later as rework: a regression shipped behind a test that named the behavior it was supposed to protect but never actually exercised it. The test gave false confidence, so the bug was found by manual play or critique instead of by the suite that was supposed to catch it.

`test-quality-reviewer` was introduced as a fourth review stage — running after pattern review, narrowly scoped to test-code trustworthiness and test design.

## Problem

Code-quality review and test-quality review fail differently:

- **Code-quality review** asks "does this production code work, is it readable, is it maintainable?" Tests in the diff get a glance, and a green test tends to get a pass.
- **Test-quality review** asks "does this test actually protect the behavior it claims to protect?"

A test can be green and worthless: a trivially-passing setup that triggers a guard's early-return so the path under test never runs; a vacuous assertion ("no exception thrown" when the behavior has an observable result); a body that exercises an adjacent behavior instead of the one in the test name. None of these fail. None of them are caught reliably when test review is folded into a production-code-focused stage. And once a few weak tests land, the suite's green status stops meaning what readers think it means.

`test-quality-reviewer` is the **test-trustworthiness stage** — the gate that asks whether a weak or misleading test could still merge.

## Solution shape

Code-first, two modes:

- `mode: diff` — the fourth in-loop review stage. Reviews the test code in the current task's `git diff`, reading the production code under test to judge whether the tests are meaningful. Emits a `PASS` / `ISSUES_FOUND` verdict.
- `mode: audit` — an on-demand sweep of existing test code (a file, a folder, or the whole suite). Emits a prioritized findings report, not a binary verdict — a sweep of many files is a report, not a gate.

It reads production code to judge tests but **reports only on test files**. Production-code-quality, pattern, and spec findings belong to the other reviewers; emitting them here blurs the gate.

**Judgment-driven checklist.** The agent flags trivially-passing setups, weak or absent assertions, mock-saturated (tautological-mock) tests, wrong-path testing, missing edge cases, brittle over-coupled tests, non-deterministic tests, and test-code-quality smells. The rule is to flag an issue only when you can name a concrete way the test fails to protect the behavior it claims to protect — not for stylistic preference.

**Optional metrics input.** If the project produces coverage and complexity metrics, the agent uses them to prioritize which production code's tests warrant the closest scrutiny — code that is both complex and weakly covered is where weak tests matter most. Metrics are never a hard dependency: when absent, the agent says so and performs the full qualitative checklist anyway.

**Refuse combined-review dispatches.** If the dispatch prompt asks for spec compliance + code quality + pattern + test quality in one call, the agent emits a structured refusal. Separate dispatches preserve the gating discipline.

**Anti-closure rule:** the `PASS` bar is constant across revision rounds. Round 5 `PASS` meets the same standard as round 1.

## Real workflow snippet

Example `AGENTS.md` block on the implementation-review loop:

```markdown
## Implementation review sub-loop

When using the subagent-driven-development workflow, each task's diff goes through four
review stages, each a separate dispatch:

1. **Spec compliance review** — separate dispatch with a spec-compliance prompt.
2. **Code quality review** — separate dispatch with a code-quality prompt.
3. **Pattern review** — `pattern-reviewer` against the task's diff, with `mode:` matching
   the touched surface.
4. **Test quality review** — `test-quality-reviewer` (`mode: diff`) against the task's
   diff. Reviews the test code's trustworthiness and design.

If a stage flags issues, the implementer fixes them and that stage re-reviews
(continuing the same reviewer session). Each review stage is a separate dispatch — do not
collapse the four into a single agent call.
```

Example dispatch shape:

> Dispatch `test-quality-reviewer` with `mode: diff` against Task N's diff. Spec compliance, code quality, and pattern review have already passed.

## Pitfalls observed

- **Folding test review back into the code-quality stage.** This is the exact failure mode the agent exists to fix. A production-code-focused reviewer waves green tests through. Keep the stage separate.
- **Combined-review dispatches.** Dispatchers occasionally bundle all four stages into one prompt. The agent refuses by design. Adapt the orchestration; don't relax the refusal.
- **Treating an audit report as a gate.** `audit` mode produces a prioritized findings report, not a `PASS` / `ISSUES_FOUND` verdict. A sweep of many files is a report; only `diff` mode gates a task.
- **Depending on coverage metrics.** Metrics are an optional prioritization input. A project with no coverage tooling still gets a full qualitative review. A missing metrics artifact never blocks a verdict.
- **Cross-task SendMessage-resume.** Each task's test-quality review is a fresh dispatch. The reviewer-session-continuation rule applies to revision rounds **on the same task**, not across tasks.

## Adaptation notes

- The test surface is project-defined. The canonical spec does not hardcode where tests live — point the agent at your project's test directory through your `CLAUDE.md` / `AGENTS.md` conventions.
- The checklist categories are the durable shape; the examples are framework-neutral. Adapt them to your test framework's idioms (xUnit, Vitest, pytest, etc.) — the categories survive the translation.
- Coverage and complexity metrics are optional. If your project has no coverage tooling, adopt the agent anyway — it runs fully qualitatively. Wire a metrics artifact in later if you add one; do not block adoption on it. Keep the metrics description generic — the agent reads whatever artifact the project publishes and does not own the coverage tooling.
- **Adopt the handoff realignment with the agent.** Introducing `test-quality-reviewer` re-partitions test-related review ownership. `pattern-reviewer` defers test quality and test design to this agent. `spec-reviewer`'s plan review keeps only the literal test-existence walk (does the plan name every test the spec calls for) and drops any review of planned test correctness or test bodies — per TDD discipline the implementer writes each test body fresh, and implemented test-code quality is reviewed here, on real test code, at stage 4. If you adopt `test-quality-reviewer` without applying this realignment, two stages will double-own test judgment and the plan stage will keep trying to review test bodies that do not exist yet.
- The refuse-combined-review section is load-bearing — adopt it. Combined-review prompts erode review-stage gating quickly.
