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

[포지셔닝](docs/positioning.md) · [지원 범위](docs/support-scope.md) ·
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

`doctor.sh`는 팩 구조와 사용 가능한 symlink를 검사합니다. 성공 결과가 실행
중인 에이전트의 Craft 로드를 증명하지는 않으므로 4단계에서 하네스별 진입점을
확인하세요. 선택한 Claude·Codex 링크가 없다는 경고가 나오면
`INSTALL_CLAUDE=1 ~/.compforge/scripts/setup/install.sh` 또는 Codex 대응
변수로 다시 설치합니다.

### 3. 프론트엔드 프로젝트로 이동

Compforge 팩은 `~/.compforge`에 있고 앱 코드는 **프론트엔드 저장소**에 있습니다.
에이전트는 항상 대상 프로젝트에서 시작합니다:

```bash
cd /path/to/your-frontend-project
```

### 4. Craft를 로드하고 한 번 요청

| 하네스 | Craft 로드와 호출 |
|---|---|
| **Claude Code** | Claude Code 재시작 후 `/compforge:craft <요청>` |
| **Codex CLI** | Codex 재시작 후 `/skills`에서 **compforge**를 고르고 `/` 없이 요청 |
| **Cursor Agent CLI** | `--plugin-dir ~/.cursor/plugins/local/compforge` 후 `Use Compforge craft: …` |

Claude Code:

```text
/compforge:craft 장바구니 아이템에 수량 조절 스테퍼 추가해줘
```

Codex CLI:

```text
Use Compforge craft: 장바구니 아이템에 수량 조절 스테퍼 추가해줘
```

Cursor Agent CLI는 `install.sh`가 설정하지 않습니다. 로컬 플러그인으로 등록하고
명시적으로 넘기세요:

```bash
mkdir -p ~/.cursor/plugins/local
ln -s ~/.compforge ~/.cursor/plugins/local/compforge
cursor-agent --plugin-dir ~/.cursor/plugins/local/compforge
```

```text
Use Compforge craft: 장바구니 아이템에 수량 조절 스테퍼 추가해줘
```

새 실행 작업에서 Craft가 로드되면 가장 작은 경로를 고르고 UI 로직 전에
Assumptions와 Component Contract를 제시합니다. 자문 요청은 구현하지 않고
경로만 추천합니다. 설정 상세:
[Claude Code](docs/claude-code.md) · [Codex](docs/codex.md) ·
[Cursor](docs/cursor.md).

### 5. 선택: 프로젝트에 팩을 남기기

`compforge init`은 `AGENTS.md` 포인터와 `compforge-lock.json`을 남겨서, 여러분의
레포만 클론한 에이전트도 Compforge를 읽어야 한다는 걸 알게 합니다. 함께 스택별
ESLint import 존(기능 폴더 / Next App Router) 또는 steiger(FSD)와 PR을 막는
GitHub Actions 체크를 복사합니다. Craft를 시험하는 데는 필수가 아닙니다.

```bash
~/.compforge/scripts/setup/init.sh
```

`package.json`과 `src/`에서 스택을 감지하고, 자기가 만들지 않은 파일은 덮어쓰지
않으며(손으로 쓴 `AGENTS.md`는 Compforge 마커 바깥이 그대로 보존됩니다),
**negative self-test**로 끝냅니다. 일부러 깨뜨린 import가 실패하지 않으면 init은
성공을 보고하지 않습니다. 나중에 가드가 살아 있는지 다시 증명하려면:

```bash
~/.compforge/scripts/setup/init.sh --verify
```

포인터는 팩 위치와 고정된 버전만 적습니다. 하드 룰을 복사하지 않는 이유는 다음
릴리스에서 곧바로 낡기 때문입니다. 상세: [`templates/`](./templates/README.md).

## 기본 워크플로

Craft가 단일 진입점입니다. 작은 작업은 집중 경로를 고르고, 새 기능 영역이나
큰 화면은 전체 순서를 유지합니다:

```text
Discovery → Design → Delivery Plan → Skeleton → Implement → Test
```

| 단계 | 산출물 | 금지 |
|---|---|---|
| **Discovery** | 사용자 플로우, 화면, 용어집, 질문 | 코드 |
| **Design** | 컴포넌트 트리, 상태 홈, API 계약 | 구현 |
| **Delivery Plan** | 범위, 순서, 테스트, 릴리스 위험 | 코딩 |
| **Skeleton** | 기능 폴더, 타입 잡힌 빈 컴포넌트/훅 | 비즈니스 로직 |
| **Implement** | 테스트된 기능 하나씩, 훅 먼저 | 여러 기능 동시 작업 |
| **Test** | 훅·컴포넌트·E2E 근거 | 테스트 없는 로직 훅 |

각 단계 끝에는 사람 확인이 있습니다. 앞선 결정이 이미 있을 때만 Craft에 특정
단계부터 시작하라고 요청하세요. 리팩토링은 동작을 보존해야 하므로 기능
워크플로 밖에서 진행합니다.

출하된 스택 식별자는 `react-vite-feature`, `react-vite-fsd`,
`react-next-app`입니다. Vue는 React 수직이 게이트입니다.
[docs/roadmap.md](docs/roadmap.md)를 보세요.

### 세션 사이 작업 이어가기

실행 작업은 `.craft/` 아래에 가벼운 기록을 남깁니다. 미완료 작업이 있으면
Craft가 편집 전에 Resume 블록을 제시합니다. 세션이 끝났는데 일이 남으면
`.craft/next-session-prompt.md`가 다음 결정을 기록합니다.

## 예제로 배우기

| 자료 | 용도 |
|---|---|
| [Examples index](examples/README.md) | 같은 Todo 앱, 출하된 세 스택 |
| [장바구니 워크스루](docs/guides/cart/README.ko.md) | 한 화면을 Discovery → Test까지 |
| [문서 인덱스](docs/README.md) | 설치, 레퍼런스, 검증 기록 |
| [하니스 검증](docs/verification/README.md) | v1.0.0에서 실제로 스모크한 것 |
| [Support scope](docs/support-scope.md) | 검증된 범위, 하니스 경로, 1.x 호환 계약 |
| [Skill stability](docs/skill-stability.md) | stable / experimental 스킬 구분 |
| [Reviewer checklist](docs/reviewer-checklist.md) | 구현 후 규칙 점검 |
| [Templates](templates/README.md) | `init`이 프로젝트에 복사하는 강제 설정 |

## 왜 Compforge인가

깨끗한 React 코드베이스가 어떻게 생겼는지는 대부분 압니다. 어려운 건 에이전트가
화면을 `useState` 11개와 `useEffect` 체인이 든 600줄 페이지로 붕괴시키는 것을
막는 일입니다.

| 원칙 | 의미 |
|---|---|
| **작게** | 한 스킬 = 한 개념, 스킬 200줄 이하 |
| **측정 가능하게** | 컴포넌트 파일 200줄, 파일당 export 1개 |
| **워크플로 우선** | Discovery → Test, 사람 확인 유지 |
| **상태 우선** | 모든 상태에는 이름 붙은 집이 하나 |
| **철학보다 증명** | 효과 주장은 [발행된 실행](docs/proof/)을 근거로 |

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

[Proof 프로토콜](docs/proof/README.md)은 과제, 대조군, 평가 규칙과 공개 기준을
고정합니다. [발행된 실행](docs/proof/)이 지금 뒷받침하는 주장은 이것뿐입니다.
*Compforge는 에이전트가 코드베이스의 나쁜 패턴을 복사하는 것을 막고, 이미 좋은
패턴이 있는 코드베이스에는 더할 것이 없으며, 약한 모델에서는 위반을 줄이되
핵심 위반까지 막지는 못한다.* 불리한 실행도 공개합니다. 퍼센트 주장이 아닙니다.

## 설치, 업데이트, 제거

빠른 시작 bootstrap은 최신 `main`을 추적합니다. 특정 릴리스를 설치하려면:

```bash
git clone https://github.com/LooSung/compforge ~/.compforge
cd ~/.compforge
git checkout v1.0.1
chmod +x scripts/setup/*.sh
./scripts/setup/install.sh
./scripts/setup/doctor.sh
```

### 설치 대상

| 하네스 | 설치 또는 등록 경로 |
|---|---|
| **Claude Code** | `~/.claude/skills/compforge`, `~/.claude/commands/compforge` |
| **Codex CLI** | `~/.codex/skills/compforge` |
| **Cursor Agent CLI** | `--plugin-dir`로 `~/.cursor/plugins/local/compforge` |

`install.sh`는 Claude·Codex 설정 디렉터리가 있을 때만 링크를 만듭니다.
대상이 없으면 `INSTALL_CLAUDE=1` 또는 `INSTALL_CODEX=1`로 명시합니다.
Cursor는 `install.sh`가 설정하지 않습니다.

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
./scripts/ci/smoke-test.sh             # 격리된 Claude/Codex 설치 수명주기
./scripts/ci/harness-smoke.sh static   # 매니페스트, 스킬 안정성, 프로브 토큰
```

이 검사는 실제 Craft 응답을 실행하지 않습니다. 활성화는 사용하는 하네스의
진입점으로 확인합니다: [Claude Code](docs/claude-code.md) ·
[Codex](docs/codex.md) · [Cursor](docs/cursor.md).

### 제거

```bash
./scripts/setup/uninstall.sh
```

이 명령은 이 팩을 가리키는 Compforge 관리 Claude·Codex 링크만 제거합니다.
`~/.compforge`, Cursor의 `~/.cursor/plugins/local/compforge`, 프로젝트의
`.cursor/skills/compforge`는 유지합니다. 완전히 제거하려면 직접 삭제하세요.

## 포함된 구성

- `skills/` — 워크플로, React, 스택, 스켈레톤, 플레이북, 리뷰 지침
- `commands/` — Claude Code 커맨드 진입점
- `examples/` — 실행 가능한 TypeScript + React Todo 예제 3종
- `docs/` — 하네스 가이드, Proof, 로드맵, 지원 범위, 검증 기록
- `scripts/` — 설치, init, lint, proof, smoke test
- `templates/` — ESLint 존, steiger, 차단 CI, 비차단 아키텍처 리뷰

에이전트 규칙의 정본은 [`AGENTS.md`](./AGENTS.md)이며
[`CLAUDE.md`](./CLAUDE.md)는 Claude Code 어댑터입니다.

## 프로젝트 정책

skill, script, CI, agent instruction은 영어를 정본으로 사용합니다. 한국어
독자는 skill별 복제본 대신
[`docs/methodology.ko.md`](./docs/methodology.ko.md)를 사용합니다.
1.x 유지보수와 비-목표는 [로드맵](./docs/roadmap.md), `v1.0.0`이 약속하는
범위는 [지원 범위](./docs/support-scope.md), 완료된 릴리스는
[변경 이력](./CHANGELOG.md)에서 확인합니다.

## 라이선스

MIT
