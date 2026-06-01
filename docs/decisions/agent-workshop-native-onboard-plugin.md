# Decision: add native marketplace onboarding plugin

**Date:** 2026-05-23

## Status

Draft for operator review.

## Context

`agent-workshop` now has a manifest-backed marketplace:

- `marketplace/catalog.json` defines agent packs, roles, maturity labels,
  prerequisites, host support, and profile slots.
- `docs/marketplace/` explains pack selection and profile adaptation.
- canonical agent definitions remain repo-local files under `.claude/agents/`,
  with host wrappers under `.codex/`, `.gemini/`, and `.opencode/`.

That is useful for manual adoption, but it is not yet a native marketplace
plugin. Beacon shows the host split clearly: Claude Code and Codex each have
native plugin marketplace surfaces, and their plugin payloads are not identical.

The next slice should make `agent-workshop` installable through native host
marketplaces without turning the plugin into a bundle of active global agents.
The plugin should install one skill that can inspect a target project, recommend
which repo-local agents to adopt, and then write/adapt those files only when the
operator explicitly approves apply mode.

## Goal

Add a native marketplace distribution layer for `agent-workshop` that exposes a
single onboarding skill, `agent-workshop-onboard`, in supported hosts. The skill
uses the existing marketplace catalog and bundled templates to guide a model
through project-specific agent adoption.

The plugin should answer: "Given this target repo and its workflow, which agents
should be installed, copied as-is, adapted, deferred, or skipped, and what exact
project-local definitions should be written?"

## Non-goals

- Do not expose all scaffold agents as active global/plugin agents.
- Do not auto-install agent packs on plugin installation.
- Do not add an MCP server.
- Do not add a long-running service, registry server, or CLI installer.
- Do not edit a target repo in default mode.
- Do not mutate user-level Claude, Codex, Gemini, or OpenCode config files.
- Do not make Beacon, Umbra, Conosterm, chat-service, or wiki-specific profiles
  default behavior.

## Distribution Shape

The native plugin is a bootstrapper, not the final agent surface.

It ships:

- one skill: `agent-workshop-onboard`
- the current `marketplace/catalog.json`
- reference copies of canonical agent specs, wrappers, skill specs, origin docs,
  and conventions as bundled resources/templates
- host plugin metadata for Claude Code and Codex
- documentation explaining how to invoke the onboarding skill in a target repo

Marketplace entries point at the slim `plugins/agent-workshop/` payload, not the
repo root. This keeps the scaffold's canonical `.claude/skills/` tree out of the
marketplace package. Bundled skill templates also avoid nested `SKILL.md`
filenames so plugin hosts do not discover them as active skills.

It does not ship active `agents/` entries in the plugin payload. Active agents
should be repo-local files written into the adopting project after the onboarding
skill has created an adoption plan and the operator approves `mode: apply`.

This preserves the main design boundary: agents are not universal runtime tools;
they are project-local workflow contracts.

## Host Packaging

### Claude Code

Claude marketplace wrapper and plugin payload:

```text
.claude-plugin/
  marketplace.json
plugins/
  agent-workshop/
    .claude-plugin/
      plugin.json
    skills/
      agent-workshop-onboard/
        SKILL.md
        references/
          catalog.json
          templates/
          docs/
    README.md
```

The Claude marketplace entry points at `./plugins/agent-workshop`. The Claude
plugin uses native skill discovery from that payload. The payload may include
only a `skills/` directory and does not need plugin-level `agents/` or
`.mcp.json`.

`plugin.json` should describe the plugin as a local agent-scaffold onboarding
assistant. It should not register MCP servers.

### Codex

Codex plugin payload:

```text
.agents/
  plugins/
    marketplace.json
plugins/
  agent-workshop/
    .codex-plugin/
      plugin.json
    skills/
      agent-workshop-onboard/
        SKILL.md
        agents/
          openai.yaml
        references/
          catalog.json
          templates/
          docs/
    README.md
```

The Codex marketplace entry points at `./plugins/agent-workshop`. The Codex
plugin exposes only the onboarding skill. It does not expose apps or MCP
servers.

The Codex plugin manifest should list capability `Skills` only.

### Other Hosts

Gemini and OpenCode support remains template output, not native marketplace
delivery in this slice. The onboarding skill can generate `.gemini/` and
`.opencode/` repo-local wrappers when the target project asks for those hosts,
but the plugin distribution is Claude/Codex first.

## Skill Name And Modes

Skill name:

- `agent-workshop-onboard`

Modes:

- `mode: plan` - default. Inspect target repo, recommend adoption, and produce a
  proposed file-change plan. Must not write files.
- `mode: apply` - write the approved repo-local files. Requires explicit
  operator approval of the adoption plan.
- `mode: audit` - inspect an existing adoption for drift: missing wrappers,
  stale profiles, canonical/spec drift, missing conventions, and agents that no
  longer earn their keep.
- `mode: explain` - answer questions about packs, profile slots, or agent
  boundaries without inspecting or writing files.

Only `mode: apply` may modify files.

## Plan Mode Contract

`mode: plan` runs in a target project and produces an adoption plan.

Required inputs:

- target repo root (normally current working directory)
- requested pack(s), agent(s), or workflow goal
- supported host(s), if known
- whether the target project wants spec-driven development, docs maintenance,
  governance review, research notes, or visual asset execution

The skill should inspect:

- root workflow instructions: `AGENTS.md`, `CLAUDE.md`, and equivalent host docs
- existing `.claude/`, `.codex/`, `.gemini/`, `.opencode/` folders
- existing docs roots and conventions
- current test tooling and coverage/quality policy docs when relevant
- existing change-log or decision-log conventions
- existing plugin or marketplace declarations
- project risk/impact notes when present

The output must classify each candidate agent:

- `copy-as-is` - canonical scaffold can be copied with only path-neutral
  wrapper updates.
- `profile-required` - agent is suitable but needs project profile values before
  it becomes useful.
- `needs-local-definition` - the project needs a narrower local variant or extra
  convention docs before adoption.
- `defer` - likely useful later, but not enough supporting workflow exists now.
- `skip` - the project does not currently have the problem the agent solves.

The output must include:

- selected packs and agents
- per-agent classification and rationale
- required profile slots
- files proposed for create/modify
- exact source template for each proposed file
- conventions or docs the target repo must add before the agent becomes a gate
- host wrappers to generate
- risks and omissions
- explicit approval prompt for `mode: apply`

## Apply Mode Contract

`mode: apply` may write files only when the operator has approved a concrete
plan from the same session or has supplied an approved plan file.

Apply mode must:

1. Re-read the approved plan.
2. Re-check target repo status and report dirty unrelated files.
3. Refuse if the approved plan does not name exact files.
4. Refuse if the target repo has conflicting uncommitted changes in files the
   plan wants to modify.
5. Write only the approved file set.
6. Preserve unrelated content in existing `AGENTS.md`, `CLAUDE.md`, and docs.
7. Prefer project-local definitions over global/user-level edits.
8. Run the planned validation checks.
9. Report changed files, skipped files, validation results, and follow-up
   profile gaps.

Apply mode should not commit automatically unless the operator asks for commit
behavior in the approved plan.

## Audit Mode Contract

`mode: audit` checks an existing adoption.

It should verify:

- repo-local agents match the intended marketplace catalog entries or document
  their local divergence
- wrappers point at the chosen canonical host files
- skills are mirrored when the project supports multiple skill-loading hosts
- profile slots are present or explicitly marked `not-applicable`
- `AGENTS.md` and `CLAUDE.md` agree on workflow rules that fire during sessions
- no plugin-global agent is being mistaken for the repo-local agent
- stale agents that no longer earn their keep are called out for removal

Audit mode reports findings only. It does not fix them.

## Template And Reference Layout

The plugin needs bundled references, but those references must not become active
agents merely because the plugin is installed.

Recommended reference layout inside the skill:

```text
skills/agent-workshop-onboard/
  SKILL.md
  agents/
    openai.yaml
  references/
    catalog.json
    agents/
      doc-indexer.md
      pattern-reviewer.md
      research.md
      spec-reviewer.md
      test-quality-reviewer.md
      vigil.md
      visual-implementer.md
      wiki-maintainer.md
    wrappers/
      codex/
      gemini/
      opencode/
    skills/
      agent-audit.md
      change-log.md
      doc-audit.md
      push.md
      research.md
      visual-advisor.md
    docs/
      agents/
      skills/
      conventions/
      marketplace/
```

The onboarding skill reads from `references/` and writes selected content into
the target repo. Hosts should not auto-discover `references/agents/` as active
agent definitions or `references/skills/` as active skill definitions.

## Project Profile Output

The onboarding plan should generate a project profile section that can be pasted
or written into `AGENTS.md` / `CLAUDE.md`.

Profile section shape:

```markdown
## Agent Workshop Profile

Selected packs:
- review-core

Supported hosts:
- Claude Code
- Codex

Profile slots:
- sourcePriorityDocs: README.md, AGENTS.md, docs/README.md
- specPaths: docs/superpowers/specs/
- planPaths: docs/superpowers/plans/
- patternDomains:
  - mode: backend -> docs/conventions/backend.md
  - mode: docs -> docs/conventions/docs.md
- testQualityPolicy:
  - coverageTarget: project-defined
  - crapTarget: <= 6 when valid per-method CRAP data exists
  - highImpactSurfaces: <project-defined>

Installed agents:
- spec-reviewer: profile-required
- pattern-reviewer: needs-local-definition until patternDomains docs exist
- test-quality-reviewer: profile-required
```

This section is a generated starting point, not a hidden config file. Operators
can edit it directly.

## Safety Rules

- Default to `mode: plan`.
- Do not write files without explicit `mode: apply` approval.
- Do not install agents that the project does not have supporting workflow for.
- Do not install `visual-implementer` unless a visual baseline and proof path
  exist or are part of the approved plan.
- Do not install `research` unless a project-owned brief schema exists or is
  part of the approved plan.
- Do not make `pattern-reviewer` a required gate until pattern domains and
  convention docs exist.
- Do not treat average coverage as enough for high-impact surfaces.
- Do not derive CRAP from coverage data unless complexity values are valid.
- Do not edit user/global host config.
- Do not copy private local project paths from examples into target repos.
- Do not overwrite existing repo-local agents without reporting the local diff
  and obtaining approval.

## Validation Expectations

The implementation should add lightweight validation, preferably without new
runtime dependencies.

Validator checks:

- plugin payload includes exactly one active skill
- plugin payload includes no active agents
- the bundled reference catalog matches `marketplace/catalog.json`
- every cataloged canonical agent has a bundled reference copy
- every cataloged wrapper path has a bundled reference copy
- Claude plugin manifest exists and contains no MCP registration
- Codex marketplace and plugin manifests exist and expose skill-only capability
- Codex `agents/openai.yaml` points at `agent-workshop-onboard`
- docs explain `plan`, `apply`, `audit`, and `explain` modes
- no generated/adoption docs imply automatic installation on plugin install

## Documentation Updates

Implementation should update:

- `README.md` with native marketplace install overview.
- `docs/marketplace/README.md` with the plugin/onboarding path.
- `docs/setup.md` so manual copy remains available but is no longer the only
  path.
- `docs/change-log.md` when the plugin lands.
- A new plugin-specific doc, likely `docs/marketplace/native-plugin.md`.

## Acceptance Criteria

- Claude Code can install the local plugin and discover only
  `agent-workshop-onboard`.
- Codex can install the local plugin and discover only
  `agent-workshop-onboard`.
- Installing the plugin does not expose the eight scaffold agents globally.
- `agent-workshop-onboard mode: plan` can inspect a target repo and produce an
  adoption plan without writing files.
- `agent-workshop-onboard mode: apply` writes only an explicitly approved file
  set.
- The skill can classify agents as `copy-as-is`, `profile-required`,
  `needs-local-definition`, `defer`, or `skip`.
- The skill can generate repo-local `.claude` canonical agents and selected
  host wrappers from bundled references.
- The implementation includes validation proving plugin payloads and bundled
  references do not drift from `marketplace/catalog.json`.
- No MCP server, runtime service, or dependency is introduced unless a later
  design explicitly approves it.

## Open Decisions

Settled for this slice:

- The plugin installs one onboarding skill, not the agent pack itself.
- `mode: apply` is allowed to write project-local files after explicit approval.
- Claude and Codex are the first native marketplace targets.
- Gemini and OpenCode remain generated wrapper targets, not native plugin
  install targets.
- References live under the onboarding skill and are not active agents.

Still to decide during implementation planning:

- Exact plugin display names and version numbers.
- Whether bundled references are copied mechanically from source files or
  maintained as separate committed payload copies.
- Whether validation is a PowerShell script, a Node script using built-ins, or
  documented shell checks only.
- Whether `mode: apply` may commit when the approved plan explicitly asks for a
  commit.
