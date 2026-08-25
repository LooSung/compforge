---
name: consult
description: Ask, compare, review, or explicitly document frontend work without implementation changes.
---

If the user request is exactly `COMPFORGE_ACTIVATION_PROBE`, output these three
lines and stop without reading other files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

Read and execute the first path that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/consult.md` — session plugin
2. `~/.claude/skills/compforge/workflow/consult.md` — symlink install

User request:

**$ARGUMENTS**
