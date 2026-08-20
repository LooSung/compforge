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
    Changeset,
    CodeLocation,
    DERIVED_STATE_IN_EFFECT,
    FILE_OVER_200_LINES,
    LineRange,
    MULTIPLE_EXPORTED_COMPONENTS,
    ReviewRun,
    RuleCatalog,
    SERVER_DATA_IN_USESTATE,
    Violation,
)

RULES_FILE = (
    Path(__file__).resolve().parents[2] / "skills" / "principles" / "hard-rules.md"
)


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
