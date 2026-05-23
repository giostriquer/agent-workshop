# Agent Profiles

Profiles are the project-specific values that make marketplace agents safe to
adopt without baking local domain rules into the canonical specs.

An adopting project should write profile values into its `CLAUDE.md`,
`AGENTS.md`, and relevant `docs/conventions/` files. A value may be marked
`not-applicable`, but it should not be silently omitted when a selected pack
requires it.

## Profile slots

| Slot | Purpose |
|---|---|
| `sourcePriorityDocs` | Source-of-truth docs the agent should read first. |
| `specPaths` | Where design specs live. |
| `planPaths` | Where implementation plans live. |
| `patternDomains` | Pattern-review modes and their convention docs. |
| `testQualityPolicy` | Coverage target, CRAP policy, property/mutation expectations, and high-impact surfaces. |
| `docsRoot` | Documentation root and source-of-truth hierarchy. |
| `docRoutingPolicy` | When to dispatch `doc-indexer` versus reading directly. |
| `changeLogPolicy` | Whether and where meaningful changes are recorded. |
| `wrapperPolicy` | Host support and canonical-host choice. |
| `visualBaseline` | Approved visual baseline docs and proof requirements. |
| `researchBriefSchema` | Required fields for research dispatch briefs. |
| `agentAuditScope` | Local agent, skill, wrapper, and workflow surfaces `vigil` audits. |

## Example profile fragments

### Product-boundary project

Use for projects where non-goals and safety boundaries are central.

```markdown
profile.specReviewer.productBoundaries:
- local-first
- no hidden remote control
- no cloud orchestration without explicit approval
- source-of-truth state lives under `.project-state/`
```

### Domain-pattern project

Use for projects with multiple implementation surfaces.

```markdown
profile.patternReviewer.patternDomains:
- mode: backend
  docs: docs/conventions/backend.md
- mode: frontend
  docs: docs/conventions/frontend.md
- mode: docs
  docs: docs/conventions/docs.md
```

### High-impact test-quality project

Use for projects where weak tests on core behavior carry higher user or
operational risk.

```markdown
profile.testQualityPolicy:
  coverageTarget: project-defined
  crapTarget: "<= 6 when valid per-method CRAP data exists"
  propertyTesting: parsers, serializers, state transitions, permission matrices
  mutationTesting: targeted critical-path mutation or acceptance mutation
  highImpactSurfaces: terminal command execution, local state migration, billing/accounting, operator-visible status
```

### Documentation-heavy project

Use for projects where docs are source-of-truth, not just notes.

```markdown
profile.docs:
  docsRoot: docs/
  docRoutingPolicy: dispatch doc-indexer for routing, source discovery, and broad audits
  changeLogPolicy: record meaningful workflow, product, and agent-surface changes in docs/change-log.md
```

### Visual project

Use only when the project has approved visual proof artifacts.

```markdown
profile.visualBaseline:
  baselineDoc: docs/assets/current-baseline.md
  allowedSurfaces: approved generated assets, local cleanup, runtime wiring after approval
  proof: screenshot or runtime capture plus artifact path
```
