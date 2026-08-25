---
name: workflow-consult
description: Answer, propose, review, or write one planning document for frontend work without changing implementation code.
tags: [workflow, advisory, review, planning]
stability: experimental
---

# Workflow — Consult

## Purpose

Give evidence-backed frontend advice without turning an advisory request into
permission to implement. Select exactly one mode per invocation: `answer`,
`proposal`, `review`, or `document`.

## When to use

Use for component-architecture questions, alternatives, reviews, and explicit
requests to create or update a planning document. Use Craft for implementation
and Refactor for behavior-preserving code changes.

## Startup

1. Confirm the target project and resolve user paths against it.
2. Read the request and only the code, project rules, and Compforge skills
   needed to support the answer.
3. Select one mode using the priority below.
4. Begin with `Mode: <token> | Write permission: <none|one document>` using the
   exact lowercase mode token. Do not emit narrative before this header.
5. Perform only that mode and report residual uncertainty or verification gaps.

Consult does not auto-create continuity files. If the target project already
has relevant `.craft/` or planning records, read them as evidence.

## Mode selection

Select the first explicit signal that matches:

1. **Document** — create, write, update, save, or document wording.
2. **Review** — review, audit, inspect, or rule-check wording.
3. **Proposal** — alternatives, recommendation, direction, or comparison wording.
4. **Answer** — default for a question or advisory request.

A request to compare options or recommend one is always Proposal, even when it
is phrased as a question.

If the user asks to “review and fix,” complete Review only. Offer Craft or
Refactor as a separate next action; do not change mode silently.

## Answer

Lead with the direct answer. Cite repository evidence when available. Label
inference, uncertainty, and missing context. State the smallest useful next
action, if any. Write permission: none.

## Proposal

Present no more than three viable alternatives. Recommend one and name the
deciding tradeoff. Separate current facts from proposed decisions. Leave
unconfirmed decisions in Open Questions. Without concrete evidence, recommend
the simpler path provisionally. Write permission: none.

## Review

Read the target project's rules first. Load only relevant Hard Rules,
anti-patterns, and `docs/reference/reviewer-checklist.md` sections.

Output:

1. blocking correctness, accessibility, or Hard Rule findings with evidence;
2. optional maintainability advice in a separate section;
3. residual risks or checks that were not run.

If there are no findings, say so explicitly. Write permission: none.

## Document

Choose the destination in this order:

1. the user's explicit path;
2. an existing project planning document;
3. the current approved Compforge stage artifact (Discovery, Design, or
   Delivery Plan);
4. stop and ask if the destination is still unclear.

Inspect relevant current code before documenting implemented behavior. Separate
current facts, proposed decisions, risks, and Open Questions. Do not describe a
proposal as completed work.

For a new feature area or large screen, follow Discovery → Design → Delivery
Plan and write only the current approved stage artifact. Stop at its human
checkpoint.

Write permission: one planning document. Update a directly required index or
link only when the user requested it or project rules require it.

## Prohibited

- Never modify production code, test code, configuration, CI, or dependencies.
- Never apply Review findings or Proposal recommendations in the same request.
- Never write a document without explicit document wording.
- Never manufacture evidence or present inference as observed fact.
- Never collapse required workflow stages or their human checkpoints.
- Never install Playwright or start an E2E suite from Consult.
- Never widen Compforge beyond TypeScript + React.

## Completion

Report the selected mode, evidence inspected, files written (normally none),
open questions, and the next command if implementation or refactoring is needed.
