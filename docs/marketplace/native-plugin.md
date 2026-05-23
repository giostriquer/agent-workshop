# Native Onboarding Plugin

Agent Workshop ships a native marketplace plugin for Claude Code and Codex. The
plugin is intentionally small: it exposes one active skill,
`agent-workshop-onboard`, and bundles the scaffold files as references.

Installing the plugin does not install the scaffold agents globally. It gives the
host a guided onboarding surface that can inspect a target repo, recommend the
smallest useful pack set, and apply only an approved project-local file set.

## Marketplace Files

- Claude Code: `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
- Codex: `.agents/plugins/marketplace.json` with payload in `plugins/agent-workshop/`

Both surfaces point to the same skill contract. The root skill copy supports
Claude Code discovery, and the plugin payload copy supports Codex discovery.

## Skill Modes

- `mode: plan` is the default. It is read-only and returns selected packs,
  classifications, required profile slots, exact proposed files, validation
  checks, risks, and omitted agents.
- `mode: apply` writes only an approved plan's exact file set. It checks git
  status, refuses ambiguous paths, preserves unrelated local content, and does
  not commit unless the approved plan explicitly asks for a commit.
- `mode: audit` checks an existing Agent Workshop adoption for drift, stale
  agents, wrapper mismatches, profile gaps, and accidental plugin-global agents.
- `mode: explain` answers questions about packs, host wrappers, profile slots,
  and agent boundaries using the bundled references.

## Bundled References

The plugin bundles copies of:

- `marketplace/catalog.json`
- canonical `.claude/agents/*.md`
- host wrappers under `.codex/`, `.gemini/`, and `.opencode/`
- mirrored `.claude/skills/*/SKILL.md`
- marketplace, agent, skill, and convention docs

The validator keeps those copies in sync with the canonical scaffold files:

```powershell
.\scripts\validate-native-plugin.ps1
```

## Manual Copy Remains Available

The native plugin is the preferred guided path when Claude Code or Codex can load
marketplace plugins. Manual copying still works and remains the fallback for
other hosts, offline workflows, or cases where the operator wants to review every
file by hand before adoption.
