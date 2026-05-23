# Doc Routing

## Rule

When a question involves documentation routing — "which docs matter for X?" / "where is the source of truth for Y?" — decide between **dispatching `doc-indexer`** and **reading directly**:

| Question type | Action |
|---|---|
| "Where does the source of truth for system X live?" | Dispatch `doc-indexer` |
| "Which docs should I read before writing the spec for X?" | Dispatch `doc-indexer` |
| "Is there a routing or vault-hygiene drift after this reorg?" | Dispatch `doc-indexer` (audit mode) |
| "What is the formula for Y?" | Read directly — direct reading beats summary |
| "What does this specific decision record say?" | Read directly |
| "What does CLAUDE.md say about agent dispatch?" | Read directly |
| "I need to update doc X" | Dispatch `wiki-maintainer`, not `doc-indexer` |

The principle: **dispatch when the answer is a routing decision; read directly when the answer is content.**

## Why

`doc-indexer` is a routing and audit specialist. Its value comes from reading the minimum relevant set of docs and answering with a routing summary. That value is wasted on questions where:

- the caller needs the actual content (formula, value, decision rationale) — dispatching adds indirection and summary fidelity risk
- the answer requires editing — `doc-indexer` lacks edit tools by design
- the answer is in a doc the caller already has open

Direct reading is cheaper for content questions. Dispatch is right for routing questions.

## Cross-references

- `doc-indexer`'s canonical spec at `.claude/agents/doc-indexer.md` covers the agent's behavior.
- `wiki-maintainer`'s canonical spec at `.claude/agents/wiki-maintainer.md` covers the documentation owner.
- The two are distinct roles; the boundary is enforced at the tool layer (`doc-indexer` lacks edit tools).

## In your project's docs

Adopt this convention by writing a project-specific equivalent at `docs/conventions/docs/doc-routing.md`. Reference your project's specific dispatch examples and your project's specific source-of-truth doc list.

The shape that matters: **dispatch for routing questions; read directly for content questions; route edits to `wiki-maintainer`.**

## Audit-mode special case

When `doc-indexer` is dispatched in audit mode, its output ends with a `Recommended orchestrator action` line stating what should happen next (dispatch `wiki-maintainer`, ask user to confirm, or defer). The orchestrator (the model that dispatched `doc-indexer`) acts on this line — `doc-indexer` cannot dispatch other agents itself because subagents cannot spawn other subagents.

This is also a project-specific convention worth adopting verbatim — without the explicit "Recommended orchestrator action" line, audit findings often just sit unaddressed because the orchestrator forgot to follow up.
