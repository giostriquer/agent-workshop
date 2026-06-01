# Native Marketplace Onboarding Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship native Claude/Codex marketplace packaging for `agent-workshop` that exposes one onboarding skill, not the scaffold agents themselves.

**Architecture:** Keep marketplace metadata at the repo root and make both Claude
Code and Codex marketplace entries point at the slim plugin payload under
`plugins/agent-workshop/`. Both plugin surfaces expose only
`agent-workshop-onboard`; bundled references live under that skill and are
copied from the canonical scaffold files. A PowerShell validator checks payload
shape, reference parity, and docs claims.

**Tech Stack:** Markdown, JSON, YAML, PowerShell built-ins, Git. No new runtime or dev dependencies.

---

## Settled Implementation Choices

- Plugin name: `agent-workshop`
- Version: `0.1.1`
- Active plugin skill: `agent-workshop-onboard`
- Native targets: Claude Code and Codex
- Bundled references: committed payload copies in both root `skills/` and slim
  marketplace payload `plugins/agent-workshop/skills/`; skill templates use
  non-discoverable `references/skills/<skill>.md` filenames
- Marketplace source: `./plugins/agent-workshop`, never repo root
- Validation: `scripts/validate-native-plugin.ps1`
- Apply-mode commit behavior: apply mode does not commit unless the approved plan explicitly requests a commit

## Files

Create:

- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`
- `.agents/plugins/marketplace.json`
- `plugins/agent-workshop/.claude-plugin/plugin.json`
- `plugins/agent-workshop/.codex-plugin/plugin.json`
- `plugins/agent-workshop/README.md`
- `skills/agent-workshop-onboard/SKILL.md`
- `plugins/agent-workshop/skills/agent-workshop-onboard/SKILL.md`
- `plugins/agent-workshop/skills/agent-workshop-onboard/agents/openai.yaml`
- `skills/agent-workshop-onboard/references/**`
- `plugins/agent-workshop/skills/agent-workshop-onboard/references/**`
- `scripts/validate-native-plugin.ps1`
- `docs/marketplace/native-plugin.md`

Modify:

- `README.md`
- `docs/marketplace/README.md`
- `docs/setup.md`
- `docs/change-log.md`

## Task 1: Add Native Plugin Manifests And Onboarding Skill

**Files:**

- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Create: `.agents/plugins/marketplace.json`
- Create: `plugins/agent-workshop/.claude-plugin/plugin.json`
- Create: `plugins/agent-workshop/.codex-plugin/plugin.json`
- Create: `plugins/agent-workshop/README.md`
- Create: `skills/agent-workshop-onboard/SKILL.md`
- Create: `plugins/agent-workshop/skills/agent-workshop-onboard/SKILL.md`
- Create: `plugins/agent-workshop/skills/agent-workshop-onboard/agents/openai.yaml`

- [ ] **Step 1: Confirm current repo has no native plugin payload**

Run:

```powershell
Get-ChildItem -Force .claude-plugin,.agents,plugins -ErrorAction SilentlyContinue
```

Expected: no existing plugin payload conflicts. If any target path exists, stop and inspect before writing.

- [ ] **Step 2: Create Claude plugin manifest**

Create `.claude-plugin/plugin.json`:

```json
{
  "name": "agent-workshop",
  "description": "Onboard repo-local AI agent scaffolding from Agent Workshop.",
  "version": "0.1.1",
  "author": { "name": "Agent Workshop" },
  "homepage": "https://github.com/giostriquer/agent-workshop",
  "repository": "https://github.com/giostriquer/agent-workshop",
  "license": "MIT",
  "keywords": ["agents", "skills", "scaffold", "onboarding"]
}
```

This root copy is kept in sync with the slim payload manifest. Do not add
`mcpServers`, `agents`, or command entries.

- [ ] **Step 3: Create Claude payload manifest**

Create `plugins/agent-workshop/.claude-plugin/plugin.json` with the same content
as `.claude-plugin/plugin.json`.

- [ ] **Step 4: Create Claude marketplace file**

Create `.claude-plugin/marketplace.json`:

```json
{
  "name": "agent-workshop",
  "description": "Local marketplace for Agent Workshop",
  "owner": { "name": "Agent Workshop" },
  "plugins": [
    {
      "name": "agent-workshop",
      "version": "0.1.1",
      "source": "./plugins/agent-workshop",
      "description": "Onboard repo-local agent scaffolding with one guided skill",
      "author": { "name": "Agent Workshop" }
    }
  ]
}
```

- [ ] **Step 5: Create Codex marketplace file**

Create `.agents/plugins/marketplace.json`:

```json
{
  "name": "agent-workshop",
  "interface": {
    "displayName": "Agent Workshop"
  },
  "plugins": [
    {
      "name": "agent-workshop",
      "source": {
        "source": "local",
        "path": "./plugins/agent-workshop"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Productivity"
    }
  ]
}
```

- [ ] **Step 6: Create Codex plugin manifest**

Create `plugins/agent-workshop/.codex-plugin/plugin.json`:

```json
{
  "name": "agent-workshop",
  "version": "0.1.1",
  "description": "Onboard repo-local AI agent scaffolding from Agent Workshop.",
  "author": {
    "name": "Agent Workshop",
    "url": "https://github.com/giostriquer/agent-workshop"
  },
  "license": "MIT",
  "homepage": "https://github.com/giostriquer/agent-workshop",
  "repository": "https://github.com/giostriquer/agent-workshop",
  "keywords": ["agents", "skills", "scaffold", "onboarding"],
  "skills": "./skills",
  "interface": {
    "displayName": "Agent Workshop",
    "shortDescription": "Onboard repo-local agent scaffolding.",
    "longDescription": "Agent Workshop gives Codex one onboarding skill that inspects a target repo, recommends repo-local agent adoption, and applies approved files. It does not expose the scaffold agents globally.",
    "developerName": "Agent Workshop",
    "category": "Productivity",
    "capabilities": ["Skills"],
    "websiteURL": "https://github.com/giostriquer/agent-workshop"
  }
}
```

Do not add `mcpServers`, `apps`, or active `agents`.

- [ ] **Step 7: Create onboarding skill body**

Create `skills/agent-workshop-onboard/SKILL.md` and copy it byte-identically to `plugins/agent-workshop/skills/agent-workshop-onboard/SKILL.md`:

```markdown
---
name: agent-workshop-onboard
description: Use when onboarding Agent Workshop agents into a repository, planning or applying repo-local agent packs, auditing existing agent-workshop adoption, or explaining pack/profile choices.
---

# Agent Workshop Onboard

This skill is the only active plugin surface for Agent Workshop. It does not make the scaffold's agents global. It helps an operator decide which repo-local agents, wrappers, skills, conventions, and profile definitions a target project should adopt.

Default to `mode: plan`. Only `mode: apply` may write files, and only after the operator approves a concrete plan from this session or supplies an approved plan file.

## Inputs

- `mode`: `plan` (default), `apply`, `audit`, or `explain`
- `target`: target repository root; default to the current working directory
- `packs`: optional requested packs from `references/catalog.json`
- `agents`: optional requested agent ids from `references/catalog.json`
- `hosts`: optional target hosts such as Claude Code, Codex, Gemini, or OpenCode
- `approved_plan`: required for `mode: apply`; either the plan produced in this session or a path to an approved plan file

## Mode: plan

Inspect the target repo and produce an adoption plan. Do not write files.

Read, when present:

- `AGENTS.md`, `CLAUDE.md`, and host-specific workflow docs
- `.claude/`, `.codex/`, `.gemini/`, `.opencode/`
- `docs/`, especially conventions, setup, decisions, change logs, and testing docs
- existing plugin or marketplace manifests
- test tooling and quality policy docs when `test-quality-reviewer` is a candidate

Classify each candidate agent:

- `copy-as-is`: canonical scaffold can be copied with only path-neutral wrapper updates
- `profile-required`: suitable, but project profile slots must be filled first
- `needs-local-definition`: suitable only after a narrower local variant or convention docs are written
- `defer`: likely useful later, but the supporting workflow does not exist yet
- `skip`: the project does not currently have the problem the agent solves

Return:

- selected packs and agents
- classification and rationale for each candidate
- required profile slots
- exact files proposed for create/modify
- source template for each proposed file or reference path to the bundled template
- validation checks to run after apply
- risks, omitted agents, and follow-up decisions
- explicit prompt asking whether to proceed with `mode: apply`

## Mode: apply

Apply only an approved plan. Refuse to write if there is no concrete approved plan.

Before writing:

1. Re-read the approved plan.
2. Run `git status --short` in the target repo when it is a git checkout.
3. Report unrelated dirty files.
4. Refuse if the plan lacks exact file paths.
5. Refuse if any target file has conflicting uncommitted changes not accounted for in the plan.

When writing:

- write only files named in the approved plan
- preserve unrelated sections in existing `AGENTS.md`, `CLAUDE.md`, and docs
- prefer repo-local `.claude/`, `.codex/`, `.gemini/`, and `.opencode/` files
- never edit user/global host config
- never copy private local project paths from examples into the target repo
- do not commit unless the approved plan explicitly asks for a commit

After writing:

- run the approved validation checks
- report changed files, skipped files, validation output, and remaining profile gaps

## Mode: audit

Inspect an existing Agent Workshop adoption and report drift. Do not write files.

Check:

- installed agents versus `references/catalog.json`
- local divergence from bundled references
- wrapper pointers and host support
- skill mirrors when multiple hosts are supported
- required profile slots
- agreement between `AGENTS.md` and `CLAUDE.md`
- stale agents that no longer earn their keep
- plugin-global agents accidentally replacing repo-local agents

## Mode: explain

Answer questions about packs, profile slots, host wrappers, or agent boundaries. Use `references/catalog.json` and bundled docs as the source model.

## Safety Rules

- Default to read-only planning.
- Do not install all agents by default.
- Do not install `pattern-reviewer` as a gate until pattern domains and convention docs exist.
- Do not install `visual-implementer` unless a visual baseline and proof path exist or are in the approved plan.
- Do not install `research` unless a project-owned research brief schema exists or is in the approved plan.
- Do not derive CRAP from coverage data unless complexity values are valid.
- Treat high-impact surfaces as profile-specific; average coverage is not enough.
- Do not overwrite existing local agents without showing the local diff and getting approval.

## Bundled References

Bundled templates live under `references/` inside this skill. They are source material for repo-local adoption, not active plugin agents.
```

- [ ] **Step 8: Create Codex skill wrapper**

Create `plugins/agent-workshop/skills/agent-workshop-onboard/agents/openai.yaml`:

```yaml
interface:
  display_name: "Agent Workshop Onboard"
  short_description: "Plan or apply repo-local Agent Workshop adoption"
  default_prompt: "Use $agent-workshop-onboard to inspect this target repo, recommend Agent Workshop packs and profile slots, and apply only an explicitly approved repo-local adoption plan. Default to mode: plan. Do not expose or install all scaffold agents globally."
```

- [ ] **Step 9: Create Codex plugin README**

Create `plugins/agent-workshop/README.md`:

```markdown
# Agent Workshop Plugin

This plugin exposes one skill: `agent-workshop-onboard`.

The skill plans, applies, audits, or explains repo-local adoption of Agent Workshop agents. Installing this plugin does not install the scaffold agents globally. Use `mode: plan` in a target repo first, then approve `mode: apply` only when the proposed file set is correct.
```

- [ ] **Step 10: Verify Task 1**

Run:

```powershell
git diff --check
git status --short
```

Expected: only Task 1 files are new or modified.

- [ ] **Step 11: Commit Task 1**

Run:

```powershell
git add -- .claude-plugin .agents/plugins/marketplace.json plugins/agent-workshop/.claude-plugin plugins/agent-workshop/.codex-plugin plugins/agent-workshop/README.md plugins/agent-workshop/skills/agent-workshop-onboard skills/agent-workshop-onboard/SKILL.md
git commit -m "feat: add agent-workshop onboarding plugin shell"
```

## Task 2: Populate Bundled References

**Files:**

- Create: `skills/agent-workshop-onboard/references/**`
- Create: `plugins/agent-workshop/skills/agent-workshop-onboard/references/**`

- [ ] **Step 1: Copy canonical references into root skill**

Use PowerShell `Copy-Item` to create:

```text
skills/agent-workshop-onboard/references/catalog.json
skills/agent-workshop-onboard/references/agents/*.md
skills/agent-workshop-onboard/references/wrappers/codex/*.toml
skills/agent-workshop-onboard/references/wrappers/gemini/*.md
skills/agent-workshop-onboard/references/wrappers/opencode/*.md
skills/agent-workshop-onboard/references/skills/<skill>.md
skills/agent-workshop-onboard/references/docs/agents/*.md
skills/agent-workshop-onboard/references/docs/skills/*.md
skills/agent-workshop-onboard/references/docs/conventions/*.md
skills/agent-workshop-onboard/references/docs/marketplace/*.md
```

Source files:

- `marketplace/catalog.json`
- `.claude/agents/*`
- `.codex/agents/*`
- `.gemini/agents/*`
- `.opencode/agents/*`
- `.claude/skills/*/SKILL.md`
- `docs/agents/*`
- `docs/skills/*`
- `docs/conventions/*`
- `docs/marketplace/*`

- [ ] **Step 2: Copy root skill references into marketplace plugin skill**

Copy `skills/agent-workshop-onboard/references/` to `plugins/agent-workshop/skills/agent-workshop-onboard/references/`.

- [ ] **Step 3: Verify reference parity**

Run:

```powershell
Compare-Object `
  (Get-ChildItem -Recurse -File skills/agent-workshop-onboard/references | ForEach-Object { $_.FullName.Substring((Resolve-Path 'skills/agent-workshop-onboard/references').Path.Length + 1) } | Sort-Object) `
  (Get-ChildItem -Recurse -File plugins/agent-workshop/skills/agent-workshop-onboard/references | ForEach-Object { $_.FullName.Substring((Resolve-Path 'plugins/agent-workshop/skills/agent-workshop-onboard/references').Path.Length + 1) } | Sort-Object)
```

Expected: no output.

- [ ] **Step 4: Commit Task 2**

Run:

```powershell
git add -- skills/agent-workshop-onboard/references plugins/agent-workshop/skills/agent-workshop-onboard/references
git commit -m "feat: bundle onboarding reference templates"
```

## Task 3: Add Native Plugin Validator

**Files:**

- Create: `scripts/validate-native-plugin.ps1`

- [ ] **Step 1: Add validator script**

Create `scripts/validate-native-plugin.ps1`. It must:

- parse `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `plugins/agent-workshop/.claude-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `plugins/agent-workshop/.codex-plugin/plugin.json`, and `marketplace/catalog.json`
- fail if `.claude-plugin/plugin.json` contains `mcpServers`
- fail if the Claude marketplace source is not `./plugins/agent-workshop`
- fail if `plugins/agent-workshop/.claude-plugin/plugin.json` contains `mcpServers` or `agents`
- fail if `plugins/agent-workshop/.codex-plugin/plugin.json` contains `mcpServers` or `apps`
- fail if the Codex manifest does not set `skills` to `./skills`
- fail if the plugin payload contains any `SKILL.md` file other than `plugins/agent-workshop/skills/agent-workshop-onboard/SKILL.md`
- fail if any plugin payload contains active `agents/` outside `plugins/agent-workshop/skills/agent-workshop-onboard/agents/openai.yaml`
- fail if root/Codex skill `SKILL.md` files differ
- fail if root/Codex reference file lists differ
- fail if any reference copy differs from the source file it is supposed to mirror
- fail if every cataloged agent is not represented under `references/agents/`
- print `native plugin validation ok` on success

- [ ] **Step 2: Run validator**

Run:

```powershell
.\scripts\validate-native-plugin.ps1
```

Expected:

```text
native plugin validation ok
```

- [ ] **Step 3: Run diff check and commit**

Run:

```powershell
git diff --check
git add -- scripts/validate-native-plugin.ps1
git commit -m "test: validate native onboarding plugin payload"
```

## Task 4: Add Plugin Documentation

**Files:**

- Create: `docs/marketplace/native-plugin.md`
- Modify: `README.md`
- Modify: `docs/marketplace/README.md`
- Modify: `docs/setup.md`
- Modify: `docs/change-log.md`

- [ ] **Step 1: Create native plugin docs**

Create `docs/marketplace/native-plugin.md` explaining:

- native plugin install is Claude/Codex first
- the plugin exposes only `agent-workshop-onboard`
- installing the plugin does not install global scaffold agents
- `mode: plan` is read-only default
- `mode: apply` writes only an approved file set
- `mode: audit` checks drift
- `mode: explain` answers catalog/profile questions
- manual copy remains available

- [ ] **Step 2: Update `README.md`**

Add the native plugin to "What's here" and "How to use it". Keep manual setup references.

- [ ] **Step 3: Update marketplace and setup docs**

Update `docs/marketplace/README.md` and `docs/setup.md` so native onboarding is the preferred guided path and manual copying remains available.

- [ ] **Step 4: Update change log**

Add a compact `2026-05-23` entry for the native onboarding plugin.

- [ ] **Step 5: Verify and commit**

Run:

```powershell
rg -n "agent-workshop-onboard|native plugin|mode: plan|mode: apply" README.md docs/marketplace docs/setup.md docs/change-log.md
git diff --check
.\scripts\validate-native-plugin.ps1
git add -- README.md docs/marketplace/README.md docs/marketplace/native-plugin.md docs/setup.md docs/change-log.md
git commit -m "docs: document native onboarding plugin"
```

## Task 5: Final Verification

**Files:**

- Verify all implementation files.

- [ ] **Step 1: Run validator**

Run:

```powershell
.\scripts\validate-native-plugin.ps1
```

Expected:

```text
native plugin validation ok
```

- [ ] **Step 2: Run repository checks**

Run:

```powershell
git diff --check
git status --short
git log --oneline -8
```

Expected:

- `git diff --check` prints nothing.
- `git status --short` prints nothing.
- recent log includes the native plugin commits after `docs: design native marketplace onboarding plugin`.

## Self-Review Checklist

- [ ] Only `agent-workshop-onboard` is exposed as an active plugin skill.
- [ ] No active scaffold agents are exposed by the plugin.
- [ ] Claude and Codex plugin metadata are present.
- [ ] Bundled references mirror the current canonical scaffold files.
- [ ] `mode: plan` is read-only by default.
- [ ] `mode: apply` is explicit approval-gated and project-local only.
- [ ] Validation proves manifest shape and reference parity.
- [ ] Documentation keeps manual copy path available.
