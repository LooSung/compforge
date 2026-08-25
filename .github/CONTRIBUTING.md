# Contributing to Compforge

Thanks for considering a contribution. Compforge prefers small, measurable
improvements over broad methodology rewrites.

## Contributions we value

1. Clarifying component boundaries, state placement, or existing workflows.
2. Improving supported React stacks, skeletons, and enforcement templates.
3. Fixing Craft routing, verification, examples, or harness packaging.
4. Adding evidence that strengthens or narrows an existing claim.
5. Bug fixes and documentation corrections.

Do not add unsupported stacks, duplicate Hard Rules, per-skill translation
mirrors, or runtime installer dependencies without evidence that the existing
shell-based approach cannot work.

## Local setup

```bash
git clone https://github.com/LooSung/compforge.git
cd compforge
./scripts/setup/install.sh
./scripts/setup/doctor.sh
```

## Find the existing owner

| Area | Canonical location |
|---|---|
| Workflow stages and Craft | `skills/workflow/` |
| Component and state rules | `skills/react/` and `skills/principles/` |
| Stack selection and skeletons | `skills/lang/` and `skills/skeleton/` |
| Delivered enforcement | `templates/` and `scripts/setup/init.sh` |
| Runnable references | `examples/` |
| Compatibility and harness paths | `docs/reference/support-scope.md` |
| Completed user-visible changes | `CHANGELOG.md` → `Unreleased` |

Extend the smallest existing owner before proposing a new skill or document.

## Verify locally

```bash
./scripts/ci/lint-skills.sh
./scripts/ci/harness-smoke.sh static
./scripts/ci/smoke-test.sh
python3 scripts/ci/test-review.py
```

When changing init or a stack template, run the matching
`./scripts/ci/init-smoke.sh <example>`. When changing an example, run its
`npm run check`.

## Skill rules

Every skill must:

1. Have valid frontmatter and a clear trigger.
2. Stay at or below 200 lines.
3. Teach one concept and name prohibited behavior where relevant.
4. Include measurable verification.
5. Be registered in `skills/stability.json` and routed where needed.

Hard Rules live only in `skills/principles/hard-rules.md`.

## Language policy

Skills, scripts, CI, and agent instructions are English canonical. Korean
documents explain concepts; they are not per-skill mirrors. Issues and PRs may
use English or Korean.

## Commit and PR scope

Use focused Conventional Commit messages, for example:

```text
docs(react): clarify URL state ownership
fix(init): preserve strict checks during verify
chore(ci): add a packaging regression
```

Use the PR template and keep one architecture or policy decision per PR.

## Community

This project follows the [Code of Conduct](CODE_OF_CONDUCT.md). Report security
issues through the private process in [SECURITY.md](SECURITY.md).
