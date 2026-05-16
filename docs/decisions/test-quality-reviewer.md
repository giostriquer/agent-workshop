# Decision: add `test-quality-reviewer` and move the review loop to four stages

**Date:** 2026-05-16

## What changed

- Added `test-quality-reviewer` as the eighth canonical agent — a code-first reviewer of implemented test code for trustworthiness and test design. Canonical spec at `.claude/agents/test-quality-reviewer.md`, with Codex / Gemini / OpenCode thin wrappers and an origin doc at `docs/agents/test-quality-reviewer.md`.
- The implementation-review loop documented in `docs/examples/spec-driven-development.md` moved from three stages to four: spec compliance → code quality → pattern review → **test quality**.
- Realigned the test-related review ownership between the existing reviewers:
  - `pattern-reviewer` now explicitly defers test quality and test design to `test-quality-reviewer` (deferral-line touch-up).
  - `spec-reviewer`'s plan review keeps only the literal `Test existence (literal walk)` check and drops review of planned test correctness and test bodies. A new `Boundary with test-quality-reviewer` subsection records the split. The spec-mode `Testability` check is unchanged.

## Why

A test that compiles, runs green, and asserts almost nothing passes every other review gate. In the originating project, weak, trivially-passing, and misleading tests became a recurring source of rework — a failure distinct from general code-quality review, which is focused on production code and tends to wave green tests through. A dedicated test-trustworthiness stage closes that gap.

The realignment exists so no two stages double-own test judgment: plan review checks only that the plan *names* the tests the spec calls for; per TDD discipline the implementer writes each test body fresh; and implemented test-code quality is reviewed on real test code at the fourth stage. Adopting `test-quality-reviewer` without the realignment would leave `spec-reviewer` reviewing test bodies that do not exist yet.

## Deliberately excluded

The originating project pairs this agent with engine-specific coverage tooling (a coverage-package install, a batch-runner switch, and a complexity/coverage risk score). That tooling is domain-specific and was **not** propagated. The canonical spec keeps coverage and complexity metrics as a generic, **optional** prioritization input: a project with no coverage tooling adopts the agent and runs it fully qualitatively; a project that publishes a metrics artifact wires it in without the agent owning the tooling.

## Adoption note

Adopters that take `test-quality-reviewer` should also apply the handoff realignment to their `spec-reviewer` and `pattern-reviewer` so review ownership stays partitioned. See the Adaptation notes in `docs/agents/test-quality-reviewer.md`.
