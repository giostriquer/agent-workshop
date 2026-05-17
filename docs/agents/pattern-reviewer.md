# pattern-reviewer

## Origin

The originating project's review loop initially had two stages: spec compliance and code quality. After several PRs landed where the *code was correct and high-quality* but *violated established repo patterns* (mutable structs where the standard was readonly, public List exposure where the standard was IReadOnlyList, layer boundary leaks), it became clear that "code quality" and "convention conformance" were two different concerns.

`pattern-reviewer` was introduced as the third review stage — running after code quality, narrowly scoped to implementation-pattern compliance.

## Problem

Code-quality review and pattern review fail differently:

- **Code-quality review** asks "does this code work, is it readable, is it maintainable?"
- **Pattern review** asks "does this code follow the conventions the repo has chosen?"

A PR can pass code-quality review (correct, readable, well-tested) and still violate pattern conventions (introducing a mutable type into a readonly-struct layer, exposing a List where the public surface uses IReadOnlyList, importing across a forbidden boundary). Without a dedicated pattern pass, those violations land — and once they land in a few places, they normalize and the convention erodes.

`pattern-reviewer` is the **convention-enforcement stage**.

## Solution shape

Diff-driven, mode-based:

- `mode: auto` — inspect the diff, infer active review domains, enforce only those domains.
- `mode: <domain>` — enforce only one domain (e.g. `mode: backend`, `mode: frontend`, `mode: docs`).

Each project defines its own domains. The agent honors what the invoker passes and reads only the relevant convention docs for the active domains. The anti-pattern catalog lives in `docs/conventions/<domain>/` files, not in the agent — the agent is a *runner* against project-specific rules.

**Refuse combined-review dispatches.** If the dispatch prompt asks for spec compliance + code quality + pattern review in one call, the agent emits a structured refusal. Three separate dispatches preserve the gating discipline.

**Known drift surface.** A doc (typically `docs/conventions/<domain>/known-drift.md`) lists pre-existing violations that the agent should not re-flag. Updates to that surface happen on the terminal pattern-compliant round only — adding/removing items mid-loop creates thrash.

**Anti-closure rule:** classification bar is constant across rounds. Round 5 pattern-compliant meets the same standard as round 1.

## Real workflow snippet

Example `AGENTS.md` block on the SDD review loop:

```markdown
## Implementation review sub-loop

When using the subagent-driven-development workflow:

1. **Spec compliance review** — separate dispatch with a spec-compliance prompt.
2. **Code quality review** — separate dispatch with a code-quality prompt.
3. **Pattern review** — `pattern-reviewer` against the task's diff, with `mode:` matching the touched surface (e.g. `mode: backend`, `mode: frontend`, `mode: auto`).
4. **Test quality review** — `test-quality-reviewer` (`mode: diff`) against the task's diff, checking test-code trustworthiness and design.

If pattern review flags issues, the implementer fixes them. Pattern re-review confirms the fix. If the fix was structural (new files, changed interfaces, extracted config layer), loop back to code quality review before final pattern re-review. If the fix was mechanical (field vs property, switch arm, namespace swap), skip back to pattern re-review.

Each review stage is a separate dispatch. Do not collapse the four into a single agent call.
```

Example dispatch shape:

> Dispatch `pattern-reviewer` with `mode: backend` against the current diff. Spec compliance and code quality reviews have already passed.

## Pitfalls observed

- **Combined-review dispatches.** Dispatchers occasionally try to bundle "spec + code-quality + pattern" into one prompt. The agent refuses by design. Adapt the orchestration; don't relax the refusal.
- **Wrong mode for mixed diffs.** A diff that touches both backend and frontend, dispatched with `mode: backend`, will list the frontend files as "Not reviewed by this mode" and need a second dispatch. Use `mode: auto` for genuinely mixed work.
- **Editing known-drift mid-loop.** Adding or removing entries during a non-terminal round creates thrash where an entry is added one round and removed the next. Apply pending updates only on the terminal pattern-compliant round.
- **Treating pattern-reviewer as a code-quality reviewer.** It is narrower — it checks pattern conformance, not correctness or readability. If a finding sounds like "this method could be cleaner," that's code-quality territory.
- **Cross-task SendMessage-resume.** Each task's pattern review is a fresh dispatch. The reviewer-session-continuation rule applies to revision rounds **on the same task**, not across tasks.
- **Silent no-op on an unrecognized surface.** A review stage produces false confidence not only by mis-judging code but by never examining it. In the originating project a whole recurring category of work lived in a repo-local automation/scripts directory the domain layout never covered — `mode: auto` classified those files into no domain, recorded them "not reviewed," and the stage emitted a non-failing verdict. Large diffs passed a mandatory review gate that had enforced nothing on them. The **Domain coverage gaps** rule in the canonical spec is the fix: files matching no defined domain are a coverage-gap *finding*, not a clean pass, and the recurring uncovered directory is the signal to extend the domain layout.

## Adaptation notes

- The mode list is project-specific. The originating project uses `unity` and `portal` for its two domains; your project might use `backend` / `frontend` / `infra` / `docs` or whatever fits.
- The anti-pattern catalog in the canonical spec is **a template**, not the actual list. Your project's `docs/conventions/<domain>/` files own the real rules. The agent enforces what's documented; if a rule appears in the agent's template but isn't in your conventions, raise it as an observation rather than a finding.
- The refuse-combined-review section is unusually load-bearing — adopt it verbatim. The originating project's history shows that combined-review prompts erode review-stage gating quickly.
- The known-drift surface is a project-specific convention. If your project doesn't yet have one, the first time `pattern-reviewer` flags pre-existing code drift not introduced by the current diff, that's the moment to start one.
- Domain-specific cheap pattern checks (e.g. greps for `\bany\b` in TypeScript live-debug UI, or convention-guard scripts for new ConfigSO files) are project-specific. Document them in your `docs/conventions/<domain>/` files; the agent will run what's documented.
