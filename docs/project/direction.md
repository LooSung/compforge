# Compforge — 1.x Direction

현재 1.x의 정체성, 유지보수 범위, 비-목표를 기록한다. 완료된 변경의
상세 이력은 [`CHANGELOG.md`](../../CHANGELOG.md)에 있고, 미래 계획과 릴리스
초안은 공개 문서에 두지 않는다.

핵심 사용 계약은
[`support-scope.md`](../reference/support-scope.md)다. 그 계약을 깨면 2.0이다.

---

## 현재 기준선

- 제품 정의와 효과 주장 기준: [`positioning.md`](positioning.md)
- 지원 스택과 1.x 호환 계약:
  [`support-scope.md`](../reference/support-scope.md)
- 에이전트가 따르는 현재 규칙: [`../../skills/`](../../skills/)
- 완료된 변경: [`CHANGELOG.md`](../../CHANGELOG.md)와
  [`releases/`](../releases/) 아카이브
- v1 하니스 기준선:
  [`harness-v1.0.0.md`](../verification/harness-v1.0.0.md)

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

## 비-목표 (가드레일)

- 범용 에이전트·코드 인덱서·멀티에이전트 오케스트레이터가 되지 않는다.
- 앱 보일러플레이트, UI 키트, 자동 코드 생성기를 배포하지 않는다.
- 토큰·비용을 효과 지표로 삼지 않고 메가 스킬을 만들지 않는다.
- React 프론트엔드 밖으로 범위를 넓히지 않는다. 백엔드는
  [OOPforge](https://github.com/LooSung/oopforge)가 담당한다.
- 스모크하지 않은 하니스 경로나 불안정한 통합을 지원한다고 주장하지 않는다.
