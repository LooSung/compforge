"""Accessibility detectors over JSX: the name, role, and focus subset.

Rules (skills/principles/hard-rules.md):
  CONTROL_WITHOUT_ACCESSIBLE_NAME
  FORM_CONTROL_WITHOUT_LABEL
  INTERACTIVE_HANDLER_WITHOUT_KEYBOARD

The ladder in component-discipline.md refuses to drop names, roles, focus, and
keyboard paths to save lines. This file is only the part a text scan can prove,
so a clean run is evidence about these three rules, not an accessibility audit.
Ambiguous markup (a child expression, an unresolvable id) is left silent.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Iterator, List, Optional, Tuple

from .model import (
    CONTROL_WITHOUT_ACCESSIBLE_NAME,
    CodeLocation,
    FORM_CONTROL_WITHOUT_LABEL,
    INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
    LineRange,
    RuleCatalog,
    Violation,
)

NAMING_ATTRIBUTES = ("aria-label", "aria-labelledby", "title")
NAMED_CONTROLS = ("button", "a")
FORM_CONTROLS = ("input", "select", "textarea")
NON_INTERACTIVE = (
    "div", "span", "li", "p", "section", "article", "td",
    "h1", "h2", "h3", "h4", "h5", "h6", "img",
)
# A value attribute or the browser default already names these.
SELF_NAMED_INPUT_TYPES = ("hidden", "submit", "button", "reset", "image")

TAG_NAME = re.compile(r"[A-Za-z][\w.\-]*")
TAG_START = re.compile(r"<([A-Za-z][\w.\-]*)")
KEY_HANDLER = re.compile(r"\bonKey(?:Down|Up|Press)\s*=")


@dataclass(frozen=True)
class OpenTag:
    name: str
    attributes: str
    start: int
    body_start: int
    self_closing: bool


def _offset_to_line(content: str, offset: int) -> int:
    return content.count("\n", 0, offset) + 1


def _scan_open_tag(content: str, index: int) -> Optional[OpenTag]:
    """Read the opening tag at `index`, tolerating `>` inside attribute values."""
    name = TAG_NAME.match(content, index + 1)
    if name is None:
        return None
    cursor = name.end()
    depth = 0
    quote = ""
    while cursor < len(content):
        char = content[cursor]
        if quote:
            if char == quote:
                quote = ""
        elif char in ('"', "'"):
            quote = char
        elif char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
        elif char == ">" and depth == 0:
            attributes = content[name.end() : cursor]
            return OpenTag(
                name.group(0),
                attributes,
                index,
                cursor + 1,
                attributes.rstrip().endswith("/"),
            )
        cursor += 1
    return None


def _elements(content: str, names: Tuple[str, ...]) -> Iterator[OpenTag]:
    for match in TAG_START.finditer(content):
        if match.group(1) not in names:
            continue
        tag = _scan_open_tag(content, match.start())
        if tag is not None:
            yield tag


def _find_close(content: str, name: str, from_index: int) -> Optional[int]:
    pattern = re.compile(rf"<(/?){re.escape(name)}\b")
    depth = 1
    for match in pattern.finditer(content, from_index):
        if match.group(1):
            depth -= 1
            if depth == 0:
                return match.start()
            continue
        nested = _scan_open_tag(content, match.start())
        if nested is not None and not nested.self_closing:
            depth += 1
    return None


def _has_attribute(attributes: str, name: str) -> bool:
    return re.search(rf"(?:^|\s){re.escape(name)}\s*=", attributes) is not None


def _attribute_value(attributes: str, name: str) -> Optional[str]:
    match = re.search(
        rf"(?:^|\s){re.escape(name)}\s*=\s*"
        r"(?:\"([^\"]*)\"|'([^']*)'|\{([^{}]*)\})",
        attributes,
    )
    if match is None:
        return None
    for group in match.groups():
        if group is not None:
            return group
    return None


def _inner_signal(content: str, start: int, end: int) -> Tuple[bool, bool]:
    """Return (has text, has expression) for children, ignoring nested elements."""
    cursor = start
    text: List[str] = []
    has_expression = False
    while cursor < end:
        char = content[cursor]
        if char == "<":
            tag = _scan_open_tag(content, cursor)
            if tag is not None:
                cursor = tag.body_start
                continue
            close = content.find(">", cursor)
            cursor = end if close == -1 else close + 1
            continue
        if char == "{":
            depth = 0
            probe = cursor
            while probe < end:
                if content[probe] == "{":
                    depth += 1
                elif content[probe] == "}":
                    depth -= 1
                    if depth == 0:
                        break
                probe += 1
            expression = content[cursor + 1 : probe].strip()
            if expression and not expression.startswith("/*"):
                has_expression = True
            cursor = probe + 1
            continue
        text.append(char)
        cursor += 1
    return ("".join(text).strip() != "", has_expression)


def _label_spans(content: str) -> List[Tuple[int, int]]:
    spans: List[Tuple[int, int]] = []
    for tag in _elements(content, ("label",)):
        if tag.self_closing:
            continue
        close = _find_close(content, "label", tag.body_start)
        if close is not None:
            spans.append((tag.body_start, close))
    return spans


def _labelled_by_id(content: str, identifier: str) -> bool:
    token = identifier.strip()
    if not token:
        return False
    for tag in _elements(content, ("label",)):
        target = _attribute_value(tag.attributes, "htmlFor")
        if target is not None and target.strip() == token:
            return True
    return False


def _violation(rule_id: str, path: str, content: str, tag: OpenTag, message: str) -> Violation:
    line = _offset_to_line(content, tag.start)
    return Violation(
        rule_id,
        CodeLocation(path, LineRange(line, line)),
        subject_key=f"{path}::{tag.name}::{line}",
        message=message,
    )


def _detect_unnamed_controls(path: str, content: str) -> List[Violation]:
    out: List[Violation] = []
    for tag in _elements(content, NAMED_CONTROLS):
        if tag.name == "a" and not _has_attribute(tag.attributes, "href"):
            continue
        if any(_has_attribute(tag.attributes, item) for item in NAMING_ATTRIBUTES):
            continue
        if not tag.self_closing:
            close = _find_close(content, tag.name, tag.body_start)
            if close is None:
                continue
            has_text, has_expression = _inner_signal(content, tag.body_start, close)
            if has_text or has_expression:
                continue
        out.append(
            _violation(
                CONTROL_WITHOUT_ACCESSIBLE_NAME,
                path,
                content,
                tag,
                f"<{tag.name}> renders no text and has no aria-label; "
                "an icon-only control reaches a screen reader unnamed",
            )
        )
    return out


def _detect_unlabelled_form_controls(path: str, content: str) -> List[Violation]:
    spans = _label_spans(content)
    out: List[Violation] = []
    for tag in _elements(content, FORM_CONTROLS):
        if tag.name == "input":
            input_type = _attribute_value(tag.attributes, "type")
            if input_type is not None and input_type.strip() in SELF_NAMED_INPUT_TYPES:
                continue
        if any(_has_attribute(tag.attributes, item) for item in NAMING_ATTRIBUTES):
            continue
        if any(start <= tag.start < end for start, end in spans):
            continue
        identifier = _attribute_value(tag.attributes, "id")
        if identifier is not None and _labelled_by_id(content, identifier):
            continue
        out.append(
            _violation(
                FORM_CONTROL_WITHOUT_LABEL,
                path,
                content,
                tag,
                f"<{tag.name}> has no label, aria-label, or wrapping <label>; "
                "a placeholder is not an accessible name",
            )
        )
    return out


def _detect_keyboardless_handlers(path: str, content: str) -> List[Violation]:
    out: List[Violation] = []
    for tag in _elements(content, NON_INTERACTIVE):
        if not _has_attribute(tag.attributes, "onClick"):
            continue
        missing = [
            label
            for label, present in (
                ("role", _has_attribute(tag.attributes, "role")),
                ("tabIndex", _has_attribute(tag.attributes, "tabIndex")),
                ("a key handler", KEY_HANDLER.search(tag.attributes) is not None),
            )
            if not present
        ]
        if not missing:
            continue
        out.append(
            _violation(
                INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
                path,
                content,
                tag,
                f"<{tag.name}> takes onClick but is missing {', '.join(missing)}; "
                "use <button> or restore the focus and keyboard path",
            )
        )
    return out


def scan_file(path: str, content: str, catalog: RuleCatalog) -> List[Violation]:
    if not path.endswith(".tsx"):
        return []
    out: List[Violation] = []
    if catalog.is_enabled(CONTROL_WITHOUT_ACCESSIBLE_NAME):
        out.extend(_detect_unnamed_controls(path, content))
    if catalog.is_enabled(FORM_CONTROL_WITHOUT_LABEL):
        out.extend(_detect_unlabelled_form_controls(path, content))
    if catalog.is_enabled(INTERACTIVE_HANDLER_WITHOUT_KEYBOARD):
        out.extend(_detect_keyboardless_handlers(path, content))
    return out
