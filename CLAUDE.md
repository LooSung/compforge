# Compforge — Claude Code Instructions

Read and follow @AGENTS.md.

When working on this repository:

- Use `/compforge:craft` as the default user entry point.
- Use `/compforge:refactor` for explicit behavior-preserving cleanup.
- Use `/compforge:consult` for advice, review, or one planning document.
- Use `/compforge:jira` to write one Jira card, or the child tasks of one epic or story, without changing code.
- Keep Claude-specific packaging in `.claude-plugin/` and `commands/`.
- Do not bypass the Discovery → Design → Delivery Plan → Skeleton → Implement workflow for new features or large screens.
