# Changelog

All notable changes to Compforge are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

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

## [1.3.6] — 2026-08-31

Documentation patch. The 1.3 command surface does not change.

### Added

- [`docs/verification/harness-cursor-negative-v1.3.5.md`](docs/verification/harness-cursor-negative-v1.3.5.md):
  Cursor's isolated negative control passed `COMPFORGE_NOT_LOADED` on v1.3.5
  after `uninstall.sh` removed the HOME-scoped pack links. Positives and slash
  still pass. The installed-pack `SKIP` path is unchanged.

## [1.3.5] — 2026-08-31

Documentation patch. The 1.3 command surface does not change.

### Changed

- The 1.0.0–1.1.0 records moved to
  [`docs/releases/changelog-1.0-1.1.md`](docs/releases/changelog-1.0-1.1.md).
  Root keeps 1.2.x onward so the 300-line maintained-text gate has room for the
  next release. `docs/releases/` is no longer 0.x-only.

## [1.3.4] — 2026-08-26

Live harness evidence for the 1.3 command surface, and the script fix that run
exposed. Stack identifiers, selection questions, and the command surface do not
change.

### Fixed

- `harness-smoke.sh live cursor` no longer fails its negative control on a
  machine where Compforge is installed. `cursor-agent` discovers
  `~/.claude/skills`, `~/.codex/skills`, and `~/.agents/skills` from `HOME`, so
  the clean-workspace control saw the symlink `install.sh` creates and reported
  `COMPFORGE_LOADED`. Because the run aborted there, it also withheld the
  slash-probe evidence. The control is now skipped with a `SKIP` line naming the
  leaking path, and the remaining probes still run.

### Changed

- The Vue scope gate in `skills/lang/frontend-stack.md`, `skills/SKILL.md`, and
  `skills/workflow/craft.md` now says Vue is outside the 1.x support scope
  instead of planned or not-yet-applicable. It already was in
  `docs/reference/support-scope.md`, the READMEs, and the 1.x direction; the
  skills were promising a stack the pack does not commit to.
- `docs/reference/support-scope.md` records that Cursor's negative control needs
  a `HOME` without the pack installed.

### Added

- [`docs/verification/harness-v1.3.4.md`](docs/verification/harness-v1.3.4.md):
  live activation for `craft`, `refactor`, and `consult` on Claude Code 2.1.212,
  Codex 0.148.0, and Cursor Agent 2026.08.11-e8db854. Claude and Codex negative
  controls pass; Cursor's is recorded as skipped, not passed.
- Self-tests covering both branches of the Cursor negative control, so the skip
  cannot silently become the only path.

## [1.3.3] — 2026-08-26

Carries the 1.3.2 complexity ladder into the Skeleton stage and the READMEs.
Stack identifiers, selection questions, and the command surface do not change.

### Changed

- `skills/skeleton/frontend-skeleton.md` and `skills/workflow/skeleton.md` now
  scaffold the thin rung by default. An agent that enters at Skeleton no longer
  sees three stacks as a flat menu, and must not create `pages/`, `widgets/`, or
  `entities/` to reserve room for growth.
- The Skeleton self-check has a layer assertion: a feature stack has no
  `pages/`, `widgets/`, or `entities/` directory.
- Both READMEs present the shipped stack identifiers as a ladder instead of a
  list, so readers see `react-vite-feature` as the starting point and
  `react-vite-fsd` as a step taken past roughly five feature areas.
- The 0.9.0 record moved to [`docs/releases/changelog-0.9.md`](docs/releases/changelog-0.9.md),
  finishing the 1.2.0 split that left root history holding one 0.x release. Root
  now keeps 1.x only and fits the 300-line maintained-text gate.

## [1.3.2] — 2026-08-26

Documentation patch. Stack identifiers, selection questions, and the command
surface do not change.

### Changed

- `skills/lang/frontend-stack.md` now states the complexity ladder explicitly:
  start on feature folders and step up to `react-vite-fsd` only when the second
  selection question is yes. Next.js stays the SSR axis, not a thicker rung.
- The import-direction diagram is now per stack. Feature folders no longer show
  `entities/` and `pages/` layers they do not have.
- The Hard Rules cross-feature import bullet names the direction per stack for
  the same reason, instead of one merged chain.

## [1.3.1] — 2026-08-26

Documentation patch. The 1.3 command surface does not change.

### Changed

- README quickstart now shows `craft`, `refactor`, and `consult` before the
  optional init step.
- Codex plugin copy and default prompts name craft, refactor, and consult.

## [1.3.0] — 2026-08-25

Public command surface. Craft stays the default entry point. Refactor and
Consult exist because they use a different authorization boundary. Frontend
tests default to hooks and DOM; Playwright E2E is not the default.

### Added

- Public `refactor` and `consult` commands. Craft stays the default entry
  point. Refactor preserves behavior; Consult does not change implementation
  code. There is no public `test` command.
- Live harness probes now activate `refactor` and `consult` on Claude, Codex,
  and Cursor in addition to Craft.

### Changed

- The Test workflow now defaults to hook and DOM component tests. Playwright
  E2E is not part of the default surface; live API wiring is a manual
  connected check.
- Claude live positive probes use `--permission-mode dontAsk`. Plan mode
  refused the activation token as an injection.

## Older releases

- [1.2.0–1.2.2](docs/releases/changelog-1.2.md)
- [1.0.0–1.1.0](docs/releases/changelog-1.0-1.1.md)
- [0.9.0](docs/releases/changelog-0.9.md)
- [0.5.0–0.8.0](docs/releases/changelog-0.5-0.8.md)
- [0.1.0–0.4.1](docs/releases/changelog-0.1-0.4.md)
