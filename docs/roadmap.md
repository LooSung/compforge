# Compforge — Roadmap

**미래 지향** 문서다. 완료된 변경의 상세 이력은 [`CHANGELOG.md`](../CHANGELOG.md)에 있다. 여기에는 **"이건 반드시 한다"**만 남긴다. 세션은 한 결정, 릴리스는 닫히는 테마다.

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

## 출하됨

상세는 [`CHANGELOG.md`](../CHANGELOG.md). 로드맵에 다시 열지 않는다.

| 버전 | 닫은 결정 |
|---|---|
| [v0.5.0](https://github.com/LooSung/compforge/releases/tag/v0.5.0) | proof 반복 + `compforge init`(린트 강제 배달) |
| [v0.6.0](https://github.com/LooSung/compforge/releases/tag/v0.6.0) | 하니스 철학(Resume, Delivery Plan, 온보딩) |
| [v0.7.0](https://github.com/LooSung/compforge/releases/tag/v0.7.0) | fitness functions(evaluator, detector, 비차단 리뷰) |
| [v0.8.0](https://github.com/LooSung/compforge/releases/tag/v0.8.0) | 교육(장바구니 워크스루 + `react-next-app` 예제) |
| [v0.9.0](https://github.com/LooSung/compforge/releases/tag/v0.9.0) | 배달(`AGENTS.md` 포인터 + lock + `--verify`, `react-next-app` `init`, Next 오탐 수정) |
| [v1.0.0](https://github.com/LooSung/compforge/releases/tag/v1.0.0) | 고정 가능(하니스 스모크 실측, 접근성 detector, 지원 범위·안정성·보안 정책) |

---

## 1.0 조건 — 전부 닫힘

**v1.0.0을 찍는 때:** 낯선 팀이 TypeScript + React 팩을 `v1.0.0`에 고정해도 된다고 말할 수 있을 때.

모두 참이어야 했고, 모두 참이다.

1. ~~**대상 레포에 constitution이 남고, 세 스택 전부에 `init`이 배달됨**~~ — v0.9.0에서 닫힘. 조건은 결과지 태그 번호가 아니다.
2. ~~**문서가 가리키는 하니스 경로가 전부 스모크됨**~~ — Cursor `--plugin-dir`과 프로젝트 로컬 스킬을 2026-08-24에 실측. 디렉터리 자동 탐색은 주장하지 않음.
3. ~~**접근성 게이트의 최소 detector**~~ — 이름·라벨·키보드 경로 세 규칙을 detector가 잡는다. 나머지 접근성은 사람이 본다고 [`support-scope.md`](support-scope.md)에 적었다.
4. ~~**공개된 proof 주장을 철회할 이유가 없음**~~ — 철회할 결과가 없다. 새 페어는 1.0의 전제가 아니었다.

**하니스 실측 (2026-08-24, Cursor Agent `2026.08.11-e8db854`):**

- `--plugin-dir` + `Use Compforge craft:` → `COMPFORGE_LOADED`
- 프로젝트 로컬 스킬 + `--add-dir` → `COMPFORGE_LOADED`
- 스킬 없는 빈 워크스페이스 → `COMPFORGE_NOT_LOADED`
- `/compforge:craft` + `--plugin-dir` → Craft 진입. 문서화된 Cursor 호출은
  `Use Compforge craft: …`

재현: `./scripts/ci/harness-smoke.sh live cursor`. 정적 포장은 CI.

**접근성 detector가 잡는 범위:** `CONTROL_WITHOUT_ACCESSIBLE_NAME`,
`FORM_CONTROL_WITHOUT_LABEL`, `INTERACTIVE_HANDLER_WITHOUT_KEYBOARD`.
JSX 텍스트 스캔이므로 이 세 규칙의 증거일 뿐 접근성 감사가 아니다. 애매한
마크업은 일부러 침묵한다. 예제 3스택이 이 규칙을 통과하는 상태는
`scripts/ci/test-review.py`가 잡아 둔다.

---

## 1.0 이후

1.x는 [`support-scope.md`](support-scope.md)의 핵심 사용 계약을 깨지 않는다.
계약을 깨야 하면 2.0이다.

| 다음 | 한 일 |
|---|---|
| 접근성 범위 확대 | 포커스 이동·live region 등 지금 침묵하는 영역. detector가 오탐 없이 잡을 수 있다고 증명된 것만 |
| MCP 서버 모드 | detector·리뷰를 실시간 자가교정으로 노출하는 **opt-in**. default install 금지 |
| 마켓플레이스 / 독립 CLI | symlink 팩 다음. 스모크 없는 경로는 문서가 주장하지 않는다 |
| Vue | `vue-nuxt-feature`, `vue-nuxt-fsd`. 삼체(예제·init·proof) 없이 스킬을 쓰지 않는다 |

Vue·MCP·마켓플레이스는 1.0을 막지 않았고, 1.1도 막지 않는다.

---

## 비-목표 (가드레일)

- **수평 인프라화** — 범용 코딩 에이전트·코드 인덱서·컨텍스트 압축기와 경쟁하지 않음
- **멀티에이전트 오케스트레이션** — Chaebi·서브에이전트 팀·세션 관리·에이전트 간 통신은 우리 몫이 아니다. 우리는 **각 에이전트가 따르는 설계 규율**이지 오케스트레이터가 아니다
- **앱이 되기** — 제품 `src/`, 사내 UI 키트, Figma/px 데모 플로우, 회사 레지스트리. 그건 보일러플레이트다
- **토큰/비용 벤치마크 경쟁** — 지표는 위반율·재작업률
- **메가 스킬/메가 프롬프트** — 한 파일에 여러 개념 X
- **GUI/IDE 플러그인** — CLI/에이전트 통합으로 충분
- **자동 코드 생성기** — 패턴은 가르치고, 코드는 에이전트가 작성
- **백엔드·모바일·ML 진출** — 컴포넌트 아키텍처 + React 수직에 집중. 백엔드는 OOPforge
- **불안정한 통합을 default install에 포함** — 실험(MCP 등)은 별도 opt-in
- **검증되지 않은 하니스 주장** — Cursor 디렉터리 자동 탐색은 스모크하지 않았으므로 문서가 주장하지 않는다
