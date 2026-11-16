---
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
---

Use Compforge review on this pasted diff. Do not edit any files.

```diff
--- a/src/features/cart/CartSummary.tsx
+++ b/src/features/cart/CartSummary.tsx
@@ -1,7 +1,21 @@
-import { useCartItems } from './useCartItems';
+import { useEffect, useState } from 'react';
+import { useCartItems } from './useCartItems';

 export function CartSummary() {
-  const { items } = useCartItems();
-  const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
-  return <p>Total: {total}</p>;
+  const { items, isLoading, error } = useCartItems();
+  const [total, setTotal] = useState(0);
+
+  useEffect(() => {
+    setTotal(items.reduce((sum, item) => sum + item.price * item.quantity, 0));
+  }, [items]);
+
+  if (isLoading) return <p>Loading…</p>;
+  return (
+    <div>
+      <p>Total: {total}</p>
+      <div onClick={() => window.location.assign('/checkout')}>Checkout</div>
+    </div>
+  );
 }
```
