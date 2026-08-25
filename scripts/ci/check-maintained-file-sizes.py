#!/usr/bin/env python3
"""Enforce review-sized tracked text while exempting generated evidence."""

from __future__ import annotations

from pathlib import Path
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[2]
LINE_LIMIT = 300


def tracked_files() -> list[Path]:
    output = subprocess.check_output(
        [
            "git",
            "-C",
            str(ROOT),
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
        ]
    )
    return [ROOT / item.decode() for item in output.split(b"\0") if item]


def exempt(path: Path) -> bool:
    relative = path.relative_to(ROOT)
    if path.name == "package-lock.json":
        return True
    if path.suffix == ".patch" and relative.parts[:3] == (
        "docs",
        "proof",
        "results",
    ):
        return True
    return False


def line_count(path: Path) -> int | None:
    try:
        return len(path.read_text(encoding="utf-8").splitlines())
    except UnicodeDecodeError:
        return None


def main() -> int:
    failures: list[str] = []
    for path in tracked_files():
        if not path.is_file() or exempt(path):
            continue
        lines = line_count(path)
        if lines is not None and lines > LINE_LIMIT:
            failures.append(
                f"{path.relative_to(ROOT)}: {lines} lines (limit: {LINE_LIMIT})"
            )

    if failures:
        print("maintained file size check failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print(f"maintained file size check: PASS (limit {LINE_LIMIT})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
