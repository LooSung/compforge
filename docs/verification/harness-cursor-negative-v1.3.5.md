# v1.3.5 Cursor negative-control verification

## Candidate

- Probed checkout: `v1.3.5` (`52026c8`)
- Date: 2026-08-31
- Policy: local authenticated checks; no repository provider secrets
- CLI: Cursor Agent `2026.08.25-3e8eec8`

This record exists because v1.3.4 skipped Cursor's negative control on a HOME
where the pack was installed. The skip is still the correct path while those
links exist. This run proves the control itself: uninstall the HOME-scoped
links, probe, then restore them.

## Method

The leaking links pointed at `~/.compforge` (v1.3.1), not this checkout.
`./scripts/setup/uninstall.sh` from the checkout leaves them in place because
the expected target does not match. Uninstall used
`~/.compforge/scripts/setup/uninstall.sh`. After the probes,
`~/.compforge/scripts/setup/install.sh` restored the same three links.

`~/.agents/skills/compforge` was absent. `CURSOR_API_KEY` was unset; the probe
reused the OS credential store through sanitized `cli-config.json` as in
`harness-smoke.sh`.

## Activation and isolation

| Check | Result |
|---|---|
| `--plugin-dir` craft, refactor, consult | `COMPFORGE_LOADED` |
| project-local skill plus `--add-dir` | `COMPFORGE_LOADED` |
| isolated workspace, no plugin, pack uninstalled | `COMPFORGE_NOT_LOADED` |
| `/compforge:craft` with `--plugin-dir` | entered Craft |

Claude and Codex were not re-probed. Their v1.3.4 records still stand.

## Release decision

Cursor's negative control is real, not only a skip. It passes when the
HOME-scoped pack is absent. `live cursor` must keep skipping when those links
are present; isolating `HOME` still loses the credential store.
