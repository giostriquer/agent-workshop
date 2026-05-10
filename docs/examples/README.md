# Examples

End-to-end walkthroughs that show the agents and skills working together.

These are illustrative — the specific paths, workflow steps, and sample dispatches reflect the originating project's adoption. Adopting projects adapt to their domain.

## Contents

- [`spec-driven-development.md`](spec-driven-development.md) — the full Spec → Plan → Execute → Review → Critique → Final-Docs loop, with a Mermaid diagram showing where each agent and skill plugs in. Validated against the Superpowers framework but framework-agnostic.
- [`doc-audit-pass.md`](doc-audit-pass.md) — running a proactive doc audit, triaging findings, and routing fixes to the right agents.

## How to use these

If you're adopting the scaffold, read the example that's closest to a workflow you actually run. Pay attention to:

- **Where each agent / skill enters the loop.** That's the durable shape.
- **The dispatch shapes.** Real "this is how I'd word the prompt" examples.
- **The error-recovery paths.** What happens when a review fails, when a continuation fails, when a candidate gets rejected.

If your workflow looks substantially different from any example, that's a signal that the scaffold may not be the right fit for that workflow without adaptation. Either adapt and document the new flow, or skip the related agents / skills entirely.
