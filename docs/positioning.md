# Compforge — Positioning

## One sentence

Compforge is a spec-driven component-architecture methodology and
architecture-enforcement pack for coding agents building TypeScript + React
frontends.

## Category

Compforge is **vertical harness engineering for frontend architecture**.

It does not replace a coding agent. It gives the agent a component-boundary
language, a staged delivery workflow, measurable architecture rules, runnable
references, and fitness functions.

The operating model is:

- skills are the grammar;
- `AGENTS.md` is the constitution;
- hard rules and CI checks are the lint;
- runnable examples are the reference implementations;
- Craft is the single entry point.

## The problem

General-purpose coding agents can produce working UI while quietly eroding
its architecture. Common failure modes include:

- god page components with many `useState`s;
- server data copied into client state behind fetch effects;
- derived values stored and synced by `useEffect`;
- props drilled through three or more levels;
- planning, implementation, and verification collapsing into one step.

More prompting is not a durable fix. The constraints must be repeatable,
reviewable, and encoded in the development environment.

## The promise

> AI ships the UI. Compforge keeps the component architecture.

Compforge makes component boundaries, state homes, and verification explicit
before UI logic is written. It aims to reduce architecture violations and
architecture-driven rework, not token usage.

## Who it is for

Compforge is for:

- teams using coding agents on TypeScript + React (Vite or Next.js) frontends;
- teams that want component discipline without adopting a UI generator;
- screens where state placement and accessibility matter beyond a prototype;
- reviewers who want architecture rules expressed as checks, not preferences.

## Who it is not for

Compforge is not intended for:

- backend, mobile-native, data science, or ML development;
- generic code search, indexing, memory, or context compression;
- multi-agent orchestration, worktree management, or session scheduling;
- automatic application generation;
- teams optimizing primarily for token or model cost;
- projects that intentionally prefer god pages or fetch-in-`useEffect` as the model.

Sister pack for backends: [OOPforge](https://github.com/LooSung/oopforge).

## How it differs

### General-purpose coding agents

General agents decide how to solve a task. Compforge constrains how frontend
work is discovered, designed, implemented, and verified. It is a layer on
top of the agent, not a competing agent.

### Code generators and templates

Generators produce a predefined structure. Compforge teaches and checks
boundaries while leaving code generation to the active coding agent. Its
examples are references, not scaffolding output. `compforge init` delivers
enforcement configs, not an app skeleton.

### Static architecture tools

ESLint zones and steiger detect import violations. Compforge combines those
checks with the workflow and state-placement guidance that prevent
violations before they are introduced.

### Prompt libraries

Prompt libraries provide reusable instructions. Compforge adds stage
boundaries, human checkpoints, a Component Contract, measurable hard rules,
reference implementations, and CI-backed checks.

## The wedge

Compforge stays narrow to go deep:

1. TypeScript + React frontends (Vite; Next.js documented, example later).
2. Feature folders or Feature-Sliced Design.
3. State placement: query layer / URL / local / derived-at-render.
4. Enforcement through review rules, examples, `compforge init`, and fitness functions.

Expansion is justified only when the new capability strengthens this vertical
focus and can be demonstrated with runnable references.

## Product principles

- **Workflow before code** — new screens move through Discovery, Design,
  Delivery Plan, Skeleton, Implement, and Test.
- **Small skills** — one concept per skill, no mega-prompts.
- **State first** — every piece of state has exactly one named home.
- **Measurable rules** — important constraints should become tests or lint.
- **Human checkpoints** — agents do not silently cross major stage boundaries.
- **Proof over claims** — runnable examples and reproducible comparisons carry
  more weight than architecture prose.

## Evidence standard

Compforge should not claim effectiveness from a curated code snippet alone.
Positioning claims should be supported by reproducible before/after runs using:

- the same task, target stack, model, and starting repository;
- a control run without Compforge and a treatment run with Compforge;
- a published prompt and evaluation checklist;
- architecture-violation counts by rule;
- architecture-driven rework required to pass the same review;
- raw diffs or artifacts that others can inspect.

Token usage and elapsed time may be recorded as context, but they are not the
primary success metrics.

The canonical experiment design lives in the [proof protocol](proof/README.md).
What the published runs currently support, and nothing wider: *Compforge stops
an agent from copying a codebase's bad patterns; it adds nothing to a codebase
that already has good ones, and on a weaker model it reduces violations without
preventing the core one.* Cite pairs in `docs/proof/results/`. This is not a
percentage improvement claim.

## Messaging guardrails

Prefer:

- "architecture-enforcement pack for coding agents";
- "spec-driven component-architecture methodology";
- "vertical harness engineering for TypeScript + React";
- "reduces architecture violations and rework" when evidence is linked.

Avoid:

- "general AI development framework";
- "autonomous software factory";
- "works for every language and architecture";
- unmeasured percentage improvements;
- claims that workflow instructions alone guarantee compliance.

## Adoption path

The shortest useful adoption path is:

1. install or load the pack;
2. run `compforge init` in the target frontend repository;
3. run Craft from that repository;
4. use the smallest execution path for the task;
5. compare review findings before and after adoption.

The methodology remains useful without marketplace packaging or an MCP server.
Those integrations reduce friction; they do not define the product.
