# 장바구니 — Compforge 워크스루

> TypeScript + React로 **장바구니 화면**을 끝까지.  
> Discovery → Design → Delivery Plan → Skeleton → Implement → Test.

[English](./README.md) · [한국어](./README.ko.md)

이 안내서는 Compforge를 **한 화면에서 끝까지** 쓰는 법이다. todo를 한 번 더
만드는 예제가 아니다. 최소 실행 증명은
[`examples/todo-react-feature`](../../../examples/todo-react-feature/)다.

Next 실행 예제는 [`examples/todo-react-next`](../../../examples/todo-react-next/)다.
이 워크스루가 아니다.

---

## 시나리오

고객이 **장바구니를 보고**, 수량을 바꾸고, 줄을 지운다. 합계는 입력에 따라
바뀐다. 빈 장바구니는 빈 페이지가 아니라 이름 있는 상태다. 결제는 범위 밖이다.

---

## Craft 프롬프트

Claude Code:

```text
/compforge:craft Start Discovery for the cart screen. No code yet.
```

Codex / Cursor는 `Use Compforge craft: …` (`/` 없이). 단계 목록과 예시 산출물은
영어 정본 [README.md](./README.md)에 있다.

---

## 단계

영어 정본을 따른다. 에이전트 산출물도 영어다.

| 단계 | 파일 |
|---|---|
| 1. Discovery | [01-discovery.md](./01-discovery.md) |
| 2. Design | [02-design.md](./02-design.md) |
| 3. Delivery Plan | [03-delivery-plan.md](./03-delivery-plan.md) |
| 4. Skeleton | [04-skeleton.md](./04-skeleton.md) |
| 5. Implement | [05-implement.md](./05-implement.md) |
| 6. Test | [06-test.md](./06-test.md) |
| 7. import 규칙 참고 | [07-import-rules.md](./07-import-rules.md) |

각 단계 끝에 **사람 승인**이 있다. 다음 단계로 건너뛰지 않는다.
