---
type: llm
weight: 1
---

The review identifies all three of these defects as findings (wording may differ):
1. the total is derived data stored in state and synced with `useEffect`; it should be computed during render;
2. the `error` value from `useCartItems` is ignored, so the error state is never shown;
3. the clickable `<div>` for Checkout is not keyboard-accessible or lacks a button role / accessible control.
Pass only if all three are reported.
