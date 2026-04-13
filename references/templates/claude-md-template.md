# {{PROJECT_NAME}}

{{PROJECT_DESCRIPTION_ONELINER}}

## 정체성

{{PROJECT_IDENTITY_PARAGRAPH}}

## 설계 원칙

설계 원칙 전문은 아래 파일을 참조한다. 본 CLAUDE.md의 일부로 로드된다.

@references/harness-rules.md

## 아키텍처: {{ARCHITECTURE_NAME}}

```
{{ARCHITECTURE_DIAGRAM}}
```

## 디렉토리 구조

- `.claude/agents/` — 에이전트 정의 (공식 YAML frontmatter + markdown body)
- `.claude/hooks/` — 자동화 훅 (stdin JSON in / stdout JSON out)
- `.claude/skills/` — 스킬 정의 (SKILL.md)
- `.claude/settings.json` — 팀 공유 (checked-in)
- `.claude/settings.local.json` — 개인 override (gitignored)
- `.nova/` — 세션 상태 (progress.json)
{{ADDITIONAL_DIRECTORIES}}

## 기술 스택

{{TECH_STACK_LIST}}

## 핵심 컨벤션

- 한국어 중심, 기술 용어는 영어 유지
- 에이전트 파일: kebab-case.md, 공식 frontmatter 필드만 사용
- PGE 역할은 **description 태그**로 표기: `[planner]` / `[generator]` / `[evaluator]` — `role:` 필드는 공식 스펙에 없음
- 모든 에이전트에 Negative Space 섹션 필수
- PGE 도구 접근: Planner는 Edit 금지 + Write는 훅으로 경로 제한, Evaluator는 Write/Edit 금지 (`permissionMode: default` — `plan` 모드는 Bash 차단)
- 훅: bash·python 모두 stdin JSON 입력, stdout JSON 출력 — `$TOOL_INPUT_FILE_PATH`는 공식 스펙에 없음
{{ADDITIONAL_CONVENTIONS}}

## 주요 에이전트

{{AGENT_LIST_TABLE}}

## 주요 스킬

{{SKILL_LIST}}

## 세션 시작

{{SESSION_BOOTSTRAP_INSTRUCTIONS}}
