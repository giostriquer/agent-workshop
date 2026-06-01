# reviewers

Direct-use Claude Code plugin from [Agent Workshop](https://github.com/giostriquer/agent-workshop).

Install this plugin when you want to **use** a curated set of Agent Workshop's
review and governance agents directly — without running the onboarding/adoption
flow. It ships only agents that work standalone in an arbitrary repo, with no
project profile slots to fill.

This is the counterpart to the `agent-workshop` plugin, whose `agent-workshop-onboard`
skill instead helps you adopt repo-local agent scaffolding into a project. That
onboarding skill is intentionally **not** part of this plugin.

## Agents

Installed agents are namespaced under the plugin, e.g. `reviewers:spec-reviewer`.

- **spec-reviewer** — pre-implementation review of a spec or plan you point it at.
- **test-quality-reviewer** — reviews a test diff for trustworthiness, risk coverage, and test design.
- **pattern-reviewer** — reviews a diff for implementation-pattern conformance. In a
  repo with no documented domain layout it falls back to discovery mode: it discovers
  convention docs under `docs/` or infers conventions from sibling files, labelling
  findings as lower-confidence.
- **vigil** — read-only governance review of a repo's agent / skill / wrapper layer.

## Not included

The profile-dependent and edit-capable agents (`doc-indexer`, `wiki-maintainer`,
`visual-implementer`, `research`) are not shipped here — they need project-specific
configuration or an approved baseline and belong to the onboarding adoption path.
