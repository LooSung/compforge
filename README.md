# Compforge

> **AI ships the UI. Compforge keeps the component architecture.**
>
> *Harness engineering that stops vibe coding from wrecking your frontend.*

**Forge small. Compose forever.** Compforge defines disciplined React/TypeScript as a dialect your agent follows — skills are the grammar, hard rules are the lint, reference `examples/` are planned as the proof, and install + commands are the runtime. A methodology pack plus agent harness, not a UI library or a general agent framework.

It gives Claude Code, Codex CLI, Cursor, and compatible agents a clear way to design around **component boundaries**, **state placement** (server / client / URL), **custom hooks**, and **feature-based structure** before writing code.

Specialized for **TypeScript + React** (Vite or Next.js) — pick **feature folders** or **Feature-Sliced Design**. **Vue** support is on the roadmap, gated behind React being proven first.

Sister project: [OOPforge](https://github.com/LooSung/oopforge) — the same harness model for backend OOP/DDD (Java Spring / Python FastAPI).

[English](./README.md) · [한국어](./README.ko.md)

> **Status: v0.1 — scaffold.** Install, skills, and the Craft entry point work. Runnable reference examples, CI architecture lint, and the proof protocol are planned; see [docs/roadmap.md](docs/roadmap.md). Claims here are limited to what exists.

---

## **Quickstart**

### **1. Install**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

Check the install:

```bash
~/.compforge/scripts/setup/doctor.sh
```

### **2. Open your target project (not the pack)**

Compforge lives in `~/.compforge`. Your app code lives in **your frontend repo**. Always start the agent from that project:

```bash
cd /path/to/your-frontend-project
```

### **3. Restart / load your agent**

Restart Claude Code or Codex CLI so it picks up the new skills and commands.

**Cursor** integration is experimental. Link the skill into each target project:

```bash
mkdir -p .cursor/skills
ln -s ~/.compforge/skills .cursor/skills/compforge
printf '%s\n' '.cursor/skills/compforge' >> .git/info/exclude
```

### **4. Run Craft**

Entry point is **Craft** on every harness; only **how you invoke it** differs:

| Harness | Invoke |
|---|---|
| **Claude Code** | `/compforge:craft <request>` — registered slash command |
| **Codex CLI** | `/skills` → pick **compforge**, then prompt **without** a leading `/` |
| **Cursor Agent CLI** | After project-local skill setup, `Use Compforge craft: …` |

**Claude Code:**

```text
/compforge:craft Add a quantity stepper to the cart item
```

### **5. Update (manual — Releases do not auto-install)**

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

Then restart the agent.

---

## **The Basic Workflow**

Compforge uses a small delivery loop. *Do not merge planning, implementation, and verification.*

```text
Discovery → Design → Skeleton → Implement → Test
```

| Stage | Output | Do not do |
|---|---|---|
| **1. Discovery** | User flows, screen inventory, glossary, open questions | Code |
| **2. Design** | Component tree, state placement table, API contracts | Implementation |
| **3. Skeleton** | Feature folders, typed empty components/hooks | Business logic |
| **4. Implement** | One feature at a time, hooks first | Multiple features at once |
| **5. Test** | Unit (hooks), component, E2E checks | Untested logic hooks |

Each stage ends with a **human checkpoint** — do not skip ahead.

**For smaller, focused tasks** (one component, extending an existing feature, refactoring) — start with `/compforge:craft`. It picks the minimal path instead of forcing the full pipeline.

**Refactor is intentionally outside the default feature flow.** Use it for existing or imported code that needs cleanup without behavior changes.

### **Memory store (resume across sessions)**

Each execution work item gets one document at `.craft/<kind>-<slug>.md` tracking decisions, progress, and the next step. When you return, Craft reads the matching document **first** and continues from there. `.craft/` is gitignored by default. See [`skills/workflow/continuity.md`](skills/workflow/continuity.md).

---

## **Why Compforge**

Most teams already know *what* a clean React codebase looks like. The hard part is stopping the agent (or the team) from collapsing everything into a 600-line page component with eleven `useState`s and a `useEffect` chain. Compforge exists to make **structure** the default.

| Principle | What it means |
|---|---|
| **Small** | One skill, one concept; 200 lines per skill |
| **Measurable** | 200 lines/component file, 1 export/file — reviewable units |
| **Workflow-first** | Discovery → Test with human checkpoints |
| **State-first** | Every piece of state has exactly one named home |
| **Proof over philosophy** | Runnable examples planned before broad claims |

### Before (typical agent output)

```tsx
function CartPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);      // derived state, stored
  useEffect(() => { fetch('/cart').then(...) }, []);   // fetch chain
  useEffect(() => { setTotal(items.reduce(...)) }, [items]);  // sync effect
  // ...300 more lines of handlers and JSX
}
```

### After (Compforge)

```tsx
function CartPage() {
  const { items, addItem, removeItem } = useCart();  // logic in a hook, data in the query layer
  const total = sumTotal(items);                     // derived at render
  return <CartList items={items} onRemove={removeItem} />;  // components render
}
```

**Effects:** state has one home · logic testable without rendering · components stay small · agents follow a repeatable layout

---

## **Stacks**

| Stack | Architecture | When |
|---|---|---|
| `react-vite-feature` | Feature folders | Small/medium apps, MVP |
| `react-vite-fsd` | Feature-Sliced Design layers | Complex apps, larger teams |
| `react-next-app` | Next.js App Router + feature folders | SSR/SEO, server components |

Vue (Nuxt) is planned — gated behind the React vertical being proven and enforced first. See [docs/roadmap.md](docs/roadmap.md).

---

## **What's Inside**

```text
compforge/
├── skills/
│   ├── SKILL.md         Codex skill entry point
│   ├── workflow/        Discovery → Design → Skeleton → Implement → Test,
│   │                    plus Craft, Refactor, Continuity
│   ├── principles/      Component discipline
│   ├── react/           Component boundary · state placement · hooks
│   ├── lang/            Frontend stack selection
│   ├── skeleton/        Folder structure + empty types
│   └── antipatterns/    God component · useEffect abuse · prop drilling
├── commands/            Claude Code slash command: /compforge:craft
├── AGENTS.md            cross-agent repository instructions (Hard Rules)
├── CLAUDE.md            Claude Code bootstrap instructions
├── docs/roadmap.md      direction, phases, Vue expansion gates
└── scripts/
    ├── setup/           bootstrap, install, uninstall, doctor
    └── ci/              lint-skills.sh
```

### **Agent instruction files**

- **`AGENTS.md`** is the shared source of truth for Codex, Cursor, and other compatible agents.
- **`CLAUDE.md`** is a thin Claude Code entry point that imports `AGENTS.md`.

## **Hard Rules**

The enforceable, measurable rules live in [`AGENTS.md`](./AGENTS.md) (v0.1 draft, to be validated against reference examples before 1.0). Highlights: 200 lines/component file, 1 export/file, TS strict + no `any`, no direct mutation, server state in the query layer, useEffect as last resort, no prop drilling past 2 levels, feature imports through public APIs only.

---

## **Philosophy**

> **Model is replaceable. Workflow is permanent.**

Compforge is not a model layer. It is a **development protocol layer** for the frontend.

1. **Small** — one skill, one concept.
2. **Placed** — every piece of state has one named home.
3. **Composable** — components compose; features stay behind public APIs.
4. **Sustainable** — no mega-prompts; keep human checkpoints.

---

## **Inspiration**

- Dan Abramov's writing on effects and component thinking
- [Feature-Sliced Design](https://feature-sliced.design)
- [bulletproof-react](https://github.com/alan2207/bulletproof-react)
- React docs, *You Might Not Need an Effect*
- [OOPforge](https://github.com/LooSung/oopforge) — the sister methodology this pack mirrors

---

## **License**

MIT
