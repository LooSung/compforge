---
type: llm
weight: 1
---

The response is a prioritized code review, not a rewrite:
- it names the reviewed target and treats the pasted diff as the base (for example `pasted`);
- every finding carries a severity level of P1, P2, or P3 and points at `CartSummary.tsx` with a line or the offending code;
- it gives counts per level or an equivalent summary line;
- it does not claim to have edited files and does not post anywhere.
Pass only if all four hold.
