---
name: anthropics-skills
tier: 1
stars: 127000
url: https://github.com/anthropics/skills
license: Apache-2.0 (대부분), source-available (docx/pdf/pptx/xlsx)
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
related_official_doc: official-docs/skills.md, official-docs/agent-skills-blog.md
---

# anthropics/skills

## 한 줄
Agent Skills의 **공식 표준 + 1차 레퍼런스 구현**. ★127k. agentskills.io 오픈 표준의 본가.

## 자기소개 (원문 발췌)
> "Skills are folders of instructions, scripts, and resources that Claude loads dynamically to improve performance on specialized tasks."
>
> "This repository contains skills that demonstrate what's possible with Claude's skills system."

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리가 만드는 SKILL.md의 **포맷 정의처**. 우리 templates/skill-template.md가 공식 표준에 부합하는지 검증의 1차 자료.

## 핵심 차용 가능 요소

### 1. **최소 SKILL.md 골격 (공식)**
```markdown
---
name: my-skill-name
description: A clear description of what this skill does and when to use it
---

# My Skill Name
[instructions]

## Examples
## Guidelines
```

**필수 필드는 단 2개**: `name`, `description`.
→ 우리 templates/skill-template.md의 frontmatter가 너무 비대할 가능성. 검증 필요.

### 2. **Skill 카테고리 4종 (공식 분류)**
- Creative & Design
- Development & Technical
- Enterprise & Communication
- Document Skills (docx/pdf/pptx/xlsx)

### 3. **3가지 사용 통로**
- Claude Code: `/plugin marketplace add anthropics/skills`
- Claude.ai: 모든 유료 플랜 기본 활용
- Claude API: Skills API quickstart로 업로드

### 4. **Document Skills가 source-available인 이유**
> "We've also included the document creation & editing skills that power Claude's document capabilities under the hood"

→ 프로덕션에서 실제 동작하는 복잡한 스킬의 **레퍼런스 구현체**. 우리 SKILL.md 작성 시 가장 가까운 모델.

### 5. **Plugin 분류**
- `document-skills` — docx/pdf/pptx/xlsx
- `example-skills` — 데모/교육용

## 우리와의 차이점

| 항목 | anthropics/skills | 우리 |
|---|---|---|
| 목적 | 사용자용 도메인 스킬 | 메타하네스 생성 |
| 표준 위상 | **표준 자체** | 표준 추종자 |
| frontmatter 복잡도 | 최소 2 필드 | 10+ 필드 |
| 등록 | Marketplace | 로컬 .claude/skills/ |

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: SKILL.md 표준 변경 감지 (필드 추가/제거)
- **generator**: 우리 생성 SKILL.md가 표준에 부합하는지 1차 검증
- **분기 갱신**: 새 partner skill 등재 (Notion 등) 추적

## 핵심 인용 (2026-05-03 기준)
> "The frontmatter requires only two fields: `name` and `description`"
> "Always test skills thoroughly in your own environment before relying on them for critical tasks"

## 관련 공식 자료 (Cross-Reference)
- [Skills 공식 docs](official-docs/skills.md) [7]
- [Agent Skills 블로그](official-docs/agent-skills-blog.md) [12]
- [agentskills.io](https://agentskills.io) — 오픈 표준 본가

## 우선순위 액션
1. **template/ 디렉토리의 template-skill 다운로드 후 우리 템플릿과 diff** (1순위)
2. **공식 spec/ 디렉토리 정독** — 표준 변경사항 추적
3. **Document Skills의 SKILL.md 5개 분석** — 복잡한 스킬의 베스트 프랙티스
4. **partner skill (Notion 등) 발생 시 → 우리 워커 정의 영감**
