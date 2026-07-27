#!/usr/bin/env python3
"""Evaluate one Compforge proof workspace with deterministic, task-specific checks.

Every check is a regex heuristic over the diff, so it can miss a violation and
it can accuse an innocent line. The protocol requires human confirmation of each
finding before a result is published.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


STATE_BINDING = re.compile(r"const\s*\[\s*(\w+)\s*,\s*set\w+\s*\]\s*=\s*useState")
QUERY_NAME = re.compile(r"^(q|query|search\w*|\w*searchterm|\w*query|keyword|term|filtertext)$", re.I)
SERVER_NAME = re.compile(r"^(\w*todos|items|list|data)$", re.I)
DERIVED_NAME = re.compile(r"^(filtered\w*|visible\w*|match\w*|\w*matches|results?|\w*count|shown\w*)$", re.I)

USE_EFFECT = re.compile(r"\buseEffect\s*\(")
CACHE_WRITE = re.compile(r"\bsetQueryData\s*\(")
DIRECT_MUTATION = re.compile(r"^\s*[\w.]+\.(?:completed|title)\s*=[^=]|\.push\(|\.splice\(", re.MULTILINE)
ANY_TYPE = re.compile(r":\s*any\b|\bas\s+any\b")
EXPORTED_COMPONENT = re.compile(r"^export\s+(?:default\s+)?(?:function|const)\s+([A-Z]\w*)", re.MULTILINE)
CASE_FOLD = re.compile(r"\.toLowerCase\(\)|\.toLocaleLowerCase\(\)")
NARROWING = re.compile(r"\.filter\(|\.includes\(")
IMPORT_SOURCE = re.compile(r"""(?:from|import)\s*\(?\s*['"]([^'"]+)['"]""")
FEATURE_SEGMENT = re.compile(r"features/(\w+)")
API_MODULE = re.compile(r"(?:^|/)api(?:/|$)")
SEARCH_TERM = re.compile(r"match|search|quer", re.I)
INPUT_TAG = re.compile(r"<input\b[^>]*>", re.S)
INPUT_ID = re.compile(r'id="([^"]+)"')
# The rendered sentence, not a zero-check: a god component is full of unrelated
# `length === 0` guards, and any of them would pass a structural test.
NO_MATCH_COPY = re.compile(r"no(?:thing)?\s+[\w\s\u2019'\"]{0,30}?(match|result)", re.I)
# A named definition, not a stray word: "completed" appears in every status
# filter, and matching it accepted a component-inlined bulk loop as extracted.
DEFINITION = re.compile(r"(?:function|const|let)\s+(\w+)\s*[=(<:]")
BULK_VERB = re.compile(r"complete", re.I)
BULK_SCOPE = re.compile(r"all|many|match|todos|bulk", re.I)

ALLOWED_OUTSIDE_SRC = {".gitignore", "package.json", "package-lock.json"}


def git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", *args], cwd=root, text=True, capture_output=True, check=False
    )
    return result.stdout if result.returncode == 0 else ""


def changed_files(root: Path) -> list[Path]:
    output = subprocess.check_output(
        ["git", "diff", "--name-only", "--diff-filter=ACMR", "HEAD"],
        cwd=root,
        text=True,
    )
    return [root / line for line in output.splitlines() if line]


def relative(path: Path, root: Path) -> str:
    return path.relative_to(root).as_posix()


def is_test(rel: str) -> bool:
    return ".test." in rel or rel.startswith("src/testing/")


def is_component(rel: str) -> bool:
    return rel.endswith(".tsx") and not is_test(rel)


def state_findings(content: str, rel: str) -> list[dict[str, object]]:
    findings: list[dict[str, object]] = []
    for name in STATE_BINDING.findall(content):
        if QUERY_NAME.match(name):
            rule = "search-query-in-usestate"
        elif SERVER_NAME.match(name):
            rule = "server-data-in-usestate"
        elif DERIVED_NAME.match(name):
            rule = "derived-value-in-usestate"
        else:
            continue
        findings.append({"rule": rule, "file": rel, "binding": name})
    return findings


def import_findings(content: str, rel: str) -> list[dict[str, object]]:
    findings: list[dict[str, object]] = []
    own = FEATURE_SEGMENT.search(rel)
    for source in IMPORT_SOURCE.findall(content):
        target = FEATURE_SEGMENT.search(source)
        if own and target and target.group(1) != own.group(1):
            findings.append({"rule": "cross-feature-import", "file": rel, "import": source})
        if is_component(rel) and API_MODULE.search(source):
            findings.append({"rule": "component-imports-api", "file": rel, "import": source})
    return findings


def content_findings(content: str, rel: str) -> list[dict[str, object]]:
    if is_test(rel) or not rel.startswith("src/"):
        return []

    findings = state_findings(content, rel) + import_findings(content, rel)
    line_count = len(content.splitlines())

    if line_count > 200:
        findings.append({"rule": "file-over-200-lines", "file": rel, "lines": line_count})
    # One finding per effect, so baseline subtraction reports effects the run
    # added rather than going quiet on a file that already had one.
    for occurrence in range(len(USE_EFFECT.findall(content))):
        findings.append({"rule": "useeffect-added", "file": rel, "occurrence": occurrence})
    if CACHE_WRITE.search(content) or DIRECT_MUTATION.search(content):
        findings.append({"rule": "direct-mutation-or-cache-write", "file": rel})
    if ANY_TYPE.search(content):
        findings.append({"rule": "any-type", "file": rel})
    if rel.endswith(("/index.ts", "/index.tsx")):
        findings.append({"rule": "barrel-file", "file": rel})
    if is_component(rel):
        exported = EXPORTED_COMPONENT.findall(content)
        if len(exported) > 1:
            findings.append({"rule": "multiple-exported-components", "file": rel, "exports": exported})
        if CASE_FOLD.search(content) and NARROWING.search(content):
            findings.append({"rule": "matching-logic-in-component", "file": rel})
    return findings


def finding_key(finding: dict[str, object]) -> tuple[object, ...]:
    return (
        finding.get("rule"),
        finding.get("file"),
        finding.get("binding"),
        finding.get("occurrence"),
    )


def architecture_findings(sources: dict[str, str], root: Path) -> list[dict[str, object]]:
    findings: list[dict[str, object]] = []
    for rel, content in sources.items():
        current = content_findings(content, rel)
        previous = {
            finding_key(item)
            for item in content_findings(git(root, "show", f"HEAD:{rel}"), rel)
        }
        findings.extend(item for item in current if finding_key(item) not in previous)
        if not rel.startswith(("src/", ".craft/")) and rel not in ALLOWED_OUTSIDE_SRC:
            findings.append({"rule": "possible-unrelated-change", "file": rel})
    return findings


def search_input_is_labelled(production: dict[str, str]) -> bool:
    """True only when the *search* input carries a name, not merely when the
    file happens to contain some other label."""
    for body in production.values():
        for tag in INPUT_TAG.findall(body):
            if not SEARCH_TERM.search(tag):
                continue
            if "aria-label" in tag:
                return True
            identifier = INPUT_ID.search(tag)
            if identifier and f'htmlFor="{identifier.group(1)}"' in body:
                return True
    return False


def bulk_completion_is_extracted(production: dict[str, str]) -> bool:
    for rel, body in production.items():
        if is_component(rel):
            continue
        for name in DEFINITION.findall(body):
            if BULK_VERB.search(name) and BULK_SCOPE.search(name):
                return True
    return False


def coverage_checks(sources: dict[str, str]) -> dict[str, bool]:
    production = {rel: body for rel, body in sources.items() if not is_test(rel)}
    tests = {rel: body for rel, body in sources.items() if is_test(rel)}
    joined = "\n".join(production.values())
    # Layout-agnostic: "not a component" is the rule both stacks share, whether
    # the destination is features/todos/lib or a flat utils folder.
    logic = "\n".join(
        body for rel, body in production.items() if not is_component(rel)
    )
    return {
        "query_in_url": "useSearchParamState" in joined or "URLSearchParams" in joined,
        "matching_logic_extracted": bool(CASE_FOLD.search(logic) and NARROWING.search(logic)),
        "bulk_completion_outside_component": bulk_completion_is_extracted(production),
        "accessible_label": search_input_is_labelled(production),
        "live_region": "aria-live" in joined or 'role="status"' in joined,
        "empty_state_for_no_matches": bool(NO_MATCH_COPY.search(joined)),
        "matching_test": any(SEARCH_TERM.search(body) for rel, body in tests.items()),
        "behavior_test": any(
            SEARCH_TERM.search(body) for rel, body in tests.items() if rel.endswith(".test.tsx")
        ),
    }


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: evaluate-run.py <workspace>", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).resolve()
    paths = [path for path in changed_files(root) if path.is_file()]
    sources = {
        relative(path, root): path.read_text(encoding="utf-8", errors="replace")
        for path in paths
    }

    checks = coverage_checks(sources)
    findings = architecture_findings(sources, root)
    for name, passed in checks.items():
        if not passed:
            findings.append({"rule": f"missing-{name.replace('_', '-')}"})

    result = {
        "workspace": str(root),
        "changed_files": sorted(sources),
        "checks": checks,
        "violation_count": len(findings),
        "findings": findings,
    }
    print(json.dumps(result, indent=2, sort_keys=True))
    return 1 if findings else 0


if __name__ == "__main__":
    raise SystemExit(main())
