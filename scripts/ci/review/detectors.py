"""Scan TypeScript/React files into candidate Violations.

Rules (skills/principles/hard-rules.md):
  FILE_OVER_200_LINES
  MULTIPLE_EXPORTED_COMPONENTS
  ANY_TYPE
  SERVER_DATA_IN_USESTATE
  DERIVED_STATE_IN_EFFECT

Accessibility rules live in a11y.py and are aggregated here.
"""
from __future__ import annotations

import re
from typing import Dict, List, Tuple

from . import a11y
from .model import (
    ANY_TYPE,
    CodeLocation,
    DERIVED_STATE_IN_EFFECT,
    FILE_OVER_200_LINES,
    LineRange,
    MULTIPLE_EXPORTED_COMPONENTS,
    RuleCatalog,
    SCOPE_FILE,
    SERVER_DATA_IN_USESTATE,
    Violation,
)

FILE_LIMIT = 200
USE_EFFECT = re.compile(r"\buseEffect\s*\(")
STATE_BINDING = re.compile(
    r"const\s*\[\s*(\w+)\s*,\s*(set\w+)\s*\]\s*=\s*useState"
)
SERVER_NAME = re.compile(r"^(\w*todos|items|list|data)$", re.I)
DERIVED_NAME = re.compile(
    r"^(filtered\w*|visible\w*|match\w*|\w*matches|results?|\w*count|shown\w*)$",
    re.I,
)
ANY_TYPE_RE = re.compile(r":\s*any\b|\bas\s+any\b")
EXPORTED_COMPONENT = re.compile(
    r"^export\s+(?:default\s+)?(?:function|const)\s+([A-Z]\w*)",
    re.MULTILINE,
)


def _is_source(path: str) -> bool:
    return path.endswith((".ts", ".tsx"))


def _is_component(path: str) -> bool:
    return path.endswith(".tsx")


def _line_count(content: str) -> int:
    if content == "":
        return 0
    return len(content.splitlines())


def _offset_to_line(content: str, offset: int) -> int:
    return content.count("\n", 0, offset) + 1


def _matching_paren(content: str, open_index: int) -> int | None:
    depth = 0
    quote = ""
    escape = False
    for index in range(open_index, len(content)):
        char = content[index]
        if quote:
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == quote:
                quote = ""
            continue
        if char in {'"', "'", "`"}:
            quote = char
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return index
    return None


def _effect_spans(content: str) -> List[Tuple[int, int, str]]:
    spans: List[Tuple[int, int, str]] = []
    for match in USE_EFFECT.finditer(content):
        close = _matching_paren(content, match.end() - 1)
        if close is None:
            continue
        start_line = _offset_to_line(content, match.start())
        end_line = _offset_to_line(content, close)
        spans.append((start_line, end_line, content[match.start() : close + 1]))
    return spans


def _detect_file_too_long(path: str, content: str) -> List[Violation]:
    if not _is_component(path):
        return []
    total = _line_count(content)
    if total <= FILE_LIMIT:
        return []
    return [
        Violation(
            FILE_OVER_200_LINES,
            CodeLocation(path, LineRange(1, total)),
            subject_key=path,
            message=f"component file is {total} lines (limit {FILE_LIMIT})",
            magnitude=total,
            scope=SCOPE_FILE,
        )
    ]


def _detect_multiple_exports(path: str, content: str) -> List[Violation]:
    if not _is_component(path):
        return []
    exported = EXPORTED_COMPONENT.findall(content)
    if len(exported) <= 1:
        return []
    return [
        Violation(
            MULTIPLE_EXPORTED_COMPONENTS,
            CodeLocation(path, LineRange(1, _line_count(content))),
            subject_key=path,
            message="file exports more than one component: " + ", ".join(exported),
            scope=SCOPE_FILE,
        )
    ]


def _detect_any_type(path: str, content: str) -> List[Violation]:
    out: List[Violation] = []
    for match in ANY_TYPE_RE.finditer(content):
        line = _offset_to_line(content, match.start())
        out.append(
            Violation(
                ANY_TYPE,
                CodeLocation(path, LineRange(line, line)),
                subject_key=f"{path}::{line}",
                message="committed `any`; use unknown and narrow",
            )
        )
    return out


def _detect_server_state(path: str, content: str) -> List[Violation]:
    out: List[Violation] = []
    for match in STATE_BINDING.finditer(content):
        name, _setter = match.group(1), match.group(2)
        if not SERVER_NAME.match(name):
            continue
        line = _offset_to_line(content, match.start())
        out.append(
            Violation(
                SERVER_DATA_IN_USESTATE,
                CodeLocation(path, LineRange(line, line)),
                subject_key=f"{path}::{name}",
                message=f"`{name}` looks like server data stored in useState",
            )
        )
    return out


def _detect_derived_in_effect(path: str, content: str) -> List[Violation]:
    setters = {
        setter: name
        for name, setter in STATE_BINDING.findall(content)
        if DERIVED_NAME.match(name)
    }
    if not setters:
        return []
    out: List[Violation] = []
    for start, end, body in _effect_spans(content):
        hit = next((name for setter, name in setters.items() if setter + "(" in body), None)
        if hit is None:
            continue
        out.append(
            Violation(
                DERIVED_STATE_IN_EFFECT,
                CodeLocation(path, LineRange(start, end)),
                subject_key=f"{path}::{hit}",
                message=f"`{hit}` looks derived but is synced in useEffect",
            )
        )
    return out


def scan(files: Dict[str, str], catalog: RuleCatalog) -> List[Violation]:
    out: List[Violation] = []
    for path, content in files.items():
        if catalog.excludes(path) or not _is_source(path):
            continue
        if catalog.is_enabled(FILE_OVER_200_LINES):
            out.extend(_detect_file_too_long(path, content))
        if catalog.is_enabled(MULTIPLE_EXPORTED_COMPONENTS):
            out.extend(_detect_multiple_exports(path, content))
        if catalog.is_enabled(ANY_TYPE):
            out.extend(_detect_any_type(path, content))
        if catalog.is_enabled(SERVER_DATA_IN_USESTATE):
            out.extend(_detect_server_state(path, content))
        if catalog.is_enabled(DERIVED_STATE_IN_EFFECT):
            out.extend(_detect_derived_in_effect(path, content))
        out.extend(a11y.scan_file(path, content, catalog))
    return out
