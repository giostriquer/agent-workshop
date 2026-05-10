# Conventions

Portable conventions that govern how the agents and skills compose. Each convention is a doc in this directory; adopting projects pick which to use and write equivalents in their own `docs/conventions/`.

## Catalog

| Convention | Why it exists | When to adopt |
|---|---|---|
| [reviewer-session-continuation.md](reviewer-session-continuation.md) | Multi-round reviews must continue the same reviewer session, not respawn. | Always — every project with reviewer agents needs this. |
| [per-task-fresh-dispatches.md](per-task-fresh-dispatches.md) | Each new task gets fresh review-stage dispatches; cross-task SendMessage-resume is the cross-artifact mistake. | When using subagent-driven development with multiple sequential tasks. |
| [skill-parity.md](skill-parity.md) | Cross-host skill mirroring (`.claude/` → `.codex/` → `.gemini/`). | When your project supports multiple hosts. |
| [doc-routing.md](doc-routing.md) | Dispatch-vs-read-direct decision for `doc-indexer`. | When you adopt `doc-indexer`. |
| [scripts-discipline.md](scripts-discipline.md) | Authoring rules for repo-local `scripts/` content. | When your project has a substantial `scripts/` directory. |

## Adoption shape

These conventions reference paths and shapes that are deliberately generic. To adopt:

1. Read the convention doc.
2. Decide whether the convention applies (the "When to adopt" column above is a starting point).
3. Write a project-specific version under your project's `docs/conventions/` that references your paths and structure.
4. Reference your version from the agents and skills that depend on it.

Do not copy this scaffold's convention docs verbatim. The point is the *pattern*, not the specific phrasing.

## On the conventions themselves

These are not opinions. Every convention here came from a specific failure mode in lived-in use — a moment where a session did the wrong thing and the rule was the durable fix. The origin docs for the related agents and skills cover those failures in more detail.

If a convention here doesn't match a problem you've actually hit, you don't need it. Convention bloat is a real cost — every rule you adopt is one more thing every session has to honor.
