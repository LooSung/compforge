---
name: craft
description: Execute frontend component work with the smallest appropriate path.
---

If the user request is exactly `COMPFORGE_ACTIVATION_PROBE`, output these three
lines and stop without reading other files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

Read and execute the first path that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/craft.md` — session plugin
2. `~/.claude/skills/compforge/workflow/craft.md` — symlink install

User request:

**$ARGUMENTS**
