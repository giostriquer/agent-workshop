# Marketplace Packs

Pack metadata is defined in [`marketplace/catalog.json`](../../marketplace/catalog.json).
This page explains how to choose between packs.

## Review Core

Agents:

- `spec-reviewer`
- `pattern-reviewer`
- `test-quality-reviewer`

Adopt this pack when the project uses a spec-driven loop: design spec, plan,
implementation, and separate review stages.

Profile requirements:

- `sourcePriorityDocs`
- `specPaths`
- `planPaths`
- `patternDomains`
- `testQualityPolicy`
- `wrapperPolicy`

This is the closest thing to a default pack, but it is not universal. Tiny
scripts, throwaway prototypes, and repos without a review loop can omit it.

## Docs Core

Agents:

- `doc-indexer`
- `wiki-maintainer`

Adopt this pack when the project has enough documentation that retrieval,
routing, audit, and diff-driven source-of-truth updates are recurring work.

Profile requirements:

- `sourcePriorityDocs`
- `docsRoot`
- `docRoutingPolicy`
- `changeLogPolicy`
- `wrapperPolicy`

This pack is edit-capable through `wiki-maintainer`, so adopt it deliberately.

## Governance

Agents:

- `vigil`

Adopt this pack when the project has multiple local agents, multiple host
wrappers, or enough workflow-instruction churn that the agent layer itself needs
review.

Profile requirements:

- `sourcePriorityDocs`
- `agentAuditScope`
- `wrapperPolicy`

This pack is not a general code-review pack.

## Specialized

Agents:

- `research`
- `visual-implementer`

Adopt this pack only when the project has the matching workflows.

Profile requirements:

- `sourcePriorityDocs`
- `researchBriefSchema`
- `visualBaseline`
- `wrapperPolicy`

`research` needs a companion skill-owned brief schema. `visual-implementer`
needs a visual baseline, allowed asset surfaces, and verification commands.
