# Compforge — Roadmap

**미래 지향** 문서다. 완료된 변경의 상세 이력은 [`CHANGELOG.md`](../CHANGELOG.md)에 있다. 여기에는 **"이건 반드시 한다"**만 남긴다. 세션은 한 결정, 릴리스는 닫히는 테마다.

핵심 사용 계약은 [`support-scope.md`](support-scope.md)다. 그 계약을 깨면 2.0이다.

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
| [v0.9.0](https://github.com/LooSung/compforge/releases/tag/v0.9.0) | 배달(`AGENTS.md` 포인터 + lock + `--verify`, Next `init`) |
| [v1.0.0](https://github.com/LooSung/compforge/releases/tag/v1.0.0) | 고정 가능(하니스 스모크, 접근성 detector, 지원 범위·안정성·보안) |

1.0 조건 네 개는 결과로 닫혔다. 하니스 실측 기록은 [`verification/harness-v1.0.0.md`](verification/harness-v1.0.0.md).

---

## v1.x 유지보수

**목표:** v1.0.0에서 고정한 TypeScript + React 핵심 방법론과
Claude / Codex / Cursor 실행 경로를 1.x 호환성 계약 안에서 유지한다.

- **Harness drift** — vendor CLI가 바뀌면 문서가 주장하는 경로의
  positive/negative 증거를 함께 갱신한다. Cursor는
  `./scripts/ci/harness-smoke.sh live cursor`. Claude·Codex 라이브는
  `live claude` / `live codex`.
- **Compatible evolution** — stable 스킬, 검사, 예시를 코어 계약을 깨지 않는
  minor/patch 범위에서 개선한다.
- **Documentation ownership** — setup·reference·verification 링크가 살아 있게
  유지한다.

**범위 밖:** Vue, MCP 서버, 마켓플레이스, 독립 CLI.

---

## 장기 목표 (지금 열지 않음)

| 다음 | 한 일 |
|---|---|
| 접근성 범위 확대 | 포커스 이동·live region. detector가 오탐 없이 잡을 수 있다고 증명된 것만 |
| MCP 서버 모드 | detector·리뷰를 실시간 자가교정으로 노출하는 **opt-in**. default install 금지 |
| 마켓플레이스 / 독립 CLI | symlink 팩 다음. 스모크 없는 경로는 문서가 주장하지 않는다 |
| Vue | `vue-nuxt-feature`, `vue-nuxt-fsd`. 삼체(예제·init·proof) 없이 스킬을 쓰지 않는다 |

이 표가 1.x를 막지 않는다. 계약을 깨는 변경만 2.0이다.

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
