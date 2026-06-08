# Native Onboarding Plugin

Agent Workshop ships a native marketplace plugin for Claude Code and Codex. The
plugin is intentionally small: it exposes one active skill,
`agent-workshop-onboard`, and bundles the scaffold files as references.

Installing the plugin does not install the scaffold agents globally. It gives the
host a guided onboarding surface that can inspect a target repo, recommend the
smallest useful pack set, and apply only an approved project-local file set.

## Marketplace Files

- Claude Code: `.claude-plugin/marketplace.json` with payload in `plugins/agent-workshop/`
- Codex: `.agents/plugins/marketplace.json` with payload in `plugins/agent-workshop/`

Both marketplace surfaces point to the same slim plugin payload. That payload
contains `plugins/agent-workshop/.claude-plugin/plugin.json`,
`plugins/agent-workshop/.codex-plugin/plugin.json`, and exactly one active skill
directory: `plugins/agent-workshop/skills/agent-workshop-onboard/`.

The root `skills/agent-workshop-onboard/` copy remains a source copy for this
repo, not the marketplace source. Marketplace installs must not point at repo
root, because repo root also contains the scaffold's canonical `.claude/skills/`
tree.

## Install From A Separate Machine

For Claude Code:

```text
/plugin marketplace add giostriquer/agent-workshop
/plugin install agent-workshop@agent-workshop
```

For Codex:

```powershell
codex plugin marketplace add giostriquer/agent-workshop --ref main
codex plugin add agent-workshop@agent-workshop
codex plugin add reviewers@agent-workshop
```

Codex can also install from a local checkout while developing the marketplace:

```powershell
codex plugin marketplace add E:\dev\agent-workshop
codex plugin add agent-workshop@agent-workshop
```

Use a new Codex thread after installing or updating the plugin so the newly
installed `agent-workshop-onboard` skill is available to the session.

`reviewers` is the Codex-native counterpart to the Claude Code
`reviewers` plugin. Codex plugins distribute skills, apps, and MCP servers, so
the active Codex surface is the `handoff-review` and `handoff-pr` skills. The
reviewer agent files are bundled in the plugin payload for Claude Code and
reference, but Codex custom agents still need repo-local `.codex/agents/`
wrappers from onboarding.

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
- non-discoverable Markdown copies of mirrored `.claude/skills/*/SKILL.md`
- marketplace, agent, skill, and convention docs

Those files live under the onboarding skill's `references/` directory. They are
templates for approved repo-local adoption, not additional active plugin skills.
Reference skill templates are stored as `references/skills/<skill>.md`, not as
nested `SKILL.md` files.

The validator keeps those copies in sync with the canonical scaffold files:

```powershell
.\scripts\validate-native-plugin.ps1
```

## Manual Copy Remains Available

The native plugin is the preferred guided path when Claude Code or Codex can load
marketplace plugins. Manual copying still works and remains the fallback for
other hosts, offline workflows, or cases where the operator wants to review every
file by hand before adoption.
