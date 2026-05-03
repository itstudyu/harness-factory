---
name: agent-skills-blog
type: official-doc
url: https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills
publisher: Claude.com Blog
rules_citation: "[12]"
last_analyzed: 2026-05-03
related: tier-1-essential/anthropics-skills.md, official-docs/skills.md
note: redirect from www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills
---

# Equipping Agents for the Real World with Agent Skills — Claude Blog [12]

## 한 줄
**Progressive Disclosure** 핵심 설계 원칙 + 3단계 (metadata → SKILL.md → 외부 참조).

## 핵심 명제

1. **Progressive Disclosure 정의**
   > "Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable."

2. **3단계 구조**
   - **Level 1**: metadata (name + description)
   - **Level 2**: SKILL.md 본문
   - **Level 3+**: 외부 참조 파일

3. **비유**
   > "Like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix."

4. **Skill 설계 3원칙**
   - **(a) Start with evaluation** — 실제 태스크에서 막히는 지점 관찰
   - **(b) Structure for scale** — SKILL.md 비대 시 분리, mutually-exclusive context
   - **(c) Think from Claude's perspective** — `name`과 `description`이 자동 호출 트리거

## 우리 룰 매핑
- §3 "Progressive Disclosure" 본문 — 직접 인용
- §3 "Skill 설계 3원칙" — 직접 인용
- §3 "Skill 설계 3원칙" — 직접 인용 (반복)

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: Progressive Disclosure 정의 변경 시
- **diff-reporter**: 우리 SKILL.md가 3단계를 따르는지 검수
- **Skill 설계 시**: name + description이 자동 호출 트리거로 작동하는지 검증

## 우리 v2 영향
- v2 factory/SKILL.md
  - **Level 1**: name + description (1,536자 이내)
  - **Level 2**: SKILL.md 본문 (~100줄)
  - **Level 3**: references/ 파일들
- 현재 우리 스킬 3개는 본문이 비대 → Level 3 분리 필요

## 우선순위 액션
1. **현재 우리 3개 스킬에 Progressive Disclosure 적용** (1순위)
2. **각 스킬의 description이 자동 호출 트리거로 작동하는지 테스트**
3. **Skill 설계 3원칙 (a/b/c) 적용 점검**

## 핵심 인용
> "Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable."
