---
name: building-effective-agents
type: official-doc
url: https://www.anthropic.com/research/building-effective-agents
publisher: Anthropic Research
rules_citation: "[3]"
last_analyzed: 2026-05-03
related: tier-2-strong/claude-cookbooks.md (실제 코드)
---

# Building Effective Agents — Anthropic Research [3]

## 한 줄
**5가지 에이전트 패턴의 정의 문서**. 우리 PGE의 출처 (Evaluator-Optimizer + Orchestrator-Workers).

## 5가지 패턴 (전체)

| # | 패턴 | 정의 |
|---|---|---|
| 1 | **Prompt Chaining** | task를 순차 LLM call로 분해 |
| 2 | **Routing** | 입력 분류 → 특화 follow-up |
| 3 | **Parallelization** | 동시 LLM call로 분할 처리 |
| 4 | **Orchestrator-Workers** | 중앙 LLM이 task 분해·위임·통합 |
| 5 | **Evaluator-Optimizer** | 한 LLM 생성, 다른 LLM 평가·피드백 루프 |

## 핵심 명제

1. **단순함이 우선**
   > "Start with the simplest solution possible, and only increase complexity when needed."

2. **Workflow vs Agent 구분**
   - Workflow: 정해진 경로
   - Agent: 스스로 경로 결정

3. **Augmented LLM = 빌딩 블록**
   - Retrieval + Tools + Memory를 갖춘 LLM이 기본 단위

4. **도구 정의의 중요성**
   > "도구 정의·문서화는 prompt engineering만큼 신중해야 한다."

## 우리 룰 매핑
- §1 "Workflow vs Agent 구분" — 직접 인용
- §1 "Augmented LLM이 빌딩 블록" — 직접 인용
- §2 "Evaluator-Optimizer 패턴" — 직접 인용 (우리 PGE의 P-E)
- §2 "Orchestrator-Workers 패턴" — 직접 인용 (우리 PGE의 O)
- §6 "자기 평가 편향" 안티패턴 — 직접 인용

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 새 패턴 추가 발표 시
- **v2 redesign**: 5패턴 중 어느 것을 추가 지원할지 결정
- **revfactory/harness 6패턴과 매핑**:
  - Anthropic 5 + revfactory만의 1 (Hierarchical Delegation) = revfactory의 6

## 우리 v2 영향
- 우리 현재: Evaluator-Optimizer (PGE) 1개
- 검토: Routing (planner가 도메인별 worker로 분기) 추가
- 검토: Parallelization (commander가 독립 task를 worker에 병렬 위임)

## 우선순위 액션
1. **5패턴 매트릭스 작성** — 우리 v2가 어느 패턴 지원할지
2. Sub-blog 추적: "When (and when not) to use agents" 등 후속 글
