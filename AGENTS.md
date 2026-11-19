# Compforge — agent notes

These notes are for agents changing **Compforge itself**. To *use* Compforge on a
frontend project, follow `skills/SKILL.md` instead; it owns command routing and
skill selection for every harness.

Compforge continuity: off

## What Compforge is

A frontend methodology pack. Skills are the grammar, Hard Rules are the lint,
`examples/` are the reference implementations, and commands plus install scripts
are the runtime. Protect the core promise: small components, explicit state
placement, clear boundaries, and human checkpoints.

Sister packs: [OOPforge](https://github.com/LooSung/oopforge) (backend) and
[FuseForge](https://github.com/LooSung/fuseforge) (full-stack coordinator).

## Layout

| Path | Holds |
|---|---|
| `skills/SKILL.md` | Entry point and command routing |
| `skills/workflow/` | One file per workflow; `skills/workflow/gates.md` holds the shared startup, plan input, verification, and report gates |
| `skills/principles/hard-rules.md` | The only copy of the Hard Rules (MUST / SHOULD / NEVER) |
| `skills/react/`, `lang/`, `skeleton/`, `playbooks/`, `antipatterns/` | Topic skills that workflows load on demand |
| `skills/stability.json` | Skill maturity, explained in `docs/reference/skill-stability.md` |
| `commands/` | **Generated** from the skill sources by `scripts/ci/build-commands.py` |
| `.claude-plugin/`, `.codex-plugin/`, `.cursor-plugin/` | Harness packaging only; `.claude-plugin/marketplace.json` is the `forge` catalog of all three packs, kept identical across the three repositories except for which entry is `./` |
| `examples/` | Runnable todo app on the three shipped stacks |
| `templates/` | What `scripts/setup/init.sh` copies into a target project |
| `scripts/setup/`, `scripts/ci/` | Install lifecycle and CI checks |
| `docs/` | Human docs, indexed by `docs/README.md` |

## Checks

CI runs these (full list: `.github/workflows/lint.yml`); all must pass before a
change is done:

```bash
./scripts/ci/lint-skills.sh                       # skills, links, AGENTS.md paths, command freshness
python3 scripts/ci/check-maintained-file-sizes.py # tracked text ≤ 300 lines
python3 scripts/ci/test-doc-links.py
python3 scripts/ci/test-run-with-timeout.py
./scripts/ci/harness-smoke.sh static
python3 scripts/ci/test-harness-smoke.py
python3 scripts/proof/test-evaluate-run.py
python3 scripts/proof/test-proof-runner.py
python3 scripts/proof/test-rescore-published.py
python3 scripts/ci/test-review.py
python3 scripts/ci/test-review-a11y.py
bash scripts/setup/doctor.sh
./scripts/ci/smoke-test.sh                        # clean-HOME install lifecycle
./scripts/ci/init-smoke.sh                        # when touching init or templates/
```

After editing a workflow skill, regenerate commands with
`python3 scripts/ci/build-commands.py`.

## Rules

- A new capability or architecture change goes through Discovery → Design →
  Delivery Plan → Skeleton → Implement → Test, with human approval between
  stages. A focused fix does not need the full flow.
- One source of truth: Hard Rules live only in `skills/principles/hard-rules.md`,
  routing only in `skills/SKILL.md`, and support facts only in
  `docs/reference/support-scope.md`. Point to them; never copy them.
- Each `commands/*.md` must fit `scripts/ci/command-budget.json`. Raising a
  budget is a reviewed decision in the same diff: say what the added text is
  worth, or remove something else.
- Do not claim a harness integration works until documented setup and a
  clean-session smoke prove it. Cursor's paths are pinned by
  `scripts/ci/harness-smoke.sh live cursor`.
- Effect claims need a published pair in `docs/proof/results/`. Publish
  unfavourable runs too, and say so when a measure changed after seeing data.
- When changing install behavior, verify with a clean temporary `HOME`. Add no
  runtime dependencies to installer scripts when shell will do.
- Do not mix refactoring with feature changes. Do not create mega-prompts,
  mega-skills, or abstractions without evidence.
- Skills, scripts, and agent instructions are in English. Korean readers get
  `README.ko.md` and `docs/reference/methodology.ko.md`, not per-skill
  translations.
- Record completed user-visible changes in `CHANGELOG.md` under `Unreleased`.
  Never put future plans in tracked files. Private maintainer direction lives in
  the gitignored `docs/planning/management.md`: read it first when it exists;
  otherwise the user's request or linked issue defines scope.
- Do not create `.craft/` state in this repository.
