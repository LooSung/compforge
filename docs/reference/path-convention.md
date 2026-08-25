# Compforge pack path convention

Commands and agents resolve skills from the **pack root**. They never route
through the legacy `skills/compforge/...` source path.

## Resolve the pack root

1. `$COMPFORGE_HOME` when set.
2. `~/.compforge` after bootstrap installation.
3. The repository root while maintaining this pack.

## Canonical source paths

```text
{pack}/skills/workflow/craft.md
{pack}/skills/principles/hard-rules.md
{pack}/skills/react/state-placement.md
{pack}/skills/skeleton/frontend-skeleton.md
```

Harness folder names are packaging adapters, not alternate skill roots:

```text
~/.claude/skills/compforge/workflow/craft.md
  → {pack}/skills/workflow/craft.md

~/.codex/skills/compforge/SKILL.md
  → {pack}/skills/SKILL.md
```

Cursor's verified load paths are defined in
[`../setup/cursor.md`](../setup/cursor.md). Stable paths and compatibility
boundaries are defined in [`support-scope.md`](support-scope.md).
