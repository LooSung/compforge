#!/usr/bin/env python3
"""Self-tests for evaluate-run.py failure modes."""

from __future__ import annotations

import importlib.util
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("evaluate-run.py")
SPEC = importlib.util.spec_from_file_location("evaluate_run", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)

GIT_IDENTITY = {
    **os.environ,
    "GIT_AUTHOR_NAME": "evaluate-test",
    "GIT_AUTHOR_EMAIL": "evaluate-test@example.com",
    "GIT_COMMITTER_NAME": "evaluate-test",
    "GIT_COMMITTER_EMAIL": "evaluate-test@example.com",
}

PREVIOUS_EFFECTS = """\
export function App() {
  useEffect(() => { setVisible(todos.filter(Boolean)); }, [todos]);
  useEffect(() => { setCount(visible.length); }, [visible]);
  useEffect(() => { fetchTodos(); }, []);
  return null;
}
"""

REPLACED_EFFECTS = """\
export function App() {
  useEffect(() => { setSearchQuery(params.get("q") ?? ""); }, []);
  useEffect(() => { history.replaceState(null, "", "?q=" + searchQuery); }, [searchQuery]);
  useEffect(() => { fetchTodos(); }, []);
  return null;
}
"""


def git(root: Path, *args: str) -> None:
    subprocess.run(
        ["git", *args],
        cwd=root,
        check=True,
        capture_output=True,
        text=True,
        env=GIT_IDENTITY,
    )


class EvaluatorTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def seed_file(self, relative: str, previous: str, current: str) -> None:
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(previous, encoding="utf-8")
        git(self.root, "init")
        git(self.root, "add", relative)
        git(self.root, "commit", "-m", "baseline")
        path.write_text(current, encoding="utf-8")

    def effect_findings(self, previous: str, current: str) -> list[dict[str, object]]:
        self.seed_file("src/App.tsx", previous, current)
        findings = MODULE.architecture_findings({"src/App.tsx": current}, self.root)
        return [item for item in findings if item["rule"] == "useeffect-added"]

    def test_replaced_effects_count_as_added(self) -> None:
        added = self.effect_findings(PREVIOUS_EFFECTS, REPLACED_EFFECTS)
        self.assertEqual(2, len(added), added)

    def test_unchanged_effects_are_not_added(self) -> None:
        added = self.effect_findings(PREVIOUS_EFFECTS, PREVIOUS_EFFECTS)
        self.assertEqual([], added)

    def test_extra_effect_is_added(self) -> None:
        current = PREVIOUS_EFFECTS.replace(
            "return null;",
            "useEffect(() => { document.title = String(count); }, [count]);\n  return null;",
        )
        added = self.effect_findings(PREVIOUS_EFFECTS, current)
        self.assertEqual(1, len(added), added)

    def test_status_filter_completed_word_is_not_bulk_extraction(self) -> None:
        production = {
            "src/App.tsx": (
                "export function App() {\n"
                "  matches.forEach((todo) => toggleTodo(todo.id));\n"
                "  return null;\n"
                "}\n"
            ),
            "src/utils/search.ts": (
                "export function filterByStatus(todos, status) {\n"
                "  return todos.filter((todo) => todo.completed === (status === 'completed'));\n"
                "}\n"
            ),
        }
        self.assertFalse(MODULE.bulk_completion_is_extracted(production))

    def test_named_complete_all_matches_outside_component_counts(self) -> None:
        production = {
            "src/App.tsx": "export function App() { completeAllMatches(matches); return null; }\n",
            "src/hooks/useTodos.ts": (
                "export function completeAllMatches(todos) {\n"
                "  return todos.filter((todo) => !todo.completed);\n"
                "}\n"
            ),
        }
        self.assertTrue(MODULE.bulk_completion_is_extracted(production))


if __name__ == "__main__":
    unittest.main()
