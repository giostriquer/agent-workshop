# Scripts Discipline

## Rule

Repo-local scripts under `scripts/` (or equivalent) follow uniform authoring conventions:

1. **Document yourself.** Any new script added to the directory MUST add an entry to the directory's `README.md` in the same change set. A script without a README entry is incomplete.
2. **Honor the standard flag vocabulary.** Where applicable, all scripts honor the same flag names (`-Publish`, `-KeepHistory`, `-HistoryLabel`, etc. — adapt to your project's conventions).
3. **Use the standard artifact roots.** Transient artifacts go under `.temp/<tool>/`; durable artifacts go under `docs/diagnostics/<tool>/` (or your project's equivalent).
4. **Split helper libraries cleanly.** If a script grows past a reasonable size or develops a distinct sub-responsibility, extract to a sibling helper file (`<parent>.contract.ps1`, `<parent>.advisory.ps1`, etc.) and dot-source.

## Why

Scripts directory drift is a silent productivity tax. Without uniform conventions:

- Operators have to read each script's source to know how to invoke it.
- New scripts copy bad patterns from old ones.
- Output paths fragment (`some/.tmp`, `out/`, `.cache/`) — no consistency.
- Helper libraries get inlined into ever-growing parent scripts.

The discipline compounds: every new script that follows the convention saves the next operator (or model) a lookup.

## README entry shape

Each script entry should cover:

- **Purpose.** What the script does and why it exists.
- **Invocation.** The exact canonical command(s), including standard flags.
- **Parameters.** Every parameter with a one-line description and default value.
- **Outputs.** Every file the script writes, with absolute-from-repo paths. Distinguish transient from durable.
- **Role.** How the script fits into the project's workflow.
- **Related.** Pointers to the skill wrapper (if any), diagnostic route, and any supporting design spec.

## Blocking verification scripts

If a script blocks completion, merge, or routine verification, treat it like production code rather than glue:

- Include a happy-path run plus adversarial negative fixtures in the same implementation round.
- Cover valid syntax variants and ordinary file-content forms that could bypass a naive parser.
- Include path-shape edge cases when the script accepts path or root overrides.
- Prefer a small deterministic regression surface over one-off manual spot checks.

The minimum bar: it fails for the currently known real violation, AND it fails for synthetic variants representing valid local content shapes. Not just one idealized example.

## Tool-local scripts

Scripts that belong to a specific tool (`tooling/<tool>/scripts/`) document themselves in that tool's README rather than the top-level scripts README. Same documentation requirements, same artifact-root conventions, same standard flag vocabulary.

## In your project's docs

Adopt this convention with a project-specific equivalent at `docs/conventions/tooling/scripts-discipline.md`. Reference your project's scripts directory structure, standard flag names, and artifact roots.

The shape that matters: **uniform documentation, uniform flags, uniform artifact paths, uniform helper-library split pattern.** A script reviewer should be able to predict where outputs go and how invocation works without opening the script.

## Anti-pattern: invent-as-you-go

The most common scripts-discipline failure is inventing a new artifact root for one script ("just this once, I'll write to `out/special/`"). Once the precedent exists, others follow. Honor the standard roots even when it costs a few lines of refactor.
