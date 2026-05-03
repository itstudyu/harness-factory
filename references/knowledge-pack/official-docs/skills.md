---
name: skills
type: official-doc
url: https://code.claude.com/docs/en/skills
publisher: Claude Code Docs
rules_citation: "[7]"
last_analyzed: 2026-05-03
related: tier-1-essential/anthropics-skills.md
---

# Skills — Claude Code Docs [7]

## 한 줄
SKILL.md 표준 + Progressive Disclosure + Agent Skills 오픈 표준 호환.

## SKILL.md frontmatter 필드 (공식)
```yaml
name, description, when_to_use, argument-hint,
disable-model-invocation, user-invocable, allowed-tools,
model, effort, context, agent, paths, hooks, shell
```

## 핵심 명제

1. **description + when_to_use 합산 1,536자 이내 front-load**

2. **사용 가능 문자열 치환**
   - `$ARGUMENTS`
   - `$ARGUMENTS[N]` / `$N`
   - `${CLAUDE_SESSION_ID}`
   - `${CLAUDE_SKILL_DIR}`

3. **Skill 위치**
   - `.claude/skills/<name>/SKILL.md`
   - 파괴적 슬래시 → `disable-model-invocation: true`

4. **Progressive disclosure**
   - SKILL.md 500라인 초과 시 별도 파일로 분리

5. **agentskills.io 오픈 표준 준수**

## 우리 룰 매핑
- §3 "Skill 위치 규약" — 직접 인용
- §3 "Progressive Disclosure" 본문 — 직접 인용
- §3 "Skill 설계 3원칙" — 직접 인용
- §7 SKILL.md frontmatter — 직접 인용

## 현재 우리 스킬 (3개)
| 스킬 | 라인 |
|---|---|
| harness-factory/SKILL.md | 163 |
| harness-upgrade/SKILL.md | 251 |
| rules-updater/SKILL.md | 210 |

→ 모두 500라인 미만 ✓
→ 다만 v2에서는 1개 스킬로 통합 + harness-upgrade는 별도 유지 검토

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: SKILL.md 신규 필드 추가 감지 (특히 `paths`, `context: fork` 등)
- **diff-reporter**: Progressive Disclosure 위반 (500라인 초과) 점검
- **분기 갱신**: agentskills.io 표준 변경 추적

## 우리 v2 영향
- factory 1개 스킬로 통합 (현재 3개)
- `paths` 필드 활용 — 특정 디렉토리에서만 자동 활성화
- `context: fork` + `agent: Plan` — 격리된 sub-agent에서 실행
- `disable-model-invocation: true` 적용 항목 명확화

## 우선순위 액션
1. **agentskills.io 표준 정독** — 외부 표준 호환성 확인 (1순위)
2. **`context: fork` 활용** — planner를 격리 sub-agent로 실행
3. **`paths` 필드** — 우리 스킬을 .claude/agents/ 작업 시만 자동 활성화
