#!/usr/bin/env python3
"""Regression tests for session-scoped harness activation."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import tempfile
import textwrap
import unittest


ROOT = Path(__file__).resolve().parents[2]
HARNESS = ROOT / "scripts/ci/harness-smoke.sh"


class HarnessSmokeTests(unittest.TestCase):
    def test_claude_manifest_uses_plugin_root_contract(self) -> None:
        manifest = json.loads(
            (ROOT / ".claude-plugin/plugin.json").read_text(encoding="utf-8")
        )

        self.assertIsInstance(manifest["repository"], str)
        self.assertEqual(["./skills/"], manifest["skills"])
        self.assertEqual(["./commands/"], manifest["commands"])

    def test_claude_live_probe_does_not_rebind_existing_links(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            home = temp / "home"
            expected = {
                home / ".claude/skills/compforge": temp / "installed-claude-skills",
                home / ".claude/commands/compforge": temp / "installed-claude-commands",
                home / ".codex/skills/compforge": temp / "installed-codex-skills",
            }
            for link, target in expected.items():
                link.parent.mkdir(parents=True, exist_ok=True)
                target.mkdir()
                link.symlink_to(target)

            result, log = self.run_fake_claude(home, temp, expected)

            self.assertEqual(0, result.returncode, f"{result.stderr}\n{log}")
            self.assertIn("plugin validate --strict", log)
            self.assertIn(f"--plugin-dir {ROOT}", log)
            self.assertIn("stdin=/compforge:harness-probe", log)
            for link, target in expected.items():
                self.assertEqual(str(target), os.readlink(link))

    def test_claude_live_probe_does_not_create_global_links(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            temp = Path(directory)
            home = temp / "home"
            home.mkdir()

            result, log = self.run_fake_claude(home, temp, {})

            self.assertEqual(0, result.returncode, f"{result.stderr}\n{log}")
            self.assertIn("plugin validate --strict", log)
            self.assertIn(f"--plugin-dir {ROOT}", log)
            self.assertIn("stdin=/compforge:harness-probe", log)
            self.assertFalse((home / ".claude/skills/compforge").exists())
            self.assertFalse((home / ".claude/commands/compforge").exists())
            self.assertFalse((home / ".codex/skills/compforge").exists())

    def run_fake_claude(
        self, home: Path, temp: Path, expected: dict[Path, Path]
    ) -> tuple[subprocess.CompletedProcess[str], str]:
        bin_dir = temp / "bin"
        bin_dir.mkdir()
        log = temp / "claude.log"
        expected_file = temp / "expected-links"
        expected_file.write_text(
            "".join(f"{link}={target}\n" for link, target in expected.items()),
            encoding="utf-8",
        )
        fake = bin_dir / "claude"
        fake.write_text(
            textwrap.dedent(
                """\
                #!/usr/bin/env bash
                set -euo pipefail
                printf '%s\n' "$*" >> "$FAKE_CLAUDE_LOG"
                while IFS='=' read -r link target; do
                  [ -z "$link" ] && continue
                  [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ] || {
                    printf 'global link changed: %s\n' "$link" >&2
                    exit 41
                  }
                done < "$EXPECTED_LINKS"
                for link in \
                  "$HOME/.claude/skills/compforge" \
                  "$HOME/.claude/commands/compforge" \
                  "$HOME/.codex/skills/compforge"; do
                  if [ ! -s "$EXPECTED_LINKS" ] && [ -e "$link" -o -L "$link" ]; then
                    printf 'global link created: %s\n' "$link" >&2
                    exit 42
                  fi
                done
                case " $* " in
                  *" plugin validate "*) exit 0 ;;
                  *" --version "*) printf 'Claude Code test double\n' ;;
                  *" --plugin-dir "*)
                    prompt="$(cat)"
                    printf 'stdin=%s\n' "$prompt" >> "$FAKE_CLAUDE_LOG"
                    printf 'COMPFORGE_PLUGIN_ROOT=%s\n' "$EXPECTED_PLUGIN_ROOT"
                    printf 'COMPFORGE_LOADED\nAssumptions\nComponent Contract\n'
                    ;;
                  *)
                    prompt="$(cat)"
                    printf 'stdin=%s\n' "$prompt" >> "$FAKE_CLAUDE_LOG"
                    printf 'COMPFORGE_NOT_LOADED\n'
                    ;;
                esac
                """
            ).lstrip(),
            encoding="utf-8",
        )
        fake.chmod(0o755)
        env = os.environ.copy()
        env.update(
            {
                "COMPFORGE_HARNESS_TIMEOUT": "10",
                "EXPECTED_LINKS": str(expected_file),
                "EXPECTED_PLUGIN_ROOT": str(ROOT),
                "FAKE_CLAUDE_LOG": str(log),
                "HOME": str(home),
                "PATH": f"{bin_dir}{os.pathsep}{env['PATH']}",
            }
        )
        result = subprocess.run(
            [str(HARNESS), "live", "claude"],
            cwd=ROOT,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
        return result, log.read_text(encoding="utf-8")


if __name__ == "__main__":
    unittest.main()
