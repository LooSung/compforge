#!/usr/bin/env python3
"""Self-tests for non-destructive published-proof rescoring."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPT = Path(__file__).with_name("rescore-published.py")
SPEC = importlib.util.spec_from_file_location("rescore_published", SCRIPT)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


class RescorePublishedTests(unittest.TestCase):
    def test_main_preserves_curated_summary(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            results = Path(tmp)
            artifacts = results / "pair" / "artifacts"
            artifacts.mkdir(parents=True)
            (artifacts / "metadata.txt").write_text(
                "source_commit=1234567890abcdef\nstarter=starter\n",
                encoding="utf-8",
            )
            payload = {"violation_count": 1, "findings": []}
            for arm in ("control", "treatment"):
                (artifacts / f"{arm}-changes.patch").write_text("", encoding="utf-8")
                (artifacts / f"{arm}-evaluation.json").write_text(
                    json.dumps(payload),
                    encoding="utf-8",
                )

            summary = results / "2026-08-20-evaluator-rescore.md"
            curated = "# Curated interpretation\n\nKeep this prose.\n"
            summary.write_text(curated, encoding="utf-8")

            with (
                mock.patch.object(MODULE, "RESULTS", results),
                mock.patch.object(MODULE, "rescore_arm", return_value=payload),
                contextlib.redirect_stdout(io.StringIO()),
                contextlib.redirect_stderr(io.StringIO()),
            ):
                self.assertEqual(0, MODULE.main())

            self.assertEqual(curated, summary.read_text(encoding="utf-8"))
            for arm in ("control", "treatment"):
                rescored = artifacts / f"{arm}-evaluation-rescored.json"
                self.assertEqual(payload, json.loads(rescored.read_text(encoding="utf-8")))


if __name__ == "__main__":
    unittest.main()
