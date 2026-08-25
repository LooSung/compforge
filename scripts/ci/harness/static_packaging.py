#!/usr/bin/env python3
"""Validate Compforge harness packaging without agent credentials."""

from __future__ import annotations

import json
from pathlib import Path
import sys


def manifest_components(root: Path) -> list[tuple[str, str, str, Path]]:
    claude = json.loads((root / ".claude-plugin/plugin.json").read_text())
    codex = json.loads((root / ".codex-plugin/plugin.json").read_text())
    cursor = json.loads((root / ".cursor-plugin/plugin.json").read_text())
    return [
        ("Claude skills", claude["skills"]["directory"], "../skills", root / ".claude-plugin"),
        ("Claude commands", claude["commands"]["directory"], "../commands", root / ".claude-plugin"),
        ("Codex skills", codex["skills"], "./skills/", root),
        ("Cursor skills", cursor["skills"], "./.cursor-plugin/skills/", root),
        ("Cursor commands", cursor["commands"], "./commands/", root),
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

    for label, actual, expected, base in manifest_components(root):
        if actual != expected:
            raise SystemExit(f"{label}: expected {expected!r}, got {actual!r}")
        if not (base / actual).is_dir():
            raise SystemExit(f"{label}: missing directory {(base / actual).resolve()}")


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
        "skills/workflow/craft.md",
        "skills/principles/hard-rules.md",
        ".cursor-plugin/skills/compforge/SKILL.md",
        "scripts/ci/harness/probes.sh",
        "docs/reference/support-scope.md",
        "docs/reference/path-convention.md",
        "docs/setup/cursor.md",
        "docs/setup/claude-code.md",
        "docs/setup/codex.md",
    ]
    for relative in required:
        if not (root / relative).is_file():
            raise SystemExit(f"missing harness path: {relative}")

    for relative in (
        "commands/craft.md",
        "skills/SKILL.md",
        ".cursor-plugin/skills/compforge/SKILL.md",
    ):
        if "COMPFORGE_ACTIVATION_PROBE" not in (root / relative).read_text():
            raise SystemExit(f"missing activation probe: {relative}")


def main() -> None:
    root = Path(sys.argv[1]).resolve()
    check_manifests(root)
    check_stability(root)
    check_required_paths(root)
    print("PASS static harness packaging")


if __name__ == "__main__":
    main()
