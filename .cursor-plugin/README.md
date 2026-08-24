# Cursor Plugin Manifest

`.cursor-plugin/plugin.json` packages the verified explicit local-plugin path.
Marketplace publication remains experimental and outside the current support
scope.

## Use today

Register the pack as a local plugin, then pass the directory explicitly:

```bash
mkdir -p ~/.cursor/plugins/local
ln -s ~/.compforge ~/.cursor/plugins/local/compforge
cd /path/to/your-frontend-project
cursor-agent --plugin-dir ~/.cursor/plugins/local/compforge
```

Invoke Craft with `Use Compforge craft: <request>`. There is no
`scripts/setup/install.sh` symlink target for Cursor.

## Local plugin verdict

The current package loaded Craft in a clean headless Cursor Agent test on
2026-08-24 (`2026.08.11-e8db854`) when supplied with `--plugin-dir`.

Test conditions:

- empty temporary workspace;
- `CURSOR_CONFIG_DIR` isolation with only non-secret login metadata;
- this repository passed as `--plugin-dir`;
- fresh one-shot sessions with positive and negative controls.

The explicit plugin run automatically reads the packaged skill adapter and
canonical Craft files. An empty workspace without `--plugin-dir` returned
`COMPFORGE_NOT_LOADED`. `/compforge:craft` with `--plugin-dir` entered Craft;
the documented Cursor invoke remains `Use Compforge craft: …`.

Result: the explicit local-plugin command and the project-local skill link are
supported paths. Maintainers can reproduce both positive controls, slash
routing, and the isolated negative control with
`scripts/ci/harness-smoke.sh live cursor`.
Marketplace publication and bootstrap integration remain future work.
