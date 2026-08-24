#!/usr/bin/env python3
"""Self-test for architecture review (new-only + React detectors)."""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from review import delivery, detectors
from review.changeset import parse_unified_diff
from review.model import (
    ANY_TYPE,
    CONTROL_WITHOUT_ACCESSIBLE_NAME,
    Changeset,
    CodeLocation,
    DERIVED_STATE_IN_EFFECT,
    FILE_OVER_200_LINES,
    FORM_CONTROL_WITHOUT_LABEL,
    INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
    LineRange,
    MULTIPLE_EXPORTED_COMPONENTS,
    ReviewRun,
    RuleCatalog,
    SERVER_DATA_IN_USESTATE,
    Violation,
)

REPO_ROOT = Path(__file__).resolve().parents[2]
RULES_FILE = REPO_ROOT / "skills" / "principles" / "hard-rules.md"
EXAMPLES = REPO_ROOT / "examples"
A11Y_RULES = (
    CONTROL_WITHOUT_ACCESSIBLE_NAME,
    FORM_CONTROL_WITHOUT_LABEL,
    INTERACTIVE_HANDLER_WITHOUT_KEYBOARD,
)


def rule_ids(hits) -> set:
    return {item.rule_id for item in hits}


class ReviewTests(unittest.TestCase):
    def test_hard_rules_file_lists_detector_ids(self) -> None:
        text = RULES_FILE.read_text(encoding="utf-8")
        for rule_id in RuleCatalog.defaults().enabled:
            self.assertIn(f"`{rule_id}`", text, rule_id)

    def test_changeset_parse(self) -> None:
        diff = (
            "diff --git a/src/App.tsx b/src/App.tsx\n"
            "--- a/src/App.tsx\n"
            "+++ b/src/App.tsx\n"
            "@@ -0,0 +5,3 @@\n"
            "diff --git a/old.tsx b/old.tsx\n"
            "--- a/old.tsx\n"
            "+++ /dev/null\n"
            "@@ -1,2 +0,0 @@\n"
        )
        changeset = parse_unified_diff(diff)
        self.assertEqual(["src/App.tsx"], changeset.files())
        self.assertTrue(changeset.covers(CodeLocation("src/App.tsx", LineRange(5, 7))))
        self.assertFalse(changeset.covers(CodeLocation("src/App.tsx", LineRange(1, 1))))

    def test_file_length_and_exports(self) -> None:
        catalog = RuleCatalog.defaults()
        long_file = {"src/App.tsx": "\n".join(f"const x{i} = {i}" for i in range(201))}
        hits = detectors.scan(long_file, catalog)
        self.assertTrue(any(item.rule_id == FILE_OVER_200_LINES for item in hits))
        short = {"src/App.tsx": "export function App() { return null; }\n"}
        self.assertEqual([], detectors.scan(short, catalog))
        two = {
            "src/App.tsx": (
                "export function App() { return null; }\n"
                "export function Other() { return null; }\n"
            )
        }
        self.assertTrue(
            any(item.rule_id == MULTIPLE_EXPORTED_COMPONENTS for item in detectors.scan(two, catalog))
        )

    def test_any_and_server_state(self) -> None:
        catalog = RuleCatalog.defaults()
        any_file = {"src/hooks/useTodos.ts": "export function useTodos(): any { return []; }\n"}
        self.assertTrue(
            any(item.rule_id == ANY_TYPE for item in detectors.scan(any_file, catalog))
        )
        server = {"src/App.tsx": "const [todos, setTodos] = useState([]);\n"}
        self.assertTrue(
            any(item.rule_id == SERVER_DATA_IN_USESTATE for item in detectors.scan(server, catalog))
        )
        local = {"src/App.tsx": "const [open, setOpen] = useState(false);\n"}
        self.assertEqual([], detectors.scan(local, catalog))

    def test_derived_state_in_effect(self) -> None:
        catalog = RuleCatalog.defaults()
        source = {
            "src/App.tsx": (
                "const [visibleTodos, setVisibleTodos] = useState([]);\n"
                "useEffect(() => { setVisibleTodos(todos.filter(Boolean)); }, [todos]);\n"
            )
        }
        hits = detectors.scan(source, catalog)
        self.assertTrue(any(item.rule_id == DERIVED_STATE_IN_EFFECT for item in hits))
        ok = {
            "src/App.tsx": (
                "const visibleTodos = todos.filter(Boolean);\n"
                "useEffect(() => { window.addEventListener('x', fn); return fn; }, []);\n"
            )
        }
        self.assertFalse(
            any(item.rule_id == DERIVED_STATE_IN_EFFECT for item in detectors.scan(ok, catalog))
        )

    def test_control_without_accessible_name(self) -> None:
        catalog = RuleCatalog.defaults()
        icon_only = {
            "src/TodoItem.tsx": (
                "<button type=\"button\" onClick={() => onRemove(id)}>\n"
                "  <TrashIcon />\n"
                "</button>\n"
            )
        }
        self.assertIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(icon_only, catalog))
        )
        named = {
            "src/TodoItem.tsx": (
                "<button type=\"button\" aria-label={`Delete ${title}`}>\n"
                "  <TrashIcon />\n"
                "</button>\n"
            )
        }
        self.assertNotIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(named, catalog))
        )
        text = {"src/Add.tsx": "<button type=\"submit\">Add</button>\n"}
        self.assertNotIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(text, catalog))
        )
        # A child expression may render text; ambiguity stays silent.
        expression = {"src/Filter.tsx": "<button onClick={pick}>{option}</button>\n"}
        self.assertNotIn(
            CONTROL_WITHOUT_ACCESSIBLE_NAME, rule_ids(detectors.scan(expression, catalog))
        )

    def test_form_control_without_label(self) -> None:
        catalog = RuleCatalog.defaults()
        bare = {"src/Add.tsx": "<input value={title} placeholder=\"What next?\" />\n"}
        self.assertIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(bare, catalog))
        )
        wrapped = {
            "src/TodoItem.tsx": (
                "<label>\n"
                "  <input type=\"checkbox\" checked={done} />\n"
                "  <span>{title}</span>\n"
                "</label>\n"
            )
        }
        self.assertNotIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(wrapped, catalog))
        )
        linked = {
            "src/Add.tsx": (
                "<label htmlFor=\"title\">Title</label>\n"
                "<input id=\"title\" value={title} />\n"
            )
        }
        self.assertNotIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(linked, catalog))
        )
        submit = {"src/Add.tsx": "<input type=\"submit\" value=\"Add\" />\n"}
        self.assertNotIn(
            FORM_CONTROL_WITHOUT_LABEL, rule_ids(detectors.scan(submit, catalog))
        )

    def test_interactive_handler_without_keyboard(self) -> None:
        catalog = RuleCatalog.defaults()
        div = {"src/Row.tsx": "<div onClick={() => select(id)}>{title}</div>\n"}
        self.assertIn(
            INTERACTIVE_HANDLER_WITHOUT_KEYBOARD, rule_ids(detectors.scan(div, catalog))
        )
        restored = {
            "src/Row.tsx": (
                "<div role=\"button\" tabIndex={0} onClick={pick} onKeyDown={pick}>\n"
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

    def test_accessibility_rules_skip_non_jsx_sources(self) -> None:
        catalog = RuleCatalog.defaults()
        hook = {"src/useTodos.ts": "const label = '<input />';\n"}
        self.assertEqual(set(), rule_ids(detectors.scan(hook, catalog)) & set(A11Y_RULES))

    def test_shipped_examples_pass_accessibility_rules(self) -> None:
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

    def test_excludes_tests(self) -> None:
        catalog = RuleCatalog.defaults()
        files = {"src/App.test.tsx": "const [todos, setTodos] = useState([]);\n"}
        self.assertEqual([], detectors.scan(files, catalog))

    def test_new_only_and_line_level(self) -> None:
        violation = Violation(
            FILE_OVER_200_LINES,
            CodeLocation("src/App.tsx", LineRange(1, 210)),
            "src/App.tsx",
            "msg",
            210,
            "file",
        )
        changeset = Changeset({"src/App.tsx": [LineRange(1, 210)]})
        run = ReviewRun.open("base", "head", changeset)
        run.assess([violation], [])
        self.assertEqual(1, len(run.findings()))
        run = ReviewRun.open("base", "head", changeset)
        run.assess([violation], [violation])
        self.assertEqual([], run.findings())
        other = Changeset({"src/other.tsx": [LineRange(1, 5)]})
        run = ReviewRun.open("base", "head", other)
        run.assess([violation], [])
        self.assertEqual([], run.findings())

    def test_worsening_and_neutral_verdict(self) -> None:
        changeset = Changeset({"src/App.tsx": [LineRange(1, 220)]})
        previous = Violation(
            FILE_OVER_200_LINES,
            CodeLocation("src/App.tsx", LineRange(1, 205)),
            "src/App.tsx",
            "msg",
            205,
            "file",
        )
        current = Violation(
            FILE_OVER_200_LINES,
            CodeLocation("src/App.tsx", LineRange(1, 220)),
            "src/App.tsx",
            "msg",
            220,
            "file",
        )
        run = ReviewRun.open("base", "head", changeset)
        run.assess([current], [previous])
        self.assertEqual(1, len(run.findings()))
        self.assertEqual("NEUTRAL", run.verdict().status)

    def test_delivery(self) -> None:
        changeset = Changeset({"src/App.tsx": [LineRange(1, 210)]})
        run = ReviewRun.open("base", "head", changeset)
        run.assess(
            [
                Violation(
                    FILE_OVER_200_LINES,
                    CodeLocation("src/App.tsx", LineRange(1, 210)),
                    "src/App.tsx",
                    "too long",
                    210,
                    "file",
                )
            ],
            [],
        )
        report = run.summarize()
        markdown = delivery.summary_markdown(report)
        self.assertIn(delivery.COMMENT_MARKER, markdown)
        self.assertIn("FILE_OVER_200_LINES", markdown)
        payload = delivery.machine_findings(report)
        self.assertEqual("compforge.architecture-review.v1", payload["schema"])
        self.assertEqual(1, len(payload["findings"]))
        clean = ReviewRun.open("base", "head", changeset).summarize()
        self.assertIn(
            "No new or worsened hard-rule violations",
            delivery.summary_markdown(clean),
        )


if __name__ == "__main__":
    unittest.main()
