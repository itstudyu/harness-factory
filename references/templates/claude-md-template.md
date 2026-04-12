# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION_ONELINER}}

## 정체성

{{PROJECT_IDENTITY_PARAGRAPH}}

## 아키텍처: {{ARCHITECTURE_NAME}}

```
{{ARCHITECTURE_DIAGRAM}}
```

## 디렉토리 구조

- `.claude/agents/` — 에이전트 정의 (YAML frontmatter + markdown body)
- `.claude/hooks/` — 자동화 훅 (bash/python 스크립트)
- `.claude/skills/` — 스킬 정의 (SKILL.md)
- `.nova/` — 세션 상태 관리 (progress.json)
{{ADDITIONAL_DIRECTORIES}}

## 기술 스택

{{TECH_STACK_LIST}}

## 핵심 컨벤션

- 한국어 중심, 기술 용어는 영어 유지
- 에이전트 파일: kebab-case.md
- YAML frontmatter 필수 필드: name, description, role, tools, permissionMode
- 모든 에이전트에 Negative Space 섹션 필수
- PGE 역할 분리: Planner는 Edit 금지, Evaluator는 Write/Edit 금지
- 훅: bash는 `set -euo pipefail`, python은 stdin JSON → stdout JSON
{{ADDITIONAL_CONVENTIONS}}

## 주요 에이전트

{{AGENT_LIST_TABLE}}

## 주요 스킬

{{SKILL_LIST}}

## 세션 시작

{{SESSION_BOOTSTRAP_INSTRUCTIONS}}
