# Compforge

![CI](https://github.com/LooSung/compforge/actions/workflows/lint.yml/badge.svg)
![Examples](https://github.com/LooSung/compforge/actions/workflows/examples.yml/badge.svg)
![License](https://img.shields.io/github/license/LooSung/compforge)

> **AI가 UI를 만든다. Compforge가 컴포넌트 아키텍처를 지킨다.**
>
> *바이브 코딩이 프론트엔드를 망가뜨리지 않게 하는 하니스 엔지니어링.*

**작게 벼리고, 영원히 조합한다.** Compforge는 절제된 React/TypeScript를 에이전트가 따르는 방언(dialect)으로 정의합니다 — 스킬은 문법, 하드 룰은 린트, 레퍼런스 `examples/`는 증명(예정), install + commands는 런타임입니다. UI 라이브러리도, 범용 에이전트 프레임워크도 아닌 **방법론 팩 + 에이전트 하니스**입니다.

Claude Code, Codex CLI, Cursor 등 호환 에이전트가 코드를 쓰기 전에 **컴포넌트 경계**, **상태 배치**(서버 / 클라이언트 / URL), **커스텀 훅**, **기능 단위 구조**를 먼저 설계하도록 만듭니다.

**TypeScript + React** (Vite 또는 Next.js) 특화 — **기능 폴더** 또는 **Feature-Sliced Design** 중 선택. **Vue** 지원은 React 검증 완료를 게이트로 하는 로드맵 항목입니다.

자매 프로젝트: [OOPforge](https://github.com/LooSung/oopforge) — 같은 하니스 모델의 백엔드 OOP/DDD 버전 (Java Spring / Python FastAPI).

[English](./README.md) · [한국어](./README.ko.md)

> **상태: v0.3 — 1장 완결.** 설치, 스킬, Craft 진입점, 실행 가능한 레퍼런스 예제 2종(테스트 + 스택별 아키텍처 린트), 그리고 푸시마다 이 모든 것을 검증하는 리포 CI가 동작합니다. 대상 프로젝트용 CI 템플릿, 안티패턴 탐지기, proof 프로토콜은 2장 이후입니다. [docs/roadmap.md](docs/roadmap.md) 참고. 이 문서는 존재하는 것만 주장합니다.

---

## **빠른 시작**

### **1. 설치**

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LooSung/compforge/main/scripts/setup/bootstrap.sh)"
```

설치 확인:

```bash
~/.compforge/scripts/setup/doctor.sh
```

### **2. 대상 프로젝트를 연다 (팩이 아니라)**

Compforge는 `~/.compforge`에 삽니다. 앱 코드는 **여러분의 프론트엔드 리포**에 있습니다. 항상 그 프로젝트에서 에이전트를 시작하세요:

```bash
cd /path/to/your-frontend-project
```

### **3. 에이전트 재시작 / 로드**

Claude Code나 Codex CLI를 재시작해 새 스킬과 커맨드를 인식시키세요.

**Cursor** 연동은 실험적입니다. 각 대상 프로젝트에 스킬을 링크하세요:

```bash
mkdir -p .cursor/skills
ln -s ~/.compforge/skills .cursor/skills/compforge
printf '%s\n' '.cursor/skills/compforge' >> .git/info/exclude
```

### **4. Craft 실행**

모든 하니스의 진입점은 **Craft**이고, **호출 방법**만 다릅니다:

| 하니스 | 호출 |
|---|---|
| **Claude Code** | `/compforge:craft <요청>` — 등록된 슬래시 커맨드 |
| **Codex CLI** | `/skills` → **compforge** 선택 후, `/` 없이 프롬프트 |
| **Cursor Agent CLI** | 프로젝트 로컬 스킬 설정 후 `Use Compforge craft: …` |

**Claude Code:**

```text
/compforge:craft 장바구니 아이템에 수량 조절 스테퍼 추가해줘
```

### **5. 업데이트 (수동 — Release가 자동 설치되지 않음)**

```bash
cd ~/.compforge && git pull && ./scripts/setup/install.sh update
```

이후 에이전트를 재시작하세요.

---

## **기본 워크플로우**

Compforge는 작은 배달 루프를 사용합니다. *계획, 구현, 검증을 한 번에 합치지 마세요.*

```text
Discovery → Design → Skeleton → Implement → Test
```

| 단계 | 산출물 | 금지 |
|---|---|---|
| **1. Discovery** | 사용자 플로우, 화면 목록, 용어집, 미해결 질문 | 코드 |
| **2. Design** | 컴포넌트 트리, 상태 배치 테이블, API 계약 | 구현 |
| **3. Skeleton** | 기능 폴더, 타입 잡힌 빈 컴포넌트/훅 | 비즈니스 로직 |
| **4. Implement** | 한 번에 하나의 기능, 훅 먼저 | 여러 기능 동시 구현 |
| **5. Test** | 유닛(훅), 컴포넌트, E2E 검사 | 테스트 없는 로직 훅 |

각 단계는 **사람의 체크포인트**로 끝납니다 — 건너뛰지 마세요.

**작고 집중된 작업**(컴포넌트 하나, 기존 기능 확장, 리팩토링)은 `/compforge:craft`로 시작하세요. 전체 파이프라인을 강제하지 않고 최소 경로를 고릅니다.

**Refactor는 의도적으로 기본 기능 플로우 밖에 있습니다.** 동작 변경 없는 정리에만 사용하세요.

### **메모리 저장소 (세션 간 이어하기)**

실행 작업 항목마다 `.craft/<kind>-<slug>.md` 문서 하나가 결정, 진행 상황, 다음 단계를 추적합니다. 돌아오면 Craft가 해당 문서를 **먼저** 읽고 이어서 진행합니다. `.craft/`는 기본 gitignore입니다. [`skills/workflow/continuity.md`](skills/workflow/continuity.md) 참고.

---

## **왜 Compforge인가**

깨끗한 React 코드베이스가 *어떻게 생겼는지*는 대부분 압니다. 어려운 건 에이전트(또는 팀)가 모든 것을 `useState` 11개와 `useEffect` 체인이 든 600줄짜리 페이지 컴포넌트로 붕괴시키는 것을 막는 일입니다. Compforge는 **구조를 기본값**으로 만듭니다.

| 원칙 | 의미 |
|---|---|
| **작게** | 스킬 하나에 개념 하나; 스킬당 200줄 |
| **측정 가능하게** | 컴포넌트 파일 200줄, 파일당 export 1개 — 리뷰 가능한 단위 |
| **워크플로우 우선** | 사람 체크포인트가 있는 Discovery → Test |
| **상태 우선** | 모든 상태에는 이름 붙은 단 하나의 집이 있다 |
| **철학보다 증명** | 광범위한 주장 전에 실행 가능한 예제 (계획) |

### Before (전형적인 에이전트 산출물)

```tsx
function CartPage() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);      // 파생 상태를 저장
  useEffect(() => { fetch('/cart').then(...) }, []);   // fetch 체인
  useEffect(() => { setTotal(items.reduce(...)) }, [items]);  // 동기화 이펙트
  // ...핸들러와 JSX 300줄
}
```

### After (Compforge)

```tsx
function CartPage() {
  const { items, addItem, removeItem } = useCart();  // 로직은 훅에, 데이터는 쿼리 레이어에
  const total = sumTotal(items);                     // 렌더 시 파생
  return <CartList items={items} onRemove={removeItem} />;  // 컴포넌트는 렌더만
}
```

**효과:** 상태의 집이 하나 · 렌더링 없이 로직 테스트 · 컴포넌트가 작게 유지 · 에이전트가 반복 가능한 레이아웃을 따름

---

## **스택**

| 스택 | 아키텍처 | 언제 |
|---|---|---|
| `react-vite-feature` | 기능 폴더 | 중소형 앱, MVP |
| `react-vite-fsd` | Feature-Sliced Design 레이어 | 복잡한 앱, 큰 팀 |
| `react-next-app` | Next.js App Router + 기능 폴더 | SSR/SEO, 서버 컴포넌트 |

실행 가능한 증명: [examples/README.md](examples/README.md) — 같은 Todo 앱을 두 스택으로 각각 구현, 테스트와 스택별 아키텍처 린트 포함.

Vue (Nuxt)는 계획 항목입니다 — React 수직이 먼저 증명·강제되는 것이 게이트입니다. [docs/roadmap.md](docs/roadmap.md) 참고.

---

## **하드 룰**

강제 가능하고 측정 가능한 규칙은 [`AGENTS.md`](./AGENTS.md)에 있습니다 (v0.1 초안, 1.0 전에 레퍼런스 예제로 검증 예정). 요약: 컴포넌트 파일 200줄, 파일당 export 1개, TS strict + `any` 금지, 직접 변이 금지, 서버 상태는 쿼리 레이어에, useEffect는 최후 수단, 2단계 초과 prop drilling 금지, 기능 간 import는 public API로만.

---

## **철학**

> **모델은 교체된다. 워크플로우는 영원하다.**

Compforge는 모델 레이어가 아닙니다. 프론트엔드를 위한 **개발 프로토콜 레이어**입니다.

1. **작게** — 스킬 하나, 개념 하나.
2. **제자리에** — 모든 상태에는 이름 붙은 집이 하나 있다.
3. **조합 가능하게** — 컴포넌트는 조합되고, 기능은 public API 뒤에 머문다.
4. **지속 가능하게** — 메가 프롬프트 없이, 사람 체크포인트를 유지한다.

---

## **영감**

- Dan Abramov의 이펙트와 컴포넌트 사고에 관한 글
- [Feature-Sliced Design](https://feature-sliced.design)
- [bulletproof-react](https://github.com/alan2207/bulletproof-react)
- React 공식 문서, *You Might Not Need an Effect*
- [OOPforge](https://github.com/LooSung/oopforge) — 이 팩이 미러링하는 자매 방법론

---

## **라이선스**

MIT
