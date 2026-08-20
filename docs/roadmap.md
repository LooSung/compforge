# Compforge — Roadmap

**미래 지향** 문서다. 완료된 변경의 상세 이력은 [`CHANGELOG.md`](../CHANGELOG.md)에 있다. 여기에는 **"이건 반드시 한다"**만 남긴다 — 하고 싶은 것이 아니라 정체성을 지키며 성장하는 데 꼭 필요한 것.

---

## 0. 비전 (정체성 — 흔들지 않음)

> **Compforge는 TypeScript + React 프론트엔드에 특화된 Spec-Driven 방법론 + 아키텍처 강제(fitness function) 팩이다.**

- 우리는 **수직(vertical) 방법론**이다. 범용 코딩 에이전트·코드 인덱서·컨텍스트 압축기 같은 **수평(horizontal) 인프라**가 아니다.
- 대상은 **TypeScript + React**(Vite / Next.js)와 **컴포넌트 경계·상태 배치를 지키려는 팀**. 그 좁은 영역에서 **가장 깊다**.
- Spec-Driven Development(SDD) 생태계 안에서, Compforge는 "컴포넌트 경계 / 서버·클라이언트·URL 상태 홈 / 기능 폴더 또는 FSD"에 특화된 변종이다.
- **효과 지표는 토큰 절감이 아니라 아키텍처 위반율과 재작업률이다.** 명시적 제약(constitution + skills + fitness function)이 이 지표를 실제로 낮추는지 재현 가능한 대조 실험으로 검증한다. 일반 효과율로 확대하지 않는다.

자매 팩: 백엔드는 [OOPforge](https://github.com/LooSung/oopforge). 인접 연구: [`research/competitor-skills.md`](research/competitor-skills.md).

---

## 핵심 원칙 (유지 — 손대지 않는다)

- 작은 스킬 (200줄/스킬, 한 스킬 한 개념)
- 측정 가능한 하드 룰 (200줄/컴포넌트 파일, 파일당 export 1개)
- 단계별 휴먼 체크포인트 (Discovery → Design → Delivery Plan → Skeleton → Implement → Test)
- 상태 우선 — 모든 값에 집이 하나. 사다리는 [`component-discipline.md`](../skills/principles/component-discipline.md)
- 로딩·에러·빈 상태, 접근성, 포커스/키보드, 입력 검증은 줄 수를 아끼려고 빼지 않는다
- 토큰/비용을 핵심 지표로 삼지 않는다
- **범용 에이전트와 경쟁하지 않는다** — 그 위에 얹히는 방법론이다

---

## 다음 릴리스

### v0.7.0 — fitness function 정합

**목표:** reference 예제, 평가기, `compforge init` CI gate가 같은 Compforge 규칙을 보고
“아키텍처를 지킨다”는 약속을 실행 가능한 강제로 닫는다.

- **Evaluator 수리** — `scripts/proof/evaluate-run.py`의 두 실패 모드를 고친다.
  일괄 완료 false negative, net-versus-added `useEffect` 카운트(N개 제거 + N개 추가를 0으로 보는 것).
- **Detector** — derived-state-in-effect, query-data-in-`useState`, 파일당 export 초과,
  200줄 초과, `any`. Hard Rules를 detector가 읽을 수 있게 MUST / SHOULD / NEVER로 **한 번만** 옮긴다.
- **PR 아키텍처 리뷰** — new-only 파인딩 + 교정 프롬프트. 이 레포에서 dogfood한 뒤
  대상 프로젝트 템플릿으로 배달한다. C2 도메인 리뷰의 프론트 대응이다.
- **차단 정책** — 저장소 CI와 `compforge init` 템플릿에서 무엇을 필수 차단하고
  무엇을 non-blocking 피드백으로 남길지 명시하고 검증한다.
- **증거 갱신** — 고친 평가기로 고정 비교를 다시 실행하고, 일반 효과로 확대하지 않은
  결과와 재현 artifact를 공개한다.

**범위 밖:** 워크스루 튜토리얼, `react-next-app` 예제, Cursor `--plugin-dir` 효과 주장,
Vue, marketplace 공개, Chaebi식 오케스트레이션.

---

## 장기 목표

### 프론트 깊이

- **워크스루** — Discovery → Test를 현실 화면 하나(장바구니 또는 설정)로 끝까지.
  todo 복제가 아니고, PRD 오케스트레이션 체인도 아니다.
- **`react-next-app`** — 실행 예제 + server/client import 레시피. 예제 없이 스킬이 Next를 주장하지 않는다.
- **접근성 게이트** — 사다리에서 빼면 안 되는 항목(이름·역할·포커스)을 detector가 잡을 수 있는 범위만.

### 강제와 배포

- **init 드리프트** — `compforge-lock.json` 또는 동등한 수단으로, 배달한 ESLint 존/steiger가
  죽은 가드가 되지 않았는지 재실행 가능하게.
- **MCP 서버 모드** — detector·아키텍처 리뷰를 실시간 자가교정 도구로 노출하는 **opt-in 실험**.
- **패키징** — symlink 팩 → 플러그인 마켓플레이스 → Claude Agent SDK 위 독립 CLI.
  Cursor `--plugin-dir`은 스모크가 증명한 뒤에만 문서가 주장한다.

### 언어 확장

0.7 강제, 0.8 교육(워크스루 + Next 예제), 0.9 검증된 패키징을 먼저 갖춘다.
그 시점이 React 수직이 닫힌 **v1.0**이다. 그 뒤 각 스택에 feature + FSD + runnable 예제와
강제를 함께 제공한다.

Vue 3 + Nuxt (`vue-nuxt-feature`, `vue-nuxt-fsd`) — Composition API는 훅 규율에 가깝다.
Vue 스킬은 그 삼체(예제·init·proof 짝) 없이 쓰지 않는다.

---

## 비-목표 (가드레일)

- **수평 인프라화** — 범용 에이전트·코드 인덱서·컨텍스트 압축기와 경쟁하지 않음
- **멀티에이전트 오케스트레이션** — Chaebi·서브에이전트 팀·세션 관리·에이전트 간 통신은 우리 몫이 아니다. 우리는 **각 에이전트가 따르는 설계 규율**이지 오케스트레이터가 아니다
- **앱이 되기** — 제품 `src/`, 사내 UI 키트, Figma/px 데모 플로우, 회사 레지스트리. 그건 보일러플레이트다
- **토큰/비용 벤치마크 경쟁** — 지표는 위반율·재작업률
- **메가 스킬/메가 프롬프트** — 한 파일에 여러 개념 X
- **GUI/IDE 플러그인** — CLI/에이전트 통합으로 충분
- **자동 코드 생성기** — 패턴은 가르치고, 코드는 에이전트가 작성
- **백엔드·모바일·ML 진출** — 컴포넌트 아키텍처 + React 수직에 집중. 백엔드는 OOPforge
- **불안정한 통합을 default install에 포함** — 실험(MCP 등)은 별도 opt-in
- **검증되지 않은 하니스 주장** — Cursor 자동 탐색, Cursor의 `/compforge:craft` 슬래시는 스모크 전까지 문서에 성공으로 쓰지 않는다
