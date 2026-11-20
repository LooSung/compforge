# Compforge

![CI](https://github.com/LooSung/compforge/actions/workflows/lint.yml/badge.svg)
![Examples](https://github.com/LooSung/compforge/actions/workflows/examples.yml/badge.svg)
![License](https://img.shields.io/github/license/LooSung/compforge)

> **AI ships the UI. Compforge keeps the component architecture.**

Compforge is a skill pack for coding agents working on **TypeScript + React**
frontends (Vite or Next.js). Before your agent writes UI, it decides component
boundaries and where each piece of state lives (server / client / URL). Then it
checks the result against measurable Hard Rules.

Works with **Claude Code**, **Codex CLI**, and **Cursor Agent CLI**.

[English](./README.md) · [한국어](./README.ko.md)

## The Forge family

| Pack | For | Stack |
|---|---|---|
| **Compforge** (this repo) | Frontend | TypeScript + React |
| [OOPforge](https://github.com/LooSung/oopforge) | Backend | Java Spring · Python FastAPI · Kotlin Spring and TypeScript Next.js (experimental) |
| [FuseForge](https://github.com/LooSung/fuseforge) | One feature across both | Coordinates Compforge + OOPforge (experimental) |

Each pack works on its own. In Claude Code, the `forge` marketplace offers all three.

## Install

**Claude Code**, from the plugin marketplace (experimental):

```text
/plugin marketplace add LooSung/compforge
/plugin install compforge@forge
```

If `forge` is already added from another Forge repo, skip the first line.
Plugin files sit outside your project, so allow reading them once:
[read permission](docs/setup/claude-code.md#plugin-marketplace-experimental).

**Codex CLI**, or Claude Code without plugins, with the install script:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

The script clones `~/.compforge` and links it into Claude Code and Codex. Pick one
path per harness, then restart your agent. Cursor needs one manual step: [Cursor setup](docs/setup/cursor.md).
Pinned releases, updates, and removal: [install guide](docs/setup/install.md).

## Use

Start your agent from **your frontend project**, not from `~/.compforge`:

```text
/compforge:craft Add a quantity stepper to the cart item
/compforge:refactor Split the cart page without changing behavior
/compforge:review Review PR 42
```

| Harness | How to call |
|---|---|
| Claude Code | `/compforge:craft <request>` |
| Codex CLI | `/skills` → **compforge**, then `Use Compforge craft: <request>` (no leading `/`) |
| Cursor Agent CLI | Load the plugin per [Cursor setup](docs/setup/cursor.md), then `Use Compforge craft: <request>` |

## Commands

| Command | Use it for | It never |
|---|---|---|
| `craft` | **Default.** A component, a feature addition, a UI bug | Skips required stages or widens scope silently |
| `refactor` | Restructure without changing behavior | Adds features or changes visible UI |
| `consult` | Ask, compare, review, or write one plan document | Changes code |
| `test` | Verify, write, or strengthen hook and component tests | Changes production behavior or adds E2E by default |
| `crucible` | Plan → build → refactor → test one change in one request | Builds before you approve the plan |
| `review` | P1/P2/P3 findings on one diff, branch, or PR | Changes code or posts to a PR unless asked |
| `jira` | One Jira card, or the child tasks of one epic or story | Touches anything but those issues |

Not sure which one? Use `craft`. It picks the smallest path.

## How it works

1. **Contract first.** Before UI logic, Craft states its Assumptions and a
   Component Contract: what each component owns and where state lives.
2. **Smallest path.** A one-line fix stays one line. A new feature area or a
   large screen goes through the full flow, and you approve each stage:

   ```text
   Discovery → Design → Delivery Plan → Skeleton → Implement → Test
   ```

3. **Checked.** Craft verifies the result against the
   [Hard Rules](skills/principles/hard-rules.md) (MUST / SHOULD / NEVER) before
   it reports done.

Stacks form a ladder, not a menu: `react-vite-feature` by default,
`react-next-app` when you need SSR, and `react-vite-fsd` only past about five
feature areas or several teams. Vue is outside the 1.x scope.

### Before → after

```tsx
// Before: god page, server data in client state, derived state synced by effects
function CartPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  useEffect(() => { fetch('/cart').then(...) }, []);
  useEffect(() => { setTotal(items.reduce(...)) }, [items]);
}

// After: one state home, logic testable without rendering, small components
function CartPage() {
  const { items, addItem, removeItem } = useCart();
  const total = sumTotal(items);
  return <CartList items={items} onRemove={removeItem} />;
}
```

## Keep it in your project (optional)

`init.sh` writes an `AGENTS.md` pointer and `compforge-lock.json`, and installs
the stack's import-zone lint with a PR-blocking check. A teammate who clones only
your repository then gets the same rules. It never overwrites files it did not
generate. `init.sh` comes with the script install.

```bash
~/.compforge/scripts/setup/init.sh            # install
~/.compforge/scripts/setup/init.sh --verify   # later: is the guard still alive?
```

Project switches, one line each in your project's `AGENTS.md`:

| Line | Effect |
|---|---|
| `Compforge continuity: off` | Stop keeping `.craft/` work notes. By default, execution tasks keep them and resume unfinished work before editing. |
| `Compforge work dir: <path>` | Keep work notes somewhere other than `.craft/` |
| `Compforge live run: on` | Let Craft and Refactor launch the app to check it |
| `Compforge cleanup pass: on` | Let Refactor run `/simplify` after verification |

## Learn more

- [Examples](examples/README.md): the same todo app on all three stacks
- [Cart walkthrough](docs/guides/cart/README.md): Discovery → Test on one real screen
- Setup: [Claude Code](docs/setup/claude-code.md) · [Codex](docs/setup/codex.md) ·
  [Cursor](docs/setup/cursor.md) · [Install, update, remove](docs/setup/install.md)
- [Support scope](docs/reference/support-scope.md) ·
  [Proof runs](docs/proof/README.md), unfavourable ones included ·
  [All docs](docs/README.md)
- [Changelog](CHANGELOG.md) · [Contributing](.github/CONTRIBUTING.md) ·
  [Agent notes for maintainers](AGENTS.md)

## License

MIT
