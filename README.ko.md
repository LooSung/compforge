# Compforge

![CI](https://github.com/LooSung/compforge/actions/workflows/lint.yml/badge.svg)
![Examples](https://github.com/LooSung/compforge/actions/workflows/examples.yml/badge.svg)
![License](https://img.shields.io/github/license/LooSung/compforge)

> **AI가 UI를 만든다. Compforge가 컴포넌트 아키텍처를 지킨다.**
>
> *바이브 코딩이 프론트엔드를 망가뜨리지 않게 하는 하니스 엔지니어링.*

**작게 벼리고, 영원히 조합한다.** Compforge는 이식 가능한 컴포넌트 아키텍처
방법론 팩이자 에이전트 하니스입니다. 스킬은 문법을 가르치고, 하드 룰은
린트처럼 작동하며, 실행 가능한 예제는 기준을 제공하고, Craft는 작업에 필요한
가장 작은 워크플로를 고릅니다.

**TypeScript + React**(Vite 또는 Next.js) 프론트엔드에서 명시적인 컴포넌트
경계, 상태 배치(서버 / 클라이언트 / URL), 리뷰 가능한 기능 구조가 필요할 때
사용합니다. UI 라이브러리, 범용 에이전트 프레임워크, 자동 코드 생성기는
아닙니다.

백엔드 자매 팩: [OOPforge](https://github.com/LooSung/oopforge).

[포지셔닝](docs/project/positioning.md) ·
[지원 범위](docs/reference/support-scope.md) ·
[Proof 프로토콜](docs/proof/README.md) · [문서 인덱스](docs/README.md)

[English](./README.md) · [한국어](./README.ko.md)

## 빠른 시작

### 1. 최신 `main` 설치

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

bootstrap은 `~/.compforge`를 clone 또는 갱신하고 감지된 Claude Code·Codex
링크를 설치합니다. Cursor는 자동 설정하지 않습니다.

### 2. 팩과 설치 링크 확인

```bash
~/.compforge/scripts/setup/doctor.sh
```

`doctor.sh`는 팩 구조와 링크를 검사하지만 Craft 로드를 증명하지는 않습니다.
4단계의 하네스별 설정으로 활성화를 확인하세요.

### 3. 프론트엔드 프로젝트로 이동

Compforge 팩은 `~/.compforge`에 있고 앱 코드는 **프론트엔드 저장소**에 있습니다.
에이전트는 항상 대상 프로젝트에서 시작합니다:

```bash
cd /path/to/your-frontend-project
```

### 4. Compforge를 로드하고 한 번 요청

| 하네스 | 로드와 호출 |
|---|---|
| **Claude Code** | Claude Code 재시작 후 `/compforge:craft <요청>` |
| **Codex CLI** | Codex 재시작 후 `/skills`에서 **compforge**를 고르고 `/` 없이 요청 |
| **Cursor Agent CLI** | `--plugin-dir ~/.cursor/plugins/local/compforge` 후 `Use Compforge craft: …` |

Claude Code:

```text
/compforge:craft 장바구니 아이템에 수량 조절 스테퍼 추가해줘
/compforge:refactor 장바구니 페이지를 동작 보존으로 쪼개줘
/compforge:consult 장바구니 상태 배치를 리뷰해줘
```

Codex CLI:

```text
Use Compforge craft: 장바구니 아이템에 수량 조절 스테퍼 추가해줘
Use Compforge refactor: 장바구니 페이지를 동작 보존으로 쪼개줘
Use Compforge consult: 장바구니 상태 배치를 리뷰해줘
```

Cursor는 `install.sh`가 설정하지 않습니다.
[Cursor 설정](docs/setup/cursor.md)에서 로컬 플러그인 또는 프로젝트 스킬 경로를
선택하세요.

Craft가 기본입니다. UI 로직 전에 Assumptions와 Component Contract를 제시합니다.
인가가 맞으면 Refactor나 Consult를 쓰세요. 설정 상세:
[Claude Code](docs/setup/claude-code.md) · [Codex](docs/setup/codex.md) ·
[Cursor](docs/setup/cursor.md).

### 5. 선택: 프로젝트에 팩을 남기기

`compforge init`은 `AGENTS.md` 포인터와 `compforge-lock.json`을 남겨서, 여러분의
레포만 클론한 에이전트도 Compforge를 읽어야 한다는 걸 알게 합니다. 함께 스택별
ESLint import 존(기능 폴더 / Next App Router) 또는 steiger(FSD)와 PR을 막는
GitHub Actions 체크를 복사합니다. Craft를 시험하는 데는 필수가 아닙니다.

```bash
~/.compforge/scripts/setup/init.sh
```

Init은 자신이 만들지 않은 파일을 보존하고 negative self-test로 배달된 가드를
검증합니다. 나중에 이 검증을 다시 실행하려면:

```bash
~/.compforge/scripts/setup/init.sh --verify
```

포인터는 곧 낡을 Hard Rules를 복사하지 않습니다. 배달 파일과 self-test 상세는
[`templates/README.md`](./templates/README.md)에 있습니다.

## 공개 커맨드

Craft가 기본입니다. Refactor와 Consult는 인가 경계가 달라서 따로 있습니다.
공개 `test` 커맨드는 없습니다.

| 커맨드 | 쓸 때 | 하면 안 되는 일 |
|---|---|---|
| `craft` | 구현하거나 가장 작은 프론트 경로를 고를 때 | 필수 단계를 건너뛰거나 범위를 몰래 넓히기 |
| `refactor` | 동작을 유지한 채 구조를 정리할 때 | 기능 추가나 보이는 UI 동작 변경 |
| `consult` | 질문, 비교, 리뷰, 계획 문서 하나 | 프로덕션·테스트·설정·CI 코드 변경 |

Claude: `/compforge:craft`, `/compforge:refactor`, `/compforge:consult`.
Codex·Cursor: `Use Compforge craft: …`, `refactor: …`, `consult: …`.

## 기본 워크플로

Craft가 작은 작업은 집중 경로를 고르고, 새 기능 영역이나
큰 화면은 전체 순서를 유지합니다:

```text
Discovery → Design → Delivery Plan → Skeleton → Implement → Test
```

각 단계 끝에는 사람 확인이 있습니다. 산출물과 라우팅 정본은
[`AGENTS.md`](AGENTS.md#required-workflow)이며, 리팩토링은 별도의 동작 보존
워크플로입니다.

출하된 스택 식별자는 `react-vite-feature`, `react-vite-fsd`,
`react-next-app`이며, 고르는 메뉴가 아니라 사다리입니다. Compforge는
`react-vite-feature`(SSR이 필요하면 `react-next-app`)에서 시작하고, 기능 영역이
대략 다섯 개를 넘거나 여러 팀이 붙을 때만 `react-vite-fsd`의 Feature-Sliced
레이어로 한 단계 올립니다. 작은 화면은 FSD로 시작하지 않습니다. Next.js는
복잡도 윗단이 아니라 SSR 축입니다. Vue는 1.x 지원 범위 밖입니다.
[docs/reference/support-scope.md](docs/reference/support-scope.md)를 보세요.

### 세션 사이 작업 이어가기

실행 작업은 가벼운 `.craft/` 기록을 남기고 편집 전에 미완료 작업을 재개합니다.
자세한 규칙은 [`skills/workflow/continuity.md`](skills/workflow/continuity.md)에
있습니다.

## 예제로 배우기

| 자료 | 용도 |
|---|---|
| [Examples index](examples/README.md) | 같은 Todo 앱, 출하된 세 스택 |
| [장바구니 워크스루](docs/guides/cart/README.ko.md) | 한 화면을 Discovery → Test까지 |
| [문서 인덱스](docs/README.md) | 설치, 프로젝트, 레퍼런스, 가이드, 증거 |
| [하니스 검증](docs/verification/README.md) | v1.0.0에서 실제로 스모크한 것 |
| [Support scope](docs/reference/support-scope.md) | 검증된 범위, 하니스 경로, 1.x 호환 계약 |
| [Skill stability](docs/reference/skill-stability.md) | stable / experimental 스킬 구분 |
| [Reviewer checklist](docs/reference/reviewer-checklist.md) | 구현 후 규칙 점검 |
| [Templates](templates/README.md) | `init`이 프로젝트에 복사하는 강제 설정 |

## 왜 Compforge인가

깨끗한 React 코드베이스가 어떻게 생겼는지는 대부분 압니다. 어려운 건 에이전트가
화면을 `useState` 11개와 `useEffect` 체인이 든 600줄 페이지로 붕괴시키는 것을
막는 일입니다.

작고 측정 가능하며 워크플로와 상태 배치를 우선하는 기준은
[제품 원칙](docs/project/positioning.md#product-principles)이 정본입니다.

### Before

```tsx
function CartPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  useEffect(() => { fetch('/cart').then(...) }, []);
  useEffect(() => { setTotal(items.reduce(...)) }, [items]);
}
```

**문제:** 갓 페이지 · 서버 데이터를 클라이언트 상태에 · 파생값을 이펙트로 동기화 ·
테스트하기 어려운 JSX

### After

```tsx
function CartPage() {
  const { items, addItem, removeItem } = useCart();
  const total = sumTotal(items);
  return <CartList items={items} onRemove={removeItem} />;
}
```

**효과:** 상태의 집이 하나 · 렌더 없이 로직 테스트 · 작은 컴포넌트 · 반복 가능한
레이아웃. 실행 가능한 참고는 [examples](examples/README.md)에 있습니다.

### 증거와 한계

[증거 기준](docs/project/positioning.md#evidence-standard)은
[Proof 프로토콜과 발행된 실행](docs/proof/README.md)이 뒷받침할 수 있는 주장을
정합니다. 불리한 실행도 공개하며 보편적인 퍼센트 주장은 하지 않습니다.

## 설치, 업데이트, 제거

빠른 시작 bootstrap은 최신 `main`을 추적합니다. 특정 릴리스를 설치하려면:

```bash
git clone https://github.com/LooSung/compforge ~/.compforge
cd ~/.compforge
git checkout v1.3.6
chmod +x scripts/setup/*.sh
./scripts/setup/install.sh
./scripts/setup/doctor.sh
```

### 설치 대상

정본 경로와 호출 계약은
[`docs/reference/support-scope.md`](docs/reference/support-scope.md#canonical-harness-paths)에
있습니다. 설치 옵션은 [Claude](docs/setup/claude-code.md),
[Codex](docs/setup/codex.md), [Cursor](docs/setup/cursor.md) 가이드가 관리합니다.

### 업데이트

GitHub Release는 기존 clone을 자동 갱신하지 않습니다:

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

이 명령은 `main` 추적 clone용입니다. 릴리스 태그에 고정한 clone은
`git fetch --tags` 후 선택한 새 태그를 checkout하고
`./scripts/setup/install.sh update`를 실행합니다.

Cursor의 `--plugin-dir` 링크와 프로젝트 로컬 스킬은 `install.sh`가 관리하지
않으므로 pull 뒤 에이전트를 다시 시작합니다.

### 검증과 문제 해결

아래 명령은 `~/.compforge`에서 실행합니다:

```bash
./scripts/setup/doctor.sh              # 팩 구조와 설치 링크
./scripts/setup/install.sh --dry-run   # 예정된 링크 변경
./scripts/setup/install.sh --force     # 충돌 symlink 교체
./scripts/ci/harness-smoke.sh static   # 패키징된 하네스 계약
./scripts/ci/smoke-test.sh             # 격리 HOME 설치 lifecycle
```

개발 checkout에서 doctor는 그 checkout의 구조를 검사하지만 설치 링크는
`$COMPFORGE_HOME` 또는 `~/.compforge`를 기준으로 봅니다. 다른 정상 팩은
경고하고 팩이 아닌 대상은 실패합니다. 실제 Craft 활성화는 하네스 진입점으로
확인합니다: [Claude Code](docs/setup/claude-code.md) ·
[Codex](docs/setup/codex.md) · [Cursor](docs/setup/cursor.md).

### 제거

```bash
./scripts/setup/uninstall.sh
```

이 명령은 이 팩을 가리키는 Claude·Codex 관리 링크만 제거합니다. Cursor와
프로젝트 로컬 제거 절차는
[`docs/setup/cursor.md`](docs/setup/cursor.md#4-update-or-remove)에 있습니다.

## 포함된 구성

- `skills/` — 워크플로, React, 스택, 스켈레톤, 플레이북, 리뷰 지침
- `commands/` — Claude Code 커맨드 진입점 (`craft`, `refactor`, `consult`)
- `examples/` — 실행 가능한 TypeScript + React Todo 예제 3종
- `docs/` — 하네스 가이드, Proof, 1.x 방향, 지원 범위, 검증 기록
- `scripts/` — 설치, init, lint, proof, smoke test
- `templates/` — ESLint 존, steiger, 차단 CI, 비차단 아키텍처 리뷰

## 프로젝트 정책

[`AGENTS.md`](./AGENTS.md)는 공통 헌법과 라우팅 정본이며, 검출기가 읽는
Hard Rules는
[`skills/principles/hard-rules.md`](./skills/principles/hard-rules.md)에
있고 [`CLAUDE.md`](./CLAUDE.md)는 Claude Code 어댑터입니다.
skill, script, CI, agent instruction은 영어를 정본으로 사용합니다. 한국어
독자는 skill별 복제본 대신
[`docs/reference/methodology.ko.md`](./docs/reference/methodology.ko.md)를 사용합니다.
1.x 유지보수와 비-목표는 [1.x 방향](./docs/project/direction.md), 1.x 호환 계약은
[지원 범위](./docs/reference/support-scope.md), 완료된 릴리스는
[변경 이력](./CHANGELOG.md)에서 확인합니다.

## 라이선스

MIT
