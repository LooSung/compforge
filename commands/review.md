---
name: review
description: Review one frontend diff, branch, or pull request and report prioritized findings without changing code.
argument-hint: "[PR number or URL | branch | empty for the working tree]"
---

If the user request is exactly `COMPFORGE_ACTIVATION_PROBE`, output these three
lines and stop without reading other files:

```text
COMPFORGE_LOADED
Assumptions
Component Contract
```

Read and execute the first path that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/workflow/review.md` — session plugin
2. `~/.claude/skills/compforge/workflow/review.md` — symlink install

User request:

**$ARGUMENTS**
