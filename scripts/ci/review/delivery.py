"""Render a ReviewReport into read-only delivery surfaces.

The GitHub Action posts the comment and uploads artifacts. This module
only produces text, so it stays free of API dependencies.
"""
from __future__ import annotations

import json
from typing import Any, Dict

from .model import ReviewReport

COMMENT_MARKER = "<!-- compforge-architecture-review -->"


def _clean_summary() -> list[str]:
    return [
        "",
        "No new or worsened hard-rule violations introduced by this PR. ✅",
        "",
        "_Read-only review; pre-existing violations are not reported._",
    ]


def _finding_footer() -> list[str]:
    return [
        "",
        "_Only new or worsened violations on the changed surface are shown "
        "(read-only, non-blocking)._",
        "",
        "### Agent correction",
        "",
        "Fix only the listed subjects. Re-run architecture review.",
        "Do not mix unrelated refactors.",
    ]


def _finding_summary(findings) -> list[str]:
    lines = [
        "",
        f"Found **{len(findings)}** new or worsened hard-rule violation(s) "
        "on changed lines:",
        "",
        "| Rule | Location | Detail |",
        "|---|---|---|",
    ]
    for item in findings:
        loc = f"`{item.location.path}`:{item.location.lines.start}"
        detail = item.message.replace("|", "\\|")
        lines.append(f"| `{item.rule_id}` | {loc} | {detail} |")
    return lines + _finding_footer()


def summary_markdown(report: ReviewReport) -> str:
    lines = [COMMENT_MARKER, "## Compforge architecture review"]
    findings = sorted(
        report.findings,
        key=lambda item: (item.location.path, item.location.lines.start, item.rule_id),
    )
    lines.extend(_finding_summary(findings) if findings else _clean_summary())
    return "\n".join(lines)


def machine_json(report: ReviewReport) -> str:
    return json.dumps(machine_findings(report), indent=2, sort_keys=True)


def _correction_lines(report: ReviewReport) -> list[str]:
    findings = sorted(
        report.findings,
        key=lambda item: (item.location.path, item.location.lines.start, item.rule_id),
    )
    if not findings:
        return ["No correction needed.", ""]
    lines = [
        "Use Compforge craft. Fix only these architecture findings. Surgical.",
        "Re-run the reviewer after the fix. Do not mix unrelated refactors.",
        "",
    ]
    for index, finding in enumerate(findings, start=1):
        loc = f"{finding.location.path}:{finding.location.lines.start}"
        lines.append(f"{index}. `{finding.rule_id}` at `{loc}` — {finding.message}")
    return lines + [""]


def correction_prompt(report: ReviewReport) -> str:
    return "\n".join(["# Compforge architecture-review correction", ""] + _correction_lines(report))


def _finding_dicts(report: ReviewReport) -> list[Dict[str, Any]]:
    return [
        {
            "rule_id": item.rule_id,
            "severity": item.severity,
            "path": item.location.path,
            "line_start": item.location.lines.start,
            "line_end": item.location.lines.end,
            "message": item.message,
        }
        for item in report.findings
    ]


def machine_findings(report: ReviewReport) -> Dict[str, Any]:
    return {
        "schema": "compforge.architecture-review.v1",
        "base_ref": report.base_ref,
        "head_ref": report.head_ref,
        "verdict": {
            "status": report.verdict.status,
            "finding_count": report.verdict.finding_count,
        },
        "findings": _finding_dicts(report),
        "correction": {
            "needed": report.verdict.finding_count > 0,
            "instruction": "Fix only the listed findings. Surgical. Re-run architecture review.",
        },
    }
