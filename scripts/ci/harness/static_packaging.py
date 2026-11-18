#!/usr/bin/env python3
"""Validate Compforge harness packaging without agent credentials."""

from __future__ import annotations

import json
from pathlib import Path
import sys


def manifest_components(root: Path) -> list[tuple[str, list[str], list[str], Path]]:
    claude = json.loads((root / ".claude-plugin/plugin.json").read_text())
    codex = json.loads((root / ".codex-plugin/plugin.json").read_text())
    cursor = json.loads((root / ".cursor-plugin/plugin.json").read_text())
    return [
        ("Claude skills", claude["skills"], ["./skills/"], root),
        ("Claude commands", claude["commands"], ["./commands/"], root),
        ("Codex skills", [codex["skills"]], ["./skills/"], root),
        ("Cursor skills", [cursor["skills"]], ["./.cursor-plugin/skills/"], root),
        ("Cursor commands", [cursor["commands"]], ["./commands/"], root),
    ]


def check_manifests(root: Path) -> None:
    paths = [
        root / ".claude-plugin/plugin.json",
        root / ".codex-plugin/plugin.json",
        root / ".cursor-plugin/plugin.json",
    ]
    versions = {json.loads(path.read_text())["version"] for path in paths}
    if len(versions) != 1:
        raise SystemExit("manifest versions differ")

    claude = json.loads(paths[0].read_text())
    if not isinstance(claude.get("repository"), str):
        raise SystemExit("Claude repository must be a string")

    for label, actual, expected, base in manifest_components(root):
        if actual != expected:
            raise SystemExit(f"{label}: expected {expected!r}, got {actual!r}")
        for relative in actual:
            if not (base / relative).is_dir():
                raise SystemExit(
                    f"{label}: missing directory {(base / relative).resolve()}"
                )


def check_stability(root: Path) -> None:
    registry = json.loads((root / "skills/stability.json").read_text())
    listed = registry["stable"] + registry["experimental"]
    actual = sorted(
        str(path.relative_to(root)) for path in (root / "skills").rglob("*.md")
    )
    if len(listed) != len(set(listed)):
        raise SystemExit("skill stability registry contains duplicates")
    if sorted(listed) != actual:
        missing = sorted(set(actual) - set(listed))
        extra = sorted(set(listed) - set(actual))
        raise SystemExit(
            f"skill stability mismatch: missing={missing}, extra={extra}"
        )
    if registry["schema"] != "compforge.skill-stability.v1":
        raise SystemExit("unexpected skill stability schema")
    for status in ("stable", "experimental"):
        for relative in registry[status]:
            frontmatter = (root / relative).read_text().split("---", 2)[1]
            if f"stability: {status}" not in frontmatter:
                raise SystemExit(f"stability frontmatter mismatch: {relative}")


def check_required_paths(root: Path) -> None:
    required = [
        "commands/craft.md",
        "commands/refactor.md",
        "commands/consult.md",
        "commands/test.md",
        "commands/crucible.md",
        "commands/jira.md",
        "commands/review.md",
        "skills/workflow/craft.md",
        "skills/workflow/gates.md",
        "skills/workflow/refactor.md",
        "skills/workflow/consult.md",
        "skills/workflow/test.md",
        "skills/workflow/crucible.md",
        "skills/workflow/jira-card.md",
        "skills/workflow/jira-children.md",
        "skills/workflow/review.md",
        "skills/principles/hard-rules.md",
        ".cursor-plugin/skills/compforge/SKILL.md",
        "scripts/ci/harness/probes.sh",
        "scripts/ci/test-harness-smoke.py",
        "docs/reference/support-scope.md",
        "docs/reference/path-convention.md",
        "docs/setup/cursor.md",
        "docs/setup/claude-code.md",
        "docs/setup/codex.md",
    ]
    for relative in required:
        if not (root / relative).is_file():
            raise SystemExit(f"missing harness path: {relative}")

    probe_files = [
        "commands/craft.md",
        "commands/refactor.md",
        "commands/consult.md",
        "commands/test.md",
        "commands/crucible.md",
        "commands/jira.md",
        "commands/review.md",
        "skills/SKILL.md",
        ".cursor-plugin/skills/compforge/SKILL.md",
    ]
    for relative in probe_files:
        if "COMPFORGE_ACTIVATION_PROBE" not in (root / relative).read_text():
            raise SystemExit(f"missing activation probe: {relative}")

    expected_root = "${CLAUDE_PLUGIN_ROOT}/skills/workflow"
    expected_link = "~/.claude/skills/compforge/workflow"
    for name, workflow in (
        ("craft", "craft.md"),
        ("refactor", "refactor.md"),
        ("consult", "consult.md"),
        ("test", "test.md"),
        ("crucible", "crucible.md"),
        ("jira", "jira-card.md"),
        ("review", "review.md"),
    ):
        command = (root / f"commands/{name}.md").read_text()
        if (
            f"{expected_root}/{workflow}" not in command
            or f"{expected_link}/{workflow}" not in command
        ):
            raise SystemExit(
                f"Claude {name} command does not support both load paths"
            )

    refactor_command = (root / "commands/refactor.md").read_text()
    if (
        f"{expected_root}/gates.md" not in refactor_command
        or f"{expected_link}/gates.md" not in refactor_command
    ):
        raise SystemExit("Claude Refactor command does not load the shared gates")

    jira_skill = (root / "skills/workflow/jira-card.md").read_text()
    for marker in (
        "Never change code",
        "Type: task | story | bug | epic | backlog",
        "## 배경",
        "## 개요",
        "## 작업 내용",
        "## 현상",
        "## 결과",
        "Never create a second issue",
    ):
        if marker not in jira_skill:
            raise SystemExit(f"Jira skill missing {marker}")
    children_command = (root / "commands/jira.md").read_text()
    for marker in (
        f"{expected_root}/jira-children.md",
        f"{expected_link}/jira-children.md",
    ):
        if marker not in children_command:
            raise SystemExit(f"Claude jira command missing children path: {marker}")
    children_skill = (root / "skills/workflow/jira-children.md").read_text()
    for marker in (
        "Mode: children",
        "[F.E]",
        "[B.E]",
        "[AI]",
        "[DOC]",
        "## 개요",
        "Never edit the parent",
        "구현 저장소",
        "Never change code",
    ):
        if marker not in children_skill:
            raise SystemExit(f"Jira children skill missing {marker}")
    skill = (root / "skills/SKILL.md").read_text()
    for marker in (
        "/compforge:jira",
        "Use Compforge jira:",
        "workflow/jira-card.md",
        "workflow/jira-children.md",
    ):
        if marker not in skill:
            raise SystemExit(f"skills/SKILL.md missing Jira route: {marker}")
    review_skill = (root / "skills/workflow/review.md").read_text()
    for marker in (
        "**P1**",
        "**P2**",
        "**P3**",
        "base commit",
        "Never modify production code",
        "Never post to a pull request without an explicit request",
    ):
        if marker not in review_skill:
            raise SystemExit(f"Review skill missing {marker}")
    for marker in ("/compforge:review", "Use Compforge review:", "workflow/review.md"):
        if marker not in skill:
            raise SystemExit(f"skills/SKILL.md missing Review route: {marker}")


SPEC_FRONTMATTER_KEYS = {
    "name", "description", "license", "compatibility", "metadata", "allowed-tools",
}


def check_spec_frontmatter(root) -> None:
    """Keep SKILL.md loadable everywhere.

    Keys outside the Agent Skills spec are ignored by Claude Code but rejected
    by claude.ai uploads and the Skills API. An unquoted ': ' or ' #' in a
    value breaks YAML, and Claude Code then loads the skill with no fields.
    """
    paths = [root / "skills/SKILL.md", *sorted(root.glob(".cursor-plugin/skills/*/SKILL.md"))]
    for path in paths:
        relative = path.relative_to(root)
        block = path.read_text(encoding="utf-8").split("---", 2)[1]
        for line in block.splitlines():
            if not line or line[0] in " \t#":
                continue
            key, sep, value = line.partition(":")
            if not sep:
                raise SystemExit(f"{relative}: unparsable frontmatter line: {line}")
            if key not in SPEC_FRONTMATTER_KEYS:
                raise SystemExit(
                    f"{relative}: non-spec frontmatter key {key!r}; move it under metadata"
                )
            value = value.strip()
            if value and value[0] not in "'\"|>" and (": " in value or " #" in value):
                raise SystemExit(f"{relative}: unquoted ': ' or ' #' in {key} breaks YAML")


def main() -> None:
    root = Path(sys.argv[1]).resolve()
    check_manifests(root)
    check_stability(root)
    check_spec_frontmatter(root)
    check_required_paths(root)
    print("PASS static harness packaging")


if __name__ == "__main__":
    main()
