#!/usr/bin/env python3
"""Accessibility detector self-tests for architecture review."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from review import detectors
from review.model import (
    CONTROL_WITHOUT_ACCESSIBLE_NAME,
    FORM_CONTROL_WITHOUT_LABEL,
    INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
    RuleCatalog,
)

REPO_ROOT = Path(__file__).resolve().parents[2]
EXAMPLES = REPO_ROOT / "examples"
A11Y_RULES = (
    CONTROL_WITHOUT_ACCESSIBLE_NAME,
    FORM_CONTROL_WITHOUT_LABEL,
    INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
)


def rule_ids(hits) -> set:
    return {item.rule_id for item in hits}


class AccessibilityReviewTests(unittest.TestCase):
    def test_control_without_accessible_name(self) -> None:
        catalog = RuleCatalog.defaults()
        icon_only = {
            "src/TodoItem.tsx": (
                '<button type="button" onClick={() => onRemove(id)}>\n'
                "  <TrashIcon />\n"
                "</button>\n"
            )
        }
        self.assertIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(icon_only, catalog))
        )
        named = {
            "src/TodoItem.tsx": (
                '<button type="button" aria-label={`Delete ${title}`}>\n'
                "  <TrashIcon />\n"
                "</button>\n"
            )
        }
        self.assertNotIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(named, catalog))
        )
        text = {"src/Add.tsx": '<button type="submit">Add</button>\n'}
        self.assertNotIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(text, catalog))
        )
        expression = {"src/Filter.tsx": "<button onClick={pick}>{option}</button>\n"}
        self.assertNotIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME,
            rule_ids(detectors.scan(expression, catalog)),
        )

    def test_form_control_without_label(self) -> None:
        catalog = RuleCatalog.defaults()
        bare = {"src/Add.tsx": '<input value={title} placeholder="What next?" />\n'}
        self.assertIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(bare, catalog))
        )
        wrapped = {
            "src/TodoItem.tsx": (
                "<label>\n"
                '  <input type="checkbox" checked={done} />\n'
                "  <span>{title}</span>\n"
                "</label>\n"
            )
        }
        self.assertNotIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(wrapped, catalog))
        )
        linked = {
            "src/Add.tsx": (
                '<label htmlFor="title">Title</label>\n'
                '<input id="title" value={title} />\n'
            )
        }
        self.assertNotIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(linked, catalog))
        )
        submit = {"src/Add.tsx": '<input type="submit" value="Add" />\n'}
        self.assertNotIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(submit, catalog))
        )

    def test_interactive_handler_without_keyboard(self) -> None:
        catalog = RuleCatalog.defaults()
        div = {"src/Row.tsx": "<div onClick={() => select(id)}>{title}</div>\n"}
        self.assertIn(
            INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
            rule_ids(detectors.scan(div, catalog)),
        )
        restored = {
            "src/Row.tsx": (
                '<div role="button" tabIndex={0} onClick={pick} onKeyDown={pick}>\n'
                "  {title}\n"
                "</div>\n"
            )
        }
        self.assertNotIn(
            INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
            rule_ids(detectors.scan(restored, catalog)),
        )
        button = {"src/Row.tsx": "<button onClick={pick}>{title}</button>\n"}
        self.assertNotIn(
            INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
            rule_ids(detectors.scan(button, catalog)),
        )

    def test_rules_skip_non_jsx_sources(self) -> None:
        catalog = RuleCatalog.defaults()
        hook = {"src/useTodos.ts": "const label = '<input />';\n"}
        self.assertEqual(
            set(), rule_ids(detectors.scan(hook, catalog)) & set(A11Y_RULES)
        )

    def test_shipped_examples_pass(self) -> None:
        catalog = RuleCatalog.defaults()
        sources = {
            str(path.relative_to(REPO_ROOT)): path.read_text(encoding="utf-8")
            for path in sorted(EXAMPLES.glob("*/src/**/*.tsx"))
        }
        self.assertNotEqual({}, sources, "no example components found")
        offenders = [
            f"{item.rule_id} {item.location.path}:{item.location.lines.start}"
            for item in detectors.scan(sources, catalog)
            if item.rule_id in A11Y_RULES
        ]
        self.assertEqual([], offenders)


if __name__ == "__main__":
    unittest.main()
