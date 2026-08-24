"""Domain model for PR architecture review (no framework, no I/O).

Admit a finding only when it is new or worsened by the diff and sits on
changed lines. Everything else is an adapter.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List, Tuple

FILE_OVER_200_LINES = "FILE_OVER_200_LINES"
MULTIPLE_EXPORTED_COMPONENTS = "MULTIPLE_EXPORTED_COMPONENTS"
ANY_TYPE = "ANY_TYPE"
SERVER_DATA_IN_USESTATE = "SERVER_DATA_IN_USESTATE"
DERIVED_STATE_IN_EFFECT = "DERIVED_STATE_IN_EFFECT"
CONTROL_WITHOUT_ACCESSIBLE_NAME = "CONTROL_WITHOUT_ACCESSIBLE_NAME"
FORM_CONTROL_WITHOUT_LABEL = "FORM_CONTROL_WITHOUT_LABEL"
INTERACTIVE_HANDLER_WITHOUT_KEYBOARD = "INTERACTIVE_HANDLER_WITHOUT_KEYBOARD"

WARN = "WARN"
SCOPE_LINE = "line"
SCOPE_FILE = "file"


@dataclass(frozen=True)
class LineRange:
    start: int
    end: int

    def overlaps(self, other: "LineRange") -> bool:
        return self.start <= other.end and other.start <= self.end


@dataclass(frozen=True)
class CodeLocation:
    path: str
    lines: LineRange


@dataclass(frozen=True)
class Violation:
    """Raw detector output, before new-only / line-level filtering.

    subject_key is line-number-independent so a shifted-but-same subject
    stays silent, while a grown magnitude still counts as worsened.
    """
    rule_id: str
    location: CodeLocation
    subject_key: str
    message: str
    magnitude: int | None = None
    scope: str = SCOPE_LINE

    def identity(self) -> Tuple[str, str]:
        return (self.rule_id, self.subject_key)


@dataclass(frozen=True)
class Finding:
    rule_id: str
    location: CodeLocation
    severity: str
    message: str


@dataclass(frozen=True)
class Verdict:
    finding_count: int
    status: str = "NEUTRAL"


class Changeset:
    """Added/changed line ranges on the new side of the diff."""

    def __init__(self, added: Dict[str, List[LineRange]]):
        self._added = {path: list(ranges) for path, ranges in added.items()}

    def files(self) -> List[str]:
        return sorted(self._added)

    def covers(self, location: CodeLocation) -> bool:
        ranges = self._added.get(location.path)
        if not ranges:
            return False
        return any(location.lines.overlaps(item) for item in ranges)

    def touches(self, path: str) -> bool:
        if path in self._added:
            return True
        prefix = path.rstrip("/") + "/"
        return any(file.startswith(prefix) for file in self._added)


@dataclass
class RuleCatalog:
    enabled: Tuple[str, ...] = (
        FILE_OVER_200_LINES,
        MULTIPLE_EXPORTED_COMPONENTS,
        ANY_TYPE,
        SERVER_DATA_IN_USESTATE,
        DERIVED_STATE_IN_EFFECT,
        CONTROL_WITHOUT_ACCESSIBLE_NAME,
        FORM_CONTROL_WITHOUT_LABEL,
        INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
    )
    exclusions: Tuple[str, ...] = (
        "/test/", "/tests/", "test_", "_test.", ".test.",
        "/node_modules/", "/dist/", "/coverage/", "/.craft/",
        "/__pycache__/",
    )

    @staticmethod
    def defaults() -> "RuleCatalog":
        return RuleCatalog()

    def is_enabled(self, rule_id: str) -> bool:
        return rule_id in self.enabled

    def excludes(self, path: str) -> bool:
        normalized = "/" + path.replace("\\", "/").lstrip("/")
        return any(token in normalized for token in self.exclusions)


class ReviewRun:
    """One pull-request review. Owns new-only + line-level admission."""

    def __init__(self, base_ref: str, head_ref: str, changeset: Changeset):
        self._base_ref = base_ref
        self._head_ref = head_ref
        self._changeset = changeset
        self._findings: List[Finding] = []

    @staticmethod
    def open(base_ref: str, head_ref: str, changeset: Changeset) -> "ReviewRun":
        return ReviewRun(base_ref, head_ref, changeset)

    def assess(
        self,
        head_violations: List[Violation],
        base_violations: List[Violation],
    ) -> None:
        base_by_id = {item.identity(): item for item in base_violations}
        for item in head_violations:
            previous = base_by_id.get(item.identity())
            if previous is not None and not self._worsened(item, previous):
                continue
            if not self._in_scope(item):
                continue
            self._findings.append(
                Finding(item.rule_id, item.location, WARN, item.message)
            )

    def _in_scope(self, item: Violation) -> bool:
        if item.scope == SCOPE_FILE:
            return self._changeset.touches(item.location.path)
        return self._changeset.covers(item.location)

    @staticmethod
    def _worsened(current: Violation, previous: Violation) -> bool:
        return (
            current.magnitude is not None
            and previous.magnitude is not None
            and current.magnitude > previous.magnitude
        )

    def findings(self) -> List[Finding]:
        return list(self._findings)

    def verdict(self) -> Verdict:
        return Verdict(finding_count=len(self._findings))

    def summarize(self) -> "ReviewReport":
        return ReviewReport(
            base_ref=self._base_ref,
            head_ref=self._head_ref,
            findings=list(self._findings),
            verdict=self.verdict(),
        )


@dataclass(frozen=True)
class ReviewReport:
    base_ref: str
    head_ref: str
    findings: List[Finding] = field(default_factory=list)
    verdict: Verdict = field(default_factory=lambda: Verdict(0))
