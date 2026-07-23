# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [0.1.0] — 2026-07-23

Initial scaffold, mirroring the [OOPforge](https://github.com/LooSung/oopforge) pack structure.

### Added

- **Install runtime**: `scripts/setup/` (bootstrap, install, uninstall, doctor) — symlinks the pack into Claude Code (`~/.claude/{skills,commands}/compforge`) and Codex CLI (`~/.codex/skills/compforge`); Cursor via project-local link.
- **Entry point**: `/compforge:craft` slash command (`commands/craft.md`) → `skills/workflow/craft.md` orchestrator with Assumptions block, Component Contract, and Hard Rule verification.
- **Workflow skills**: discovery, design, skeleton, implement, test, refactor, continuity.
- **Principles**: `skills/principles/component-discipline.md` (11 rules incl. state-home ladder, pre-write ladder, surgical changes).
- **React skills**: component-boundary, state-placement, hooks-discipline.
- **Anti-patterns**: god-component, useeffect-abuse, prop-drilling.
- **Stack gate**: `skills/lang/frontend-stack.md` — TypeScript + React only (`react-vite-feature`, `react-vite-fsd`, `react-next-app`); Vue explicitly marked not-yet-supported.
- **Skeleton conventions**: `skills/skeleton/frontend-skeleton.md`.
- **Hard Rules v0.1 draft** in `AGENTS.md` (200 lines/component file, 1 export/file, TS strict, no direct mutation, server state in query layer, effects as last resort, 2-level prop limit, feature public APIs).
- **CI**: `scripts/ci/lint-skills.sh` (frontmatter + 200-line skill limit).
- Docs: `README.md`, `README.ko.md`, `AGENTS.md`, `CLAUDE.md`, `docs/roadmap.md`.
- Plugin manifests: `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/`.

### Known gaps (tracked in `docs/roadmap.md`)

- No runnable `examples/` yet — Hard Rules are a draft until validated against them.
- No CI architecture lint for target projects (eslint-plugin-boundaries / dependency-cruiser integration pending).
- No proof protocol runs yet.
- Vue not supported.
