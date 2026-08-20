"""Application entry: reviewPullRequest orchestration + git adapter + CLI.

Read-only. Always exits 0 (verdict is NEUTRAL / non-blocking).

    PYTHONPATH=scripts/ci python3 -m review.main --base origin/main --root "$PWD"
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from typing import Dict, Optional

from .changeset import parse_unified_diff
from .delivery import correction_prompt, machine_json, summary_markdown
from .detectors import scan
from .model import ReviewReport, ReviewRun, RuleCatalog


def _git(args, root: str) -> Optional[str]:
    try:
        out = subprocess.run(
            ["git", *args],
            cwd=root,
            check=True,
            capture_output=True,
            text=True,
        )
        return out.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def _diff(base: str, head: str, root: str) -> str:
    return _git(["diff", "-U0", f"{base}...{head}"], root) or ""


def _read_at(ref: str, path: str, root: str) -> Optional[str]:
    return _git(["show", f"{ref}:{path}"], root)


def _collect(ref: str, paths, root: str) -> Dict[str, str]:
    files: Dict[str, str] = {}
    for path in paths:
        content = _read_at(ref, path, root)
        if content is not None:
            files[path] = content
    return files


def review_pull_request(base: str, head: str, root: str) -> ReviewReport:
    catalog = RuleCatalog.defaults()
    changeset = parse_unified_diff(_diff(base, head, root))
    changed = changeset.files()
    head_violations = scan(_collect(head, changed, root), catalog)
    base_violations = scan(_collect(base, changed, root), catalog)
    run = ReviewRun.open(base, head, changeset)
    run.assess(head_violations, base_violations)
    return run.summarize()


def _parse_args(argv):
    parser = argparse.ArgumentParser(description="Compforge read-only PR architecture review.")
    parser.add_argument("--base", required=True, help="base ref (e.g. origin/main)")
    parser.add_argument("--head", default="HEAD", help="head ref (default HEAD)")
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument("--comment-out", help="write the Markdown summary here")
    parser.add_argument("--json-out", help="write the machine-readable findings here")
    parser.add_argument("--correction-out", help="write the agent correction prompt here")
    return parser.parse_args(argv)


def main(argv) -> int:
    args = _parse_args(argv)
    report = review_pull_request(args.base, args.head, args.root)
    summary = summary_markdown(report)
    print(summary)
    if args.comment_out:
        with open(args.comment_out, "w", encoding="utf-8") as handle:
            handle.write(summary + "\n")
    if args.json_out:
        with open(args.json_out, "w", encoding="utf-8") as handle:
            handle.write(machine_json(report) + "\n")
    if args.correction_out:
        with open(args.correction_out, "w", encoding="utf-8") as handle:
            handle.write(correction_prompt(report) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
