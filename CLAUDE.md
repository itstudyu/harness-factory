# harness-factory

Claude Code 하네스(에이전트, 스킬, 훅)를 자동 생성하는 메타-하네스.

## 정체성

이 프로젝트는 새 프로젝트를 위한 Claude Code 하네스 구조를 설계하고 생성하는 도구이다.
기존 harness-devops 프로젝트의 PGE (Planner-Generator-Evaluator) 패턴을 재사용한다.

## 아키텍처: PGE 패턴

```
유저 요구사항
    │
    v
harness-architect (Planner) ── Flipped Interaction으로 요구사항 명확화
    │                           설계 산출물: .nova/contracts/harness-design.md
    v
harness-generator (Generator) ── 템플릿 기반 파일 생성, worktree 격리
    │
    v
harness-auditor (Evaluator) ── 12항목 바이너리 체크리스트, 읽기 전용
    │
    v
결과 보고 (PASS/FAIL)
```

## 디렉토리 구조

- `.claude/agents/` — 에이전트 정의 (YAML frontmatter + markdown body)
- `.claude/hooks/` — 자동화 훅 (bash/python 스크립트)
- `.claude/skills/` — 스킬 정의 (SKILL.md)
- `references/harness-rules.md` — 설계 원칙 (SessionStart hook으로 매 세션 주입, 2200 words 이내)
- `references/harness-references.md` — URL별 상세 분석 (수동 참조용)
- `references/templates/` — 에이전트/스킬/훅 생성 템플릿
- `.nova/` — 세션 상태 관리

## 핵심 컨벤션

- 한국어 중심, 기술 용어는 영어 유지
- 에이전트 파일: kebab-case.md, YAML frontmatter 필수 필드: name, description, tools, permissionMode
- 모든 에이전트에 Negative Space 섹션 필수
- PGE 역할 분리: Planner는 Edit 금지, Evaluator는 Write/Edit 금지
- 훅: bash는 `set -euo pipefail`, python은 stdin JSON → stdout JSON
- 설계 원칙은 `references/harness-rules.md` 참조 (hook으로 자동 주입됨)

## 주요 스킬

- `/harness-factory` — 메인 진입점. 하네스 구조 자동 생성
- `/rules-updater` — 설계 원칙/참고자료 갱신 (공식 문서, trusted article)
