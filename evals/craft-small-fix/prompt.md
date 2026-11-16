---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

Use Compforge craft: the quantity stepper lets users go one above the stock limit. Fix it. This session cannot edit files, so reply with the change.

`src/features/cart/components/QuantityStepper.tsx`:

```tsx
type Props = { value: number; max: number; onChange: (next: number) => void };

export function QuantityStepper({ value, max, onChange }: Props) {
  return (
    <div role="group" aria-label="Quantity">
      <button type="button" onClick={() => onChange(value - 1)} disabled={value <= 1}>−</button>
      <span>{value}</span>
      <button type="button" onClick={() => onChange(value + 1)} disabled={value > max}>+</button>
    </div>
  );
}
```
