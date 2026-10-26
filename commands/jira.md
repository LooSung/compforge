---
name: jira
description: Write or rewrite one Jira work card in the team's fixed Korean template without changing code.
---

If the user request is exactly `COMPFORGE_ACTIVATION_PROBE`, output these three
lines and stop without reading other files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

Read and execute the first path that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/jira-card.md` — session plugin
2. `~/.claude/skills/compforge/workflow/jira-card.md` — symlink install

User request:

**$ARGUMENTS**
