# harness-factory

Claude Code 하네스(에이전트, 스킬, 훅)를 자동 생성하는 메타-하네스.

## 정체성

새 프로젝트를 위한 Claude Code 하네스 구조를 설계·생성·검증하는 도구. 공식 문서와 검증된 소스를 근거로 한 PGE (Planner–Generator–Evaluator) 패턴을 재사용한다.

## 설계 원칙

설계 원칙 전문은 아래 파일을 참조한다. 본 CLAUDE.md의 일부로 로드된다.

@references/harness-rules.md

## 아키텍처 (Orchestrator-Workers + Evaluator-Optimizer)

```
유저 요구사항
    │
    v
harness-factory (Orchestrator 스킬)
    │
    ├─▶ harness-architect (Planner)  — Flipped Interaction → 설계 문서
    ├─▶ harness-generator (Generator / Worker) — 템플릿 기반 파일 생성
    └─▶ harness-auditor  (Evaluator)  — 12항목 rubric으로 바이너리 판정
                    │
                    └─ FAIL → Generator 재위임 (최대 2회, Evaluator-Optimizer 루프)
```

## 디렉토리 구조

- `.claude/agents/` — 에이전트 정의 (공식 YAML frontmatter + markdown body)
- `.claude/hooks/` — 자동화 훅 (stdin JSON in / stdout JSON out)
- `.claude/skills/` — 스킬 정의 (SKILL.md)
- `.claude/settings.json` — 팀 공유 권한·훅 (checked-in)
- `.claude/settings.local.json` — 개인 override (gitignored)
- `references/harness-rules.md` — 설계 원칙 (CLAUDE.md로 import)
- `references/harness-references.md` — URL별 상세 분석
- `references/templates/` — 생성 템플릿
- `.nova/` — 세션 상태

## 핵심 컨벤션

- 한국어 중심, 기술 용어는 영어 유지
- 에이전트 파일: kebab-case.md, 공식 frontmatter 필드만 사용 (name, description, tools, disallowedTools, model, maxTurns, permissionMode, isolation 등)
- PGE 역할은 **description 태그**로 표기: `[planner]` / `[generator]` / `[evaluator]` — `role` 필드는 공식 스펙에 없음
- 모든 에이전트에 Negative Space 섹션 필수
- PGE 도구 접근: Planner는 Edit 금지 + Write는 `.nova/contracts/` 한정(훅 강제), Evaluator는 Write/Edit 금지 (permissionMode: default 유지 — plan 모드는 Bash까지 차단)
- 훅: bash·python 모두 stdin JSON 입력, stdout JSON 출력. `$TOOL_INPUT_FILE_PATH` 같은 환경변수는 공식 스펙에 없음

## 주요 스킬

- `/harness-factory` — 오케스트레이션 진입점. 하네스 구조 자동 생성
- `/harness-upgrade [repo]` — 기존 하네스를 최신 rules로 자동 업그레이드 (진단 → patch → 검수 → 유저 확인 후 머지). 인자 없으면 현 repo, 인자 있으면 대상 repo
- `/rules-updater` — 설계 원칙·참고자료 갱신

## 자동 제안

`references/harness-rules.md`가 마지막 갱신 후 7일 이상 경과하면 SessionStart 훅이 `/harness-upgrade` 실행을 자동 제안한다 (쿨다운 7일).
