---
name: workflow-continuity
description: Persist and restore Compforge work context across sessions via one work doc per work item in .craft/.
tags: [workflow, memory]
stability: experimental
---

# Workflow — Continuity

## Purpose

Work survives between chats. Write decisions down as you go; read them back before continuing.

## Work doc location

- One document per work item: `.craft/<kind>-<slug>.md` (e.g. `.craft/feature-cart.md`).
- `kind` is one of `feature`, `bugfix`, `refactor`.
- `.craft/` is gitignored by default (personal notes).
- Target project `AGENTS.md` may override: `Compforge work dir: <path>` or `Compforge continuity: off`.

## When to create

- **Auto-create (opt-out)** for execution tasks: feature, refactor, bugfix. Announce creation in one line; do not ask first.
- **Never create** for advisory or tiny tasks (one-line answers, single-file trivial edits).
- If `Compforge continuity: off` is set, never create.

## Resume procedure

1. On any Craft task, check `.craft/` for a doc matching the work item.
2. If found, read it **first**; continue from `Next step`; do not re-decide settled decisions.
3. If the doc conflicts with the code, trust the code and note the drift in the doc.

## Work doc format

```markdown
# <kind>: <title>

## Status
in-progress | blocked | done

## Context
One paragraph: what this work is and why.

## Decisions
- <date> chose X over Y because Z

## Progress
- [x] design approved
- [ ] implement CartList

## Next step
One concrete action.
```

## Completion gate

Before reporting a task done, update the matching work doc (Status, Progress, Decisions).
A finished work item is marked `done`, not deleted — history is the point.
