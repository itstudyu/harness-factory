# {{UMBRELLA_ROOT_NAME}}

{{PROJECT_DESCRIPTION_ONELINER}}

> 이 저장소는 **umbrella 루트**입니다. 아래의 서브 프로젝트들은 Claude Code의 공식 부모-상속 동작에 의해 이 `CLAUDE.md`와 `.claude/` 설정을 자동으로 상속받습니다. 서브 프로젝트 CWD에서 `claude`를 실행하면 상위 디렉토리를 거슬러 올라가며 `CLAUDE.md`와 `.claude/`가 병합됩니다. 심볼릭 링크나 include hack은 사용하지 않습니다.

## 정체성

{{PROJECT_IDENTITY_PARAGRAPH}}

## 설계 원칙

설계 원칙 전문은 아래 파일을 참조한다. 본 CLAUDE.md의 일부로 로드된다.

@references/harness-rules.md

## Umbrella 구조

```
{{UMBRELLA_ARCH_DIAGRAM}}
```

- **루트**: 공통 에이전트/스킬/훅/설정. 모든 서브 프로젝트가 상속받는다.
- **서브**: 기본적으로 `.claude/`를 생성하지 않는다. 상속만 받아 동작한다.
- **오버라이드**: 특정 서브가 고유 에이전트·스킬·훅이 필요한 경우에만 해당 서브에 `.claude/`를 둔다. 이 경우에도 `CLAUDE.md`는 서브에 만들지 않는다 (부모-상속으로 루트 CLAUDE.md가 자동 로드됨).

## 서브 프로젝트 목록

{{SUB_PROJECTS_LIST}}

### 상세

{{SUB_PROJECTS_TABLE}}

## 서브별 오버라이드

{{SUB_OVERRIDES_LIST}}

## 디렉토리 구조

- `.claude/agents/` — 공통 에이전트 정의 (공식 YAML frontmatter + markdown body)
- `.claude/hooks/` — 공통 자동화 훅 (stdin JSON in / stdout JSON out)
- `.claude/skills/` — 공통 스킬 정의 (SKILL.md)
- `.claude/settings.json` — 팀 공유 (checked-in). 서브에서도 상속됨
- `.claude/settings.local.json` — 개인 override (gitignored)
- `.nova/` — 세션 상태 (progress.json)
- `<sub-project>/.claude/` — 설계에 오버라이드가 명시된 서브에만 존재
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
- **서브에 `CLAUDE.md`를 만들지 않는다** — 루트 CLAUDE.md가 공식 부모-상속으로 자동 로드됨
- **서브 `.claude/`는 설계에 오버라이드가 명시된 경우에만 생성**한다
{{ADDITIONAL_CONVENTIONS}}

## 주요 에이전트

{{AGENT_LIST_TABLE}}

## 주요 스킬

{{SKILL_LIST}}

## 세션 시작

**루트에서 실행**:
```bash
cd {{UMBRELLA_ROOT_PATH}}
claude
```

**서브에서 실행** (루트 설정 자동 상속):
```bash
cd {{UMBRELLA_ROOT_PATH}}/<sub-project>
claude
```

{{SESSION_BOOTSTRAP_INSTRUCTIONS}}
