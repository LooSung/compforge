---
name: refactor
description: Improve frontend structure while preserving behavior.
---

If the user request is exactly `COMPFORGE_ACTIVATION_PROBE`, output these three
lines and stop without reading other files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

Read and execute the first path that exists for Craft startup, then the first
path that exists for Refactor execution:

Craft startup, continuity, verification, and completion reporting:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/craft.md` — session plugin
2. `~/.claude/skills/compforge/workflow/craft.md` — symlink install

Refactor execution path. Do not reclassify this request as feature work:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/refactor.md` — session plugin
2. `~/.claude/skills/compforge/workflow/refactor.md` — symlink install

User request:

**$ARGUMENTS**
