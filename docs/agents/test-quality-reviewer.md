# test-quality-reviewer

## Origin

The originating review loop had three stages: spec compliance, code quality, and pattern
review. Weak tests still landed. They compiled, ran green, and named the right behavior,
but the bodies often asserted little, hit adjacent paths, or reasserted mocks.

`test-quality-reviewer` was introduced as a separate test-trustworthiness stage: the
reviewer that asks whether tests would actually fail under realistic regressions.

The role later needed a broader scaffold shape for higher-impact projects. Some projects
can publish coverage and complexity data. Some have invariant-heavy code where property
tests are the right tool. Some need targeted mutation or acceptance-mutation checks to
prove a critical test would fail if the protected behavior were broken. Folding all of
that into one mandatory checklist would make the agent noisy, so the canonical spec now
uses capability lanes.

## Problem

Code-quality review and test-quality review fail differently:

- Code-quality review asks whether production code works, is readable, and is
  maintainable.
- Test-quality review asks whether the test suite protects the behavior it claims to
  protect.

A test can be green and worthless: a trivially passing setup, a broad snapshot, a
tautological mock, a missing negative case, or an example that never reaches the named
branch. Once those tests merge, the suite's green status becomes false confidence.

The higher-impact version of the problem is worse: a product can have decent average
coverage while complex, consequential methods remain weakly tested. That requires risk
signals and strategy, not just more examples.

## Solution shape

The canonical agent is still code-first and review-scoped, but it now has three modes:

- `mode: diff` - the in-loop test-quality stage for the current task diff. Emits
  `PASS` / `ISSUES_FOUND`.
- `mode: audit` - a targeted or full-suite sweep. Emits a prioritized findings report,
  not a binary gate.
- `mode: strategy` - an advisory pass that proposes a project test-quality profile:
  coverage target, CRAP target, high-impact surfaces, property-test candidates,
  mutation-test candidates, and audit cadence.

The review itself is organized into lanes:

- **Baseline trustworthiness** - weak assertions, tautological mocks, wrong-path tests,
  missing edges, brittle coupling, nondeterminism, and test-code complexity.
- **Metrics** - coverage and complexity evidence, including a default recommended CRAP
  ceiling of `<= 6` when valid per-method CRAP data exists. Coverage remains
  project-defined.
- **Property testing** - candidate strategy for parsers, serializers, normalization,
  state transitions, permission matrices, accounting/resource totals, migrations, and
  other invariant-rich behavior.
- **Mutation testing** - mental mutation checks in every review, with actual mutation or
  acceptance-mutation tooling recommended only where project tooling and risk justify it.
- **High-impact project scrutiny** - stricter treatment of weak tests on consequential
  surfaces and a stronger expectation for periodic audit/strategy reviews.

The key guardrail: metrics, property testing, and mutation testing are evidence lanes.
They do not become universal gates unless the adopting project explicitly makes them
gating.

## Real workflow snippet

Example review-loop block for an adopting project:

```markdown
## Implementation review sub-loop

Each meaningful task diff goes through separate review stages:

1. Spec compliance review.
2. Code quality review.
3. Pattern review.
4. Test quality review - `test-quality-reviewer` in `mode: diff`.

`test-quality-reviewer` reviews test trustworthiness and risk coverage. It may use
published metrics as prioritization evidence. The default CRAP target is `<= 6` when valid
per-method CRAP data exists; coverage target is project-defined.
```

Example strategy dispatch:

> Dispatch `test-quality-reviewer` with `mode: strategy` for the persistence subsystem.
> Treat this as high-impact. Propose coverage target, CRAP target, property-test
> candidates, mutation-test candidates, and audit cadence.

## Pitfalls observed

- **Folding test review back into code-quality review.** Production-code reviewers tend to
  wave green tests through. Keep the stage separate.
- **Making metrics the reviewer.** CRAP and coverage prioritize scrutiny; they do not
  replace reading the tests.
- **Deriving CRAP from bad inputs.** CRAP is meaningful only when coverage and
  cyclomatic-complexity data are both valid for the same method. Zeroed, missing, `NaN`,
  or synthetic complexity makes CRAP unavailable.
- **Universal property-test demands.** Property testing is valuable for invariant-rich
  behavior, not every UI or workflow test.
- **Universal mutation-test demands.** Mutation thinking belongs in every review; actual
  mutation tooling belongs in targeted audit/strategy use unless the project has a fast
  documented gate.
- **Treating audit mode as a task gate.** Audit mode produces a prioritized report. Only
  diff mode gates a task.
- **Cross-task session continuation.** Continue a reviewer session across revision rounds
  for the same task only. New task, fresh dispatch.

## Adaptation notes

- The test surface is project-defined. Point the agent at test directories and important
  helpers through `AGENTS.md`, `CLAUDE.md`, or testing conventions.
- Declare high-impact surfaces explicitly. This lets the reviewer apply stricter scrutiny
  without guessing.
- Declare coverage targets per project. Native tools, backend services, CLIs, games, and
  UI apps deserve different thresholds.
- Use `CRAP <= 6` as the default recommended ceiling when valid CRAP data exists, unless
  the project chooses a different target.
- Publish metric artifact paths if you want metric-aware audits. If metrics are absent,
  the agent still runs qualitatively.
- Adopt the handoff realignment with the agent: `pattern-reviewer` defers test quality and
  `spec-reviewer` keeps only pre-implementation testability/test-existence checks. Real
  test-body judgment happens here, on implemented tests.
- Keep the refusal rule. Combined-review prompts erode the stage boundary that makes this
  agent useful.
