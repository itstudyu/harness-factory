---
name: openai-swarm
tier: 3
stars: 21000
url: https://github.com/openai/swarm
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
status: deprecated (replaced by openai-agents-python)
successor: https://github.com/openai/openai-agents-python
---

# openai/swarm

## 한 줄
OpenAI의 **교육용 멀티에이전트 최소 구현**. ★21k. ⚠️ Deprecated — openai-agents-python으로 이전됨.

## ⚠️ 상태 경고
> "Swarm is now replaced by the OpenAI Agents SDK, which is a production-ready evolution of Swarm. The Agents SDK features key improvements and will be actively maintained by the OpenAI team."

→ **프로덕션 사용 금지. 교육 목적만**. 후속 SDK 추적 필요.

## 자기소개 (원문 발췌)
> "Swarm focuses on making agent **coordination** and **execution** lightweight, highly controllable, and easily testable."
>
> "It accomplishes this through two primitive abstractions: `Agent`s and **handoffs**."

## 우리 프로젝트와의 관련성
**핵심 가치**: 멀티에이전트의 **하한선** 구현. 추상화 0개. "abstraction을 얼마나 줄일 수 있는가"의 모범. 다만 deprecated이므로 **개념만 차용**.

## 핵심 차용 가능 요소

### 1. **두 개의 Primitive만으로 멀티에이전트 표현**
```python
agent_a = Agent(
    name="Agent A",
    instructions="You are a helpful agent.",
    functions=[transfer_to_agent_b],  # handoff function
)

agent_b = Agent(
    name="Agent B",
    instructions="Only speak in Haikus.",
)

response = client.run(agent=agent_a, messages=[...])
```

**핵심**:
- `Agent` = `instructions` + `tools`
- `handoff` = 일반 함수가 다른 Agent를 반환

→ **우리 v2의 commander가 워커에게 위임하는 패턴의 이론적 골격**. 단순함의 극치.

### 2. **Stateless 설계**
> "Swarm runs (almost) entirely on the client and, much like the Chat Completions API, does not store state between calls."

→ 우리 룰 §2 "세션 종료 계약" + 12-factor Factor 12 "Stateless reducer"의 강력한 보강.

### 3. **6개 examples 카테고리**
- `basic` — fundamentals (setup, function calling, handoffs)
- `triage_agent` — 라우팅 패턴
- `weather_agent` — function calling
- `airline` — multi-agent for customer service
- `support_bot` — UI agent + help center
- `personal_shopper` — sales + refund

→ "이 정도 다양성이 단순한 abstraction으로 다 표현된다"는 증거.

### 4. **"Why Swarm" 철학**
> "Swarm explores patterns that are lightweight, scalable, and highly customizable by design. Approaches similar to Swarm are best suited for situations dealing with a large number of independent capabilities and instructions that are difficult to encode into a single prompt."

→ 우리도 워커가 늘어날 때 동일 문제 직면. **워커 단위 분리 = swarm 패턴**.

## 우리와의 차이점

| 항목 | openai-swarm | 우리 |
|---|---|---|
| 형식 | Python 코드 | Markdown |
| 추상화 | 2개 (Agent, handoff) | 5에이전트 + 5훅 + 7템플릿 |
| 상태 | Stateless | `.nova/contracts/` 영속 |
| 운영 | OpenAI Chat API | Claude Code |

## /harness-upgrade가 참조해야 할 시점
- **v2 redesign**: "추상화를 얼마나 더 줄일 수 있나" 검증
- **신규 워커 패턴 검토**: triage / multi-agent 패턴 모방

## 후속 자료 (필수 추적)
**[openai/openai-agents-python](https://github.com/openai/openai-agents-python)** — ★25.8k
- "lightweight, powerful framework for multi-agent workflows"
- 프로덕션 ready
- 향후 분석 후 tier-2로 승격 검토

## 핵심 인용 (2026-05-03 기준)
> "These primitives are powerful enough to express rich dynamics between tools and networks of agents, allowing you to build scalable, real-world solutions while avoiding a steep learning curve."

## 우선순위 액션
1. **`examples/basic`의 handoff 코드 정독** — 단순화의 모범 (1순위)
2. **`examples/triage_agent`** — 라우팅 패턴
3. **후속 SDK (openai-agents-python) 추적** — tier 재평가
4. **handoff 패턴 → 우리 commander 위임 메커니즘 영감**
