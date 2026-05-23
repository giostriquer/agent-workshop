# Decision: add a manifest-backed agent marketplace

**Date:** 2026-05-23

## Status

Draft for operator review.

## Context

`agent-workshop` currently works as a curated scaffold: users read the docs, choose
agents and skills, then copy the relevant `.claude/`, `.codex/`, `.gemini/`, and
`.opencode/` files into an adopting project. That is sufficient for a small
manual scaffold, but it does not give adopters a clear catalog view of maturity,
pack membership, prerequisites, host support, or project-specific profile slots.

Recent cross-repo comparison showed the same pattern across local projects:

- `spec-reviewer` is a strong portable baseline, while Beacon, Umbra, and
  Conosterm carry project-specific product, domain, and review-depth profiles.
- `pattern-reviewer` is portable only when the adopting project defines its
  domain modes.
- `test-quality-reviewer` is now a strong portable baseline, but coverage,
  CRAP, property-testing, mutation-testing, and high-impact scrutiny need
  project-specific policy values.
- documentation, governance, research, and visual agents have different
  authority levels and should not all be installed as a single default bundle.

The marketplace should make those distinctions explicit without turning this
repo into an installer-first product.

## Goal

Add a marketplace layer that lets an operator choose agent packs for a new
repository from a machine-readable catalog, understand the required project
profile values, and copy only the agents, skills, wrappers, and conventions that
earn their keep.

## Non-goals

- Build a CLI installer in the first slice.
- Add a long-running service, registry server, MCP server, or package manager.
- Make every agent mandatory for every adopting project.
- Bake Beacon, Umbra, Conosterm, chat-service, or wiki-specific details into
  canonical agents.
- Promise backward compatibility for the catalog schema before it has been used
  in real adoptions.

## Design summary

The marketplace is manifest-first and docs-backed.

The first implementation adds:

- `marketplace/catalog.json` as the canonical machine-readable catalog.
- `docs/marketplace/README.md` for operator-facing adoption flow.
- `docs/marketplace/packs.md` for the initial pack definitions.
- `docs/marketplace/agent-profiles.md` for profile slots and examples.
- README/setup/docs index links so the marketplace is discoverable.

No installer is added yet. The manifest is still valuable immediately because it
defines a concrete contract for packs, maturity labels, permissions, profile
requirements, and host-wrapper support. Future validation or installation
scripts can build on the same file instead of scraping prose.

## Catalog shape

`marketplace/catalog.json` is the source of truth for marketplace entries.

Top-level fields:

- `schemaVersion`: numeric schema version, starting at `1`.
- `generated`: `false`; this catalog is maintained by hand until a script exists.
- `packs`: object keyed by pack id.
- `agents`: object keyed by agent id.

Pack entry fields:

- `title`: human-readable pack name.
- `description`: one or two sentences explaining when to adopt the pack.
- `defaultInstall`: boolean. `true` only when a pack is a reasonable starting
  point for most projects that use agent-driven workflow.
- `agents`: ordered agent ids.
- `requiresDecision`: boolean. `true` when the operator should consciously opt
  in because the pack is high-authority or specialized.

Agent entry fields:

- `title`: human-readable name.
- `canonicalPath`: path to the canonical Claude agent definition.
- `originDoc`: path to the explanatory origin doc.
- `role`: one of `review-only`, `retrieval-only`, `docs-edit`,
  `asset-edit`, `research-write`, or `governance-review`.
- `maturity`: one of `core`, `profile-required`, `specialized`, or
  `experimental`.
- `packs`: pack ids that include the agent.
- `hostSupport`: object with booleans for `claude`, `codex`, `gemini`, and
  `opencode`.
- `wrapperPaths`: paths for supported non-canonical wrappers.
- `requires`: named prerequisites the adopting project must satisfy.
- `profileSlots`: named project-specific settings the operator must fill or
  explicitly decline.
- `adoptionNotes`: short notes that explain safe use and common omissions.

The catalog intentionally stores paths and compact metadata, not the full agent
body. The canonical specs remain under `.claude/agents/`.

## Initial packs

### `review-core`

Agents:

- `spec-reviewer`
- `pattern-reviewer`
- `test-quality-reviewer`

Purpose: pre-implementation and post-implementation review gates for projects
that use specs, plans, and implementation review loops.

Install stance: reasonable default once the project has a spec-driven workflow.
Not mandatory for tiny scripts or exploratory repos.

### `docs-core`

Agents:

- `doc-indexer`
- `wiki-maintainer`

Purpose: documentation retrieval, routing, audit, and diff-driven doc updates.

Install stance: useful once the project has enough docs that routing and
source-of-truth maintenance are real costs. Requires a docs root and doc-routing
policy.

### `governance`

Agents:

- `vigil`

Purpose: advisory review of the agent, skill, wrapper, and workflow-instruction
layer itself.

Install stance: opt-in for repos with multiple agents, multiple hosts, or
meaningful workflow churn.

### `specialized`

Agents:

- `research`
- `visual-implementer`

Purpose: structured research notes and approved visual-asset execution.

Install stance: opt-in only. These agents require companion workflow contracts:
`research` needs a skill-owned brief schema, while `visual-implementer` needs a
visual baseline, allowed asset surfaces, and verification commands.

## Profile slots

Profile slots are the mechanism that keeps canonical agents generic while
allowing project-specific behavior.

Required profile slots for the first marketplace version:

- `sourcePriorityDocs`: source-of-truth docs the agent should read first.
- `specPaths`: where design specs live.
- `planPaths`: where implementation plans live.
- `patternDomains`: domain modes and convention docs for `pattern-reviewer`.
- `testQualityPolicy`: coverage targets, CRAP target policy, mutation/property
  expectations, and high-impact surfaces for `test-quality-reviewer`.
- `docsRoot`: documentation root and source-of-truth hierarchy.
- `docRoutingPolicy`: when to dispatch `doc-indexer` versus reading directly.
- `changeLogPolicy`: whether and where meaningful changes are recorded.
- `wrapperPolicy`: host support and canonical-host choice.
- `visualBaseline`: approved visual baseline docs and proof requirements.
- `researchBriefSchema`: required fields for research dispatch briefs.
- `agentAuditScope`: what local agent/skill/wrapper surfaces `vigil` audits.

An adopting project may explicitly mark a slot as `not-applicable`. Omitting a
required slot silently is a configuration smell and should be flagged by future
validation tooling.

## Cross-repo examples

Examples should appear in docs, not in canonical specs:

- Beacon-style product-boundary checks belong in a profile example for
  `spec-reviewer` and `pattern-reviewer`.
- Umbra-style Unity, portal, and visual verification checks belong in a profile
  example for domain-heavy projects.
- Conosterm-style higher-impact terminal/product checks belong in profile
  examples for `test-quality-reviewer`.
- chat-service backend/documentation routing belongs in docs-core examples.

These examples should be compact and sanitized. The marketplace must not copy
private project paths or domain decisions into canonical agent definitions.

## Adoption flow

1. Read `docs/marketplace/README.md`.
2. Choose one or more packs from `docs/marketplace/packs.md`.
3. Read each selected agent's origin doc.
4. Fill the required profile slots in the adopting project's `CLAUDE.md` and
   `AGENTS.md`, plus any project-specific convention docs.
5. Copy canonical specs and host wrappers for selected agents.
6. Copy required skills and skill mirrors separately when a selected agent
   depends on a skill-owned workflow.
7. Run a manual parity check: every selected catalog entry has its canonical
   file, origin doc, wrappers for supported hosts, and documented profile slots.
8. Use the pack in real work, then prune agents that do not earn their keep.

## Validation expectations

The first slice does not need an executable validator, but it should keep the
catalog strict enough that a validator can be added later.

Manual validation rules:

- Every `agents.<id>.canonicalPath` exists.
- Every `agents.<id>.originDoc` exists.
- Every wrapper path listed in `wrapperPaths` exists.
- Every pack agent id exists in `agents`.
- Every agent pack id exists in `packs`.
- Every agent with `role: docs-edit`, `asset-edit`, or `research-write` has
  `requiresDecision: true` on at least one containing pack or has a clear
  adoption note explaining the opt-in requirement.
- Every `profileSlots` value is documented in
  `docs/marketplace/agent-profiles.md`.

Future validator scripts may enforce these rules but should not become a
runtime dependency for adopters.

## Documentation updates

The implementation should update:

- `README.md` so the marketplace appears in "What's here" and adoption flow.
- `docs/setup.md` so new adopters start from packs and profile slots rather
  than a raw copy list.
- `docs/agents/README.md` so each agent's roster row can be understood as part
  of one or more marketplace packs.
- `docs/change-log.md` with a compact entry when the marketplace lands.

## Acceptance criteria

- The catalog exposes all eight canonical agents.
- The four initial packs are documented and represented in the catalog.
- Each cataloged agent declares role, maturity, host support, source paths,
  prerequisites, profile slots, and adoption notes.
- Marketplace docs explain why project-specific behavior belongs in profiles,
  not canonical specs.
- Setup docs route adopters through pack selection before copying files.
- No canonical agent behavior changes are required for the first slice.
- No new runtime or dev dependency is introduced.

## Risks

- **Catalog drift:** metadata may fall out of sync with files. Mitigation: keep
  validation rules explicit and add an executable validator in a later slice if
  drift appears.
- **Over-installation:** packs could make adopters copy too much. Mitigation:
  label default versus opt-in packs and keep `requiresDecision` visible.
- **Domain leakage:** examples from local repos could make the scaffold feel
  project-specific. Mitigation: examples live in docs/profile examples and stay
  compact, sanitized, and clearly optional.
- **Installer pressure:** a catalog can invite premature automation. Mitigation:
  first slice remains manifest plus docs; no installer until repeated manual
  adoption exposes the actual useful workflow.

## Open policy decisions

For the first slice, settle these policies as written:

- `review-core` is not universal, but it is the default once a project adopts a
  spec-driven development loop.
- `docs-core` is opt-in for projects with meaningful docs, not a universal
  default.
- `governance` and `specialized` are explicit opt-in packs.
- Canonical specs stay under `.claude/agents/`; the marketplace references
  them rather than moving them.
- The manifest is hand-maintained until a validator or installer has clear
  value.
