# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

### Changed

- Next.js 앱의 서버 도메인 코드(`src/server/`, route handler, server action)는 OOPforge의 실험적 `typescript-next` 스택으로 안내한다. 페이지·컴포넌트·클라이언트 상태는 계속 Compforge 몫이다. `SKILL.md` 스택 범위, `frontend-stack.md`, 지원 범위 문서, README의 자매 팩 표와 `forge` 마켓플레이스의 OOPforge 설명을 맞췄다.

## [1.11.1] — 2026-11-19

문서 정리만 있고 동작 변경은 없다.

### Removed

- 2026-07 경쟁 스킬 조사 기록 `docs/research/competitor-skills.md`. Hard Rules의 정본은 `skills/principles/hard-rules.md`이고, 조사 결과는 릴리스 아카이브(`docs/releases/changelog-0.1-0.4.md`)에 남아 있다.

## [1.11.0] — 2026-11-19

주석 규율(쓰기·읽기), Review의 `Next` 명령.

### Added

- Review: 지적마다 바로 실행할 수 있는 `Next:` 명령을 붙인다. 동작 결함은 `/compforge:craft`, 빠지거나 약한 테스트는 `/compforge:test`, 동작을 바꾸지 않는 구조 개선은 `/compforge:refactor`. 보고서 끝 `Next` 묶음은 craft → test → refactor 순서로, 테스트가 동작을 고정한 뒤 refactor한다. Review 자체는 여전히 코드를 바꾸지 않는다.

### Changed

- 주석 규율(`component-discipline` #13)을 쓰기·읽기 두 쪽으로 바꿨다. 쓰기: 의도는 이름 → 타입 → 깨지는 테스트 순으로 담고, 주석은 그걸로 못 담는 why만 이미 있는 테스트나 링크를 근거로 남긴다. 문서 주석과 도구 지시 주석은 대상이 아니다. 읽기: 주석은 주장이지 근거가 아니다. 주석이 코드와 어긋나면 테스트나 어느 쪽이 나중에 바뀌었는지 보여 주는 이력으로만 움직이고, 없으면 둘 다 두고 보고한다. 내 변경이 틀리게 만든 주석만 고치고 나머지는 보고한다.
- Hard Rules: SHOULD 문구를 위와 맞추고 NEVER "주석에만 맞춰 코드를 바꾸지 않는다"를 추가했다. Review는 diff가 틀리게 만든 주석을 P2, 새 서술 주석을 P3로 본다. 버그 수정 플레이북·리뷰어 체크리스트·한국어 방법론도 같은 규칙으로 맞췄다.
- `refactor` 명령 예산을 19000 → 19200바이트로 올렸다. 원칙 파일이 craft·refactor에 통째로 인라인되는데, 위 읽기 규칙이 오래된 주석을 근거로 고쳐진 코드를 되돌리는 실수를 막는 유일한 문장이라 줄이지 않았다. 실제 크기 19175바이트.

## [1.10.0] — 2026-11-19

Forge 마켓플레이스, 짧아진 README·AGENTS·CLAUDE.

### Added

- Claude Code 플러그인 마켓플레이스 `forge` (`.claude-plugin/marketplace.json`, 실험적). `/plugin marketplace add LooSung/compforge` 후 `/plugin install compforge@forge`. 같은 카탈로그에 `oopforge@forge`, `fuseforge@forge`도 있다. 설치·업데이트·제거와 실제 로드 검증: `docs/verification/marketplace-2026-11-19.md`.
- `skills/SKILL.md`: 플러그인으로 로드되면 플러그인 루트를 팩 루트로 본다. `init` 포인터 블록도 `~/.claude/plugins/cache/forge/compforge/<version>`을 마지막 팩 위치로 찾는다.

### Changed

- `README.md`·`README.ko.md`를 설치 한 줄 → 사용 예시 → 명령 표 → 동작 방식 순서의 짧은 문서로 다시 썼다. Forge 패밀리(Compforge·OOPforge·FuseForge) 표와 프로젝트 스위치 표를 추가했다.
- `AGENTS.md`를 이 저장소를 수정하는 에이전트용 지도(구조·CI 체크·규칙)로 줄였다. 명령 라우팅은 `skills/SKILL.md`에만 둔다.
- `CLAUDE.md`는 `@AGENTS.md`와 Claude 전용 두 줄만 남겼다.
- 설치·업데이트·제거 상세는 `docs/setup/install.md`로 옮겼다.
- `init`이 대상 프로젝트 `AGENTS.md`에 쓰는 포인터 블록이 라우팅 출처로 `{pack}/AGENTS.md` 대신 `{pack}/skills/SKILL.md`를 가리킨다. 기존 프로젝트는 `init.sh`를 다시 실행하면 갱신된다.

## [1.9.1] — 2026-11-18

### Fixed

- 루트 `CHANGELOG.md`가 300줄 제한을 넘어 CI가 실패했다. 1.3.x 기록을 `docs/releases/changelog-1.3.md`로 옮겼다.
  기능은 1.9.0과 같다. 1.9.0 태그는 남겨 두고 GitHub Release는 1.9.1로 낸다.

## [1.9.0] — 2026-11-18

Crucible, shared gates, plan input, and command budgets.

### Added

- **`/compforge:crucible`** (experimental) — 한 요청으로 Consult(계획 문서) → Craft → Refactor(필요할 때만)
  → Test(빈 곳 보강)를 차례로 실행한다. 계획 승인에서 한 번 반드시 멈추고, 이후에는 결정이 필요하거나
  검사가 실패할 때만 멈춘다. 자체 규칙은 없고 기존 워크플로를 그대로 쓴다. 보고는 마지막에 한 번.

### Changed

- **Gates** — 시작·이어하기·검증·완료 보고를 `skills/workflow/gates.md` 하나로 옮겼다. Craft·Refactor·Test·Crucible이
  같은 파일을 쓰고, Refactor·Test 명령은 더 이상 Craft 전체를 싣지 않는다. 명령 크기: refactor −23%, test −54%,
  craft +3%(계획 입력 추가).
- **Plan input** — 승인된 계획 문서(Consult가 쓴 Delivery Plan·Design 등)를 지정하면 그 결정은 확정으로 보고 다시 묻지 않는다.
  Assumptions에는 계획이 남긴 것만 쓰고, 계획과 코드가 어긋나면 멈추고 묻는다.
- **Environment Facts** — 알게 된 사실이 있을 때만 쓴다(`none` 줄을 매번 쓰지 않는다).
- **Command budget** — 생성된 명령마다 바이트 예산(`scripts/ci/command-budget.json`)을 두고 넘으면 검사가 실패한다.
- **Test** — 권한 표, 테스트 수준 선택(unit·component), 시작 전 범위 선언, 보고 규칙을 더했다. 이번 실행에서 이미 기록된
  테스트가 있으면 빈 곳만 채운다.

## [1.8.0] — 2026-11-18

Public `test` command, public-versus-internal names, and environment facts.

### Added

- **`/compforge:test`** — 훅·컴포넌트 테스트를 확인·작성·보강한다. Craft 시작·완료 게이트를 쓰고
  프로덕션 동작을 바꾸지 않으며 E2E는 기본값이 아니다. 1.3.0의 "공개 `test` 커맨드 없음" 결정을
  되돌린다. OOPforge와 명령 구성이 달라 FuseForge가 두 팩을 함께 쓸 때 혼동이 생겼다.

### Changed

- **Names** — 구조를 정당화하는 "사용자의 단어" 규칙은 이름마다 묻게 하는 규칙이 아니다.
  공개 이름(경로·엔드포인트·오류 코드·화면 문구·도메인 개념)만 묻고, 내부 이름은 기존 관례를 따른
  기본값으로 정해 목록 하나로 보여준다.
- **Environment Facts** — 완료 보고에 이번 세션에서 알게 된 환경 사실을 적는다. 사용자가 동의하면
  대상 프로젝트 `AGENTS.md`에 덧붙이고, 에이전트 메모리나 `.craft/`에만 두지 않는다.
- **Proof template** — 증명 결과에 걸린 시간, 토큰, 사람에게 물은 결정 수와 추천이 바뀐 수,
  설계 단계에서 잡은 결함과 그 비용을 기록한다. 채점기는 실행 전에 커밋을 기록하고, 이후 수정은
  재채점으로 따로 보고한다.
- **Context budget** — 대화가 한 번 자동 요약되었거나, 단계 둘 이상을 끝냈거나, 같은 상태 질문·같은 파일 읽기가 반복되면 안전한 지점에서 세션을 끊는다.
  안전한 지점은 실행 중인 에이전트·명령·머지가 없고, 변경이 커밋·기록되었고, `next-session-prompt.md` 가 커밋·대화 속 결정·남은 순서를 담은 때다.

## [1.7.3] — 2026-11-16

Size gate for small Craft tasks. Craft stays the default entry point.

### Changed

- **Size gate** — 기존 파일 두 개 이하를 고치고 새 컴포넌트·훅·상태 위치·쿼리·context를 만들지 않으며
  의존성·공개 API를 바꾸지 않는 작업은 작은 작업이다. Assumptions와 Component Contract는
  한 줄씩, 완료 보고는 `Changed`·`Verified`·`Scope drift` 세 줄이다. 규칙, 테스트,
  Scope drift는 그대로 적용된다. 측정에서 형식 분량은 줄었지만 비용은 거의 같았다.
  남은 출력의 대부분은 버그 수정 규칙이 요구하는 회귀 테스트다.
- **Evals** — `craft-small-fix` 케이스를 더했다.

## [1.7.2] — 2026-11-16

Inlined workflows in multi-file commands. Craft stays the default entry point.

### Changed

- **명령에 workflow 본문 포함** — `craft`, `refactor` 명령은 workflow와 원칙 파일의
  본문을 명령 안에 담는다. 파일을 하나씩 읽는 턴이 없어진다. `claude plugin eval`
  측정에서 craft는 9턴에서 4턴, 비용 약 34% 감소(같은 점수)였다. refactor는 턴은
  줄지만 계획을 더 길게 써서 비용은 비슷할 수 있다.
  원본은 계속 `skills/`이고, `scripts/ci/build-commands.py`가 복사한다. lint가
  `--check`로 어긋남을 잡는다. 스킬을 고친 뒤에는 이 스크립트를 다시 돌린다.

## [1.7.1] — 2026-11-16

Live run and the cleanup pass are opt-in. Craft stays the default entry point.

### Changed

- **Live run** — 기본으로 꺼져 있다. 사용자가 그 요청에서 부탁했거나 대상
  `AGENTS.md`에 `Compforge live run: on`이 있을 때만 앱를 띄운다. 꺼져 있으면
  `Live run: not run`과 손으로 확인할 것을 한 줄로 보고한다. 앱 실행이 팩에서
  가장 비싼 동작이라 Craft와 Refactor마다 돌지 않게 했다.
- **Refactor cleanup pass** — 기본으로 꺼져 있다. 사용자가 부탁했거나
  `Compforge cleanup pass: on`이 있을 때만 `/simplify`를 돌린다.

## [1.7.0] — 2026-11-16

Review command, live runs, and skill hygiene against the Claude Code skill
guidance. Craft stays the default entry point.

### Added

- **Review** — `/compforge:review`는 끝난 변경 하나(현재 diff, 브랜치, PR, 붙여넣은 diff)를
  기준 커밋에 고정해 리뷰한다. 의견은 P1(머지 전 필수)·P2(머지 전 권장)·
  P3(선택)이고, 각 의견에 근거 줄과 가장 작은 수정 방향을 적는다. PR 본문의
  "먼저 봐 주세요"·테스트·자가 점검을 읽기 순서와 검증할 주장으로 쓴다.
  코드는 바꾸지 않고, PR 코멘트는 요청할 때만 단다. 팩 리뷰어
  (`scripts/ci/review`)와 하네스의 버그 리뷰(`/code-review`)는 있으면 쓴다.
- **Refactor cleanup pass** — 검증이 통과한 뒤 하네스에 diff 범위 정리
  스킬(`/simplify`)이 있으면 한 번 돌리고, 테스트를 다시 돌리고, 바뀐 것을
  Scope drift에 적는다.
- **Live run** — `workflow/test.md`의 연결 확인에 하네스의 실행 스킬
  (`/verify`, `/run`)을 쓴다. 기존 시작 명령만 쓰고 아무것도 설치하지 않으며,
  관찰한 결과를 근거로 남긴다. Craft는 테스트 통과 후, Refactor는 첫 이동 전과
  마지막 이동 후에 같은 시나리오로 이 섹션을 따른다.
- **Evals** — `evals/`에 `claude plugin eval` 케이스 세 개(review, consult,
  craft)가 있다. 플러그인 유무를 비교해 점수 차이를 보고한다.

### Changed

- **Consult Review** — 설계, 코드 영역, 기존 코드 질문을 다룬다. 끝난 diff나
  PR은 `/compforge:review`로 안내한다.
- **SKILL.md** — description을 3인칭으로, 핵심 용도부터 쓴다. `stability`는
  Agent Skills 스펙에 맞춰 `metadata` 아래로 옮겼다(claude.ai 업로드와 Skills
  API가 스펙 밖 키를 거부한다). 모든 스킬 파일을 SKILL.md에서 바로 링크하고,
  compaction 뒤에는 라우팅된 workflow를 다시 읽는다.
- **목차** — 100줄이 넘는 스킬 파일은 제목 아래 `Contents:` 한 줄을 둔다.
- **명령** — 모든 명령에 `argument-hint`가 있다.
- **패키징 검사** — SKILL.md frontmatter가 스펙 키만 쓰고 YAML을 깨는
  `: `가 없는지 확인한다.

## [1.6.1] — 2026-10-28

State placement and workflow wording fixes. Craft stays the default entry point.

### Fixed

- **상태 배치** — `react/state-placement.md`에서 멀리 떨어진 컴포넌트가
  공유하는 상태는 composition 먼저, 그다음 context나 store다.
  `component-discipline`과 Hard Rules와 같은 순서다.
- **문구** — 지원 스택을 "Supported: TypeScript + React"로 적는다.
  `CLAUDE.md`의 워크플로가 Test 단계까지 포함한다.

## [1.6.0] — 2026-10-27

Jira children and a backlog card. Craft stays the default entry point.

### Added

- **Jira backlog** — `/compforge:jira`에 백로그 템플릿이 있다. 본문은
  배경·결과·범위·미결·참고다. Jira에 백로그 이슈 타입은 없으므로, 같이 말한
  스토리·작업·버그로 만들고 말이 없으면 스토리다. 스프린트는 비운다.
- **Jira children** — `/compforge:jira`로 이미 있는 에픽이나 스토리의 자식
  작업을 한 번에 쓴다. 제목은 `[F.E]` `[B.E]` `[AI]` `[DOC]` 중 하나다. 문서나
  리포트 자체가 결과일 때만 `[DOC]`이다. 이 저장소의
  트랙이 아닌 자식은 다른 저장소가 어떻게 연결해서 작업하는지를 적는다. 부모
  본문은 바꾸지 않는다.

## [1.5.0] — 2026-10-26

Existing command. Craft stays the default. Jira writes one task, story, bug, or epic.

### Changed

- **Jira types** — `/compforge:jira` defaults to Task. Story, bug, and epic use their own fixed template when the request names that type, and one invocation writes one issue. An epic body lists only its starting children; later children attach by parent link.

## [1.4.0] — 2026-10-26

Public command. Craft stays the default. Jira writes one card and changes nothing else.

### Added

- **Jira command** — `/compforge:jira`(Codex/Cursor는 `Use Compforge jira: …`)가
  개요·작업 내용·영향 범위·테스트 확인·참고 다섯 절의 고정 템플릿으로 Jira 작업
  카드 하나를 쓴다. 코드는 바꾸지 않고, Jira 쓰기는 명시 요청 때만 HTML
  task-list 로 저장한다.

## Older releases

- [1.3.0–1.3.6](docs/releases/changelog-1.3.md)
- [1.2.0–1.2.2](docs/releases/changelog-1.2.md)
- [1.0.0–1.1.0](docs/releases/changelog-1.0-1.1.md)
- [0.9.0](docs/releases/changelog-0.9.md)
- [0.5.0–0.8.0](docs/releases/changelog-0.5-0.8.md)
- [0.1.0–0.4.1](docs/releases/changelog-0.1-0.4.md)
