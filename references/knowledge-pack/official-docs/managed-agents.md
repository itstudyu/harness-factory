---
name: managed-agents
type: official-doc
url: https://www.anthropic.com/engineering/managed-agents
publisher: Anthropic Engineering
rules_citation: "[1]"
last_analyzed: 2026-05-03
---

# Managed Agents — Anthropic Engineering [1]

## 한 줄
Anthropic의 **3계층 가상화 모델** — Session / Harness / Sandbox 분리. Brain/Hands 분리. 우리 룰 §1의 1차 출처.

## 핵심 명제
1. **3계층 가상화**
   > "We virtualized the components of an agent: a session (the append-only log), a harness (the loop that calls Claude and routes tool calls), and a sandbox."

2. **Brain / Hands 분리**
   > "brain (Claude and its harness)" vs "hands (sandboxes and tools)"
   - 인증 정보는 brain 측에 보관
   - sandbox로는 프록시로만 노출

3. **각 계층 독립 교체 가능**

## 우리 룰 매핑
- §1 첫 항목 "3계층 가상화" 직접 인용
- §1 두 번째 항목 "Brain / Hands 분리" 직접 인용
- §6 안티패턴 "단일 컨테이너 결합" 출처

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: Anthropic이 새 가상화 모델 발표 시
- **diff-reporter**: 우리가 3계층 분리를 위반했는지 검수 (주로 settings.json + agent frontmatter 점검)

## 우리 v2 영향
- planner / commander / worker = 각각 다른 sandbox에서 실행 (`isolation: worktree`) → 3계층 가상화 충실
- 인증 정보는 메인 세션에만 → Brain/Hands 분리

## 우선순위 액션
1. 분기별 블로그 신규 발행 모니터링
2. v2 README에 "3계층 가상화 따름" 명시
