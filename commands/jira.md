---
name: jira
description: Write one Jira task, story, bug, epic, or backlog item, or the child tasks of one existing epic or story, in the fixed Korean template without changing code.
---

If the user request is exactly `COMPFORGE_ACTIVATION_PROBE`, output these three
lines and stop without reading other files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

When the parent epic or story already exists and the request is to create its
child issues, read and execute the first path that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/jira-children.md` — session plugin
2. `~/.claude/skills/compforge/workflow/jira-children.md` — symlink install

Otherwise read and execute the first path that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/jira-card.md` — session plugin
2. `~/.claude/skills/compforge/workflow/jira-card.md` — symlink install

A request that asks for a new or rewritten issue and its children in the same
breath still uses the `jira-card.md` paths above. That file writes one issue.
Children are the next turn.

User request:

**$ARGUMENTS**
