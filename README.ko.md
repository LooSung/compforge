# Compforge

![CI](https://github.com/LooSung/compforge/actions/workflows/lint.yml/badge.svg)
![Examples](https://github.com/LooSung/compforge/actions/workflows/examples.yml/badge.svg)
![License](https://img.shields.io/github/license/LooSung/compforge)

> **AI가 UI를 만든다. Compforge가 컴포넌트 아키텍처를 지킨다.**

Compforge는 **TypeScript + React**(Vite 또는 Next.js) 프론트엔드에서 일하는
코딩 에이전트용 스킬 팩입니다. 에이전트가 UI를 쓰기 전에 컴포넌트 경계와 상태가
놓일 자리(서버 / 클라이언트 / URL)를 먼저 정하게 하고, 결과를 측정 가능한
하드 룰로 검사합니다.

**Claude Code**, **Codex CLI**, **Cursor Agent CLI**에서 동작합니다.

[English](./README.md) · [한국어](./README.ko.md)

## Forge 패밀리

| 팩 | 대상 | 스택 |
|---|---|---|
| **Compforge** (이 저장소) | 프론트엔드 | TypeScript + React |
| [OOPforge](https://github.com/LooSung/oopforge) | 백엔드 | Java Spring · Python FastAPI · Kotlin Spring·TypeScript Next.js (실험적) |
| [FuseForge](https://github.com/LooSung/fuseforge) | 두 쪽에 걸친 기능 하나 | Compforge + OOPforge 조율 (실험적) |

각 팩은 단독으로 쓸 수 있습니다. Claude Code에서는 `forge` 마켓플레이스 하나로 셋 다 받을 수 있습니다.

## 설치

**Claude Code**는 플러그인 마켓플레이스로 (실험적):

```text
/plugin marketplace add LooSung/compforge
/plugin install compforge@forge
```

다른 Forge 저장소에서 `forge`를 이미 추가했다면 첫 줄은 건너뜁니다.
플러그인 파일은 프로젝트 밖에 있으므로 한 번 읽기 허용이 필요합니다:
[읽기 권한](docs/setup/claude-code.md#plugin-marketplace-experimental).

**Codex CLI**, 또는 플러그인 없이 Claude Code를 쓸 때는 설치 스크립트로:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

스크립트는 `~/.compforge`를 clone하고 Claude Code와 Codex에 연결합니다. 하니스마다
한 가지 경로만 쓰고, 에이전트를 재시작하세요. Cursor는 수동 단계가 하나 있습니다: [Cursor 설정](docs/setup/cursor.md).
릴리스 고정 설치, 업데이트, 제거: [설치 가이드](docs/setup/install.md).

## 사용

에이전트는 `~/.compforge`가 아니라 **내 프론트엔드 프로젝트**에서 시작합니다:

```text
/compforge:craft 장바구니 아이템에 수량 스테퍼 추가
/compforge:refactor 동작은 그대로 두고 장바구니 페이지 분리
/compforge:review PR 42 리뷰
```

| 하니스 | 호출 방법 |
|---|---|
| Claude Code | `/compforge:craft <요청>` |
| Codex CLI | `/skills` → **compforge** 선택 후 `Use Compforge craft: <요청>` (앞에 `/` 없음) |
| Cursor Agent CLI | [Cursor 설정](docs/setup/cursor.md)대로 플러그인을 로드한 뒤 `Use Compforge craft: <요청>` |

## 명령

| 명령 | 언제 쓰나 | 절대 하지 않는 것 |
|---|---|---|
| `craft` | **기본값.** 컴포넌트, 기능 추가, UI 버그 | 필요한 단계 생략, 범위를 몰래 넓히기 |
| `refactor` | 동작을 바꾸지 않는 구조 개선 | 기능 추가, 보이는 UI 변경 |
| `consult` | 질문, 비교, 리뷰, 계획 문서 1개 | 코드 변경 |
| `test` | 훅·컴포넌트 테스트 검증·작성·강화 | 프로덕션 동작 변경, 기본으로 E2E 추가 |
| `crucible` | 변경 하나를 계획 → 구현 → 리팩터 → 테스트까지 한 번에 | 계획 승인 전에 구현 시작 |
| `review` | diff, 브랜치, PR 하나에 대한 P1/P2/P3 지적 | 코드 변경, 요청 없이 PR에 게시 |
| `jira` | Jira 카드 1개, 또는 에픽·스토리 하나의 하위 작업 | 해당 이슈 외의 변경 |

뭘 써야 할지 모르겠다면 `craft`를 쓰세요. 가장 작은 경로를 알아서 고릅니다.

## 동작 방식

1. **계약 먼저.** UI 로직 전에 Craft가 가정(Assumptions)과 컴포넌트 계약
   (Component Contract)을 밝힙니다: 각 컴포넌트가 무엇을 소유하고 상태가
   어디에 사는지.
2. **가장 작은 경로.** 한 줄 수정은 한 줄로 끝납니다. 새 기능 영역이나 큰
   화면은 전체 흐름을 거치고, 단계마다 사용자가 승인합니다:

   ```text
   Discovery → Design → Delivery Plan → Skeleton → Implement → Test
   ```

3. **검사.** 완료 보고 전에 [하드 룰](skills/principles/hard-rules.md)
   (MUST / SHOULD / NEVER)로 결과를 검증합니다.

스택은 메뉴가 아니라 사다리입니다. 기본은 `react-vite-feature`, SSR이 필요하면
`react-next-app`, 기능 영역이 대략 다섯 개를 넘거나 여러 팀일 때만
`react-vite-fsd`. Vue는 1.x 범위 밖입니다.

### Before → after

```tsx
// Before: 거대한 페이지, 서버 데이터를 클라이언트 상태에, 파생 상태를 effect로 동기화
function CartPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  useEffect(() => { fetch('/cart').then(...) }, []);
  useEffect(() => { setTotal(items.reduce(...)) }, [items]);
}

// After: 상태의 집은 하나, 렌더링 없이 테스트 가능한 로직, 작은 컴포넌트
function CartPage() {
  const { items, addItem, removeItem } = useCart();
  const total = sumTotal(items);
  return <CartList items={items} onRemove={removeItem} />;
}
```

## 프로젝트에 남기기 (선택)

`init.sh`는 `AGENTS.md` 포인터와 `compforge-lock.json`을 쓰고, 스택에 맞는
import 경계 린트와 PR 차단 체크를 설치합니다. 저장소만 clone한 팀원도 같은
규칙을 받습니다. 자신이 생성하지 않은 파일은 덮어쓰지 않습니다. `init.sh`는 스크립트 설치에 포함됩니다.

```bash
~/.compforge/scripts/setup/init.sh            # 설치
~/.compforge/scripts/setup/init.sh --verify   # 나중에: 가드가 아직 살아 있나?
```

프로젝트 스위치 — 내 프로젝트 `AGENTS.md`에 한 줄씩:

| 줄 | 효과 |
|---|---|
| `Compforge continuity: off` | `.craft/` 작업 노트를 끕니다. 기본값은 실행 작업마다 노트를 남기고, 편집 전에 미완료 작업을 이어갑니다. |
| `Compforge work dir: <path>` | 작업 노트를 `.craft/`가 아닌 곳에 저장 |
| `Compforge live run: on` | Craft·Refactor가 앱을 직접 띄워 확인 |
| `Compforge cleanup pass: on` | 검증 후 Refactor가 `/simplify` 실행 |

## 더 보기

- [예제](examples/README.md): 같은 todo 앱을 세 스택으로
- [장바구니 워크스루](docs/guides/cart/README.ko.md): 실제 화면 하나로 Discovery → Test
- 설정: [Claude Code](docs/setup/claude-code.md) · [Codex](docs/setup/codex.md) ·
  [Cursor](docs/setup/cursor.md) · [설치·업데이트·제거](docs/setup/install.md)
- [지원 범위](docs/reference/support-scope.md) ·
  [Proof 실행 결과](docs/proof/README.md) (불리한 결과 포함) ·
  [한국어 방법론 가이드](docs/reference/methodology.ko.md) · [전체 문서](docs/README.md)
- [변경 이력](CHANGELOG.md) · [기여 가이드](.github/CONTRIBUTING.md) ·
  [메인테이너용 에이전트 노트](AGENTS.md)

## 라이선스

MIT
