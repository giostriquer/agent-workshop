# Agent Workshop Plugin

This plugin exposes one skill: `agent-workshop-onboard`.

The skill plans, applies, audits, or explains repo-local adoption of Agent
Workshop agents. Installing this plugin does not install the scaffold agents
globally. Use `mode: plan` in a target repo first, then approve `mode: apply`
only when the proposed file set is correct.
