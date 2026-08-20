#!/usr/bin/env python3
"""Re-score published proof patches with the current evaluator.

Does not re-run agents. Archives the recorded starter commit, applies the
saved patch, and writes rescored JSON beside the original machine output.
"""
from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

PACK = Path(__file__).resolve().parents[2]
EVALUATOR = Path(__file__).with_name("evaluate-run.py")
RESULTS = PACK / "docs" / "proof" / "results"
TERM = re.compile(r"skills/|ladder|rung|compforge", re.IGNORECASE)
GIT_ENV = {
    **os.environ,
    "GIT_AUTHOR_NAME": "Compforge",
    "GIT_AUTHOR_EMAIL": "proof@compforge.local",
    "GIT_COMMITTER_NAME": "Compforge",
    "GIT_COMMITTER_EMAIL": "proof@compforge.local",
}


def run(args: list[str], cwd: Path | None = None, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=cwd,
        check=check,
        capture_output=True,
        text=True,
        env=GIT_ENV,
    )


def parse_metadata(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            data[key] = value
    return data


def neutralize(workspace: Path) -> None:
    (workspace / "README.md").unlink(missing_ok=True)
    for path in sorted(workspace.rglob("*")):
        if not path.is_file() or path.suffix not in {".ts", ".tsx", ".js", ".mjs", ".cjs"}:
            continue
        lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
        kept = [
            line
            for line in lines
            if not (line.lstrip().startswith("//") and TERM.search(line))
        ]
        if len(kept) != len(lines):
            path.write_text("".join(kept), encoding="utf-8")
    index = workspace / "index.html"
    if index.exists():
        index.write_text(
            re.sub(r"<title>.*?</title>", "<title>Todos</title>", index.read_text(encoding="utf-8")),
            encoding="utf-8",
        )


def archive_starter(commit: str, starter: str, dest: Path) -> None:
    depth = starter.count("/") + 1
    dest.mkdir(parents=True, exist_ok=True)
    archive = subprocess.run(
        ["git", "archive", commit, starter],
        cwd=PACK,
        check=True,
        capture_output=True,
    )
    subprocess.run(
        ["tar", "-x", "-C", str(dest), f"--strip-components={depth}"],
        input=archive.stdout,
        check=True,
        capture_output=True,
    )


def evaluate(workspace: Path) -> dict[str, object]:
    result = run(["python3", str(EVALUATOR), str(workspace)], check=False)
    if not result.stdout.strip():
        raise RuntimeError(result.stderr or "evaluator produced no JSON")
    payload = json.loads(result.stdout)
    payload.pop("workspace", None)
    return payload


def rescore_arm(commit: str, starter: str, patch: Path) -> dict[str, object]:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        archive_starter(commit, starter, root)
        neutralize(root)
        (root / ".gitignore").write_text("node_modules/\ndist/\n", encoding="utf-8")
        run(["git", "init"], cwd=root)
        run(["git", "add", "."], cwd=root)
        run(["git", "commit", "-m", "Proof baseline"], cwd=root)
        applied = run(["git", "apply", "--whitespace=nowarn", str(patch)], cwd=root, check=False)
        if applied.returncode != 0:
            raise RuntimeError(applied.stderr or applied.stdout or "git apply failed")
        run(["git", "add", "-N", "."], cwd=root)
        return evaluate(root)


def finding_rules(payload: dict[str, object]) -> list[str]:
    findings = payload.get("findings", [])
    if not isinstance(findings, list):
        return []
    return sorted(
        str(item.get("rule", ""))
        for item in findings
        if isinstance(item, dict)
    )


def main() -> int:
    rows: list[dict[str, object]] = []
    for meta in sorted(RESULTS.glob("*/artifacts/metadata.txt")):
        data = parse_metadata(meta)
        commit = data.get("source_commit", "")
        starter = data.get("starter", "")
        folder = meta.parent
        pair = meta.parent.parent.name
        if not commit or not starter:
            continue
        for arm in ("control", "treatment"):
            patch = folder / f"{arm}-changes.patch"
            original_path = folder / f"{arm}-evaluation.json"
            if not patch.exists() or not original_path.exists():
                continue
            original = json.loads(original_path.read_text(encoding="utf-8"))
            original.pop("workspace", None)
            record = {
                "pair": pair,
                "arm": arm,
                "starter": starter,
                "commit": commit[:12],
            }
            try:
                rescored = rescore_arm(commit, starter, patch)
                out = folder / f"{arm}-evaluation-rescored.json"
                out.write_text(json.dumps(rescored, indent=2, sort_keys=True) + "\n", encoding="utf-8")
                record["original_count"] = original.get("violation_count")
                record["rescored_count"] = rescored.get("violation_count")
                record["original_rules"] = finding_rules(original)
                record["rescored_rules"] = finding_rules(rescored)
                record["status"] = "ok"
            except Exception as exc:  # noqa: BLE001 — report per-arm, keep going
                record["status"] = "error"
                record["error"] = str(exc).splitlines()[0]
            rows.append(record)
            print(f"{pair} {arm}: {record.get('status')} "
                  f"{record.get('original_count')} -> {record.get('rescored_count')}",
                  file=sys.stderr)

    summary = RESULTS / "2026-08-20-evaluator-rescore.md"
    lines = [
        "# Evaluator rescore of published pairs",
        "",
        "Same saved patches, current `scripts/proof/evaluate-run.py`.",
        "Agents were not re-run. Original `*-evaluation.json` files are unchanged.",
        "",
        "| Pair | Arm | Original | Rescored | Notes |",
        "|---|---|---|---|---|",
    ]
    for row in rows:
        if row["status"] != "ok":
            lines.append(
                f"| `{row['pair']}` | {row['arm']} | — | — | {row.get('error', 'error')} |"
            )
            continue
        original_rules = set(row["original_rules"])  # type: ignore[arg-type]
        rescored_rules = set(row["rescored_rules"])  # type: ignore[arg-type]
        added = sorted(rescored_rules - original_rules)
        note = "same" if not added and row["original_count"] == row["rescored_count"] else (
            "new rules: " + ", ".join(added) if added else "count changed"
        )
        lines.append(
            f"| `{row['pair']}` | {row['arm']} | {row['original_count']} | "
            f"{row['rescored_count']} | {note} |"
        )
    lines.extend(
        [
            "",
            "Do not treat a count change as a new agent outcome. It is a measure",
            "change on frozen diffs. New agent runs are a separate experiment.",
            "",
        ]
    )
    summary.write_text("\n".join(lines), encoding="utf-8")
    print(summary)
    return 0 if all(row["status"] == "ok" for row in rows) else 1


if __name__ == "__main__":
    raise SystemExit(main())
