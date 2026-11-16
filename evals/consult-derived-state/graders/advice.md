---
type: llm
weight: 1
---

The response recommends computing the total during render (derived value) instead of storing it in state and syncing it with an effect, and gives a concrete reason such as avoiding stale or duplicated state or an extra render.
