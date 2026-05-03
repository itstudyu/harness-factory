---
name: 12-factor-agents
tier: 2
stars: 19600
url: https://github.com/humanlayer/12-factor-agents
license: Apache-2.0 (code), CC BY-SA 4.0 (content)
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
author: humanlayer (Dex)
---

# humanlayer/12-factor-agents

## 한 줄
"12 Factor Apps"의 LLM 에이전트 버전. **프로덕션급 LLM 소프트웨어를 만드는 12개 원칙**. ★19.6k.

## 자기소개 (원문 발췌)
> "What are the principles we can use to build LLM-powered software that is actually good enough to put in the hands of production customers?"
>
> "Most of the products out there billing themselves as 'AI Agents' are not all that agentic. A lot of them are mostly deterministic code, with LLM steps sprinkled in at just the right points to make the experience truly magical."

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 `harness-rules.md` 199줄과 **동일 장르의 ★19k 모범**. "원칙을 어떻게 구조화하는가"의 직접 모델.

## 12 Factors (전체)

| # | Factor | 핵심 |
|---|---|---|
| 1 | Natural Language to Tool Calls | 자연어 → 구조화 도구 호출 |
| 2 | **Own your prompts** | 프롬프트는 직접 관리. 프레임워크가 숨기지 마라 |
| 3 | **Own your context window** | Context Engineering의 본질 |
| 4 | Tools are just structured outputs | 도구 = 구조화 출력 |
| 5 | Unify execution state and business state | 상태 통합 |
| 6 | Launch/Pause/Resume with simple APIs | 일시정지/재개 API |
| 7 | Contact humans with tool calls | 인간 호출도 도구로 |
| 8 | **Own your control flow** | 제어 흐름은 코드로 |
| 9 | Compact Errors into Context Window | 에러를 압축해서 컨텍스트에 |
| 10 | **Small, Focused Agents** | 작고 집중된 에이전트 |
| 11 | Trigger from anywhere | 어디서든 트리거 |
| 12 | **Stateless reducer** | 에이전트는 stateless 함수 |

## 핵심 차용 가능 요소

### 1. **The Agent Loop (의사 코드)**
```python
initial_event = {"message": "..."}
context = [initial_event]
while True:
    next_step = await llm.determine_next_step(context)
    context.append(next_step)

    if next_step.intent == "done":
        return next_step.final_answer

    result = await execute_step(next_step)
    context.append(result)
```
→ 우리 룰 §1 "ReAct 루프" + §2 "공식 Agent Loop"의 가장 간결한 코드 표현.

### 2. **Factor 10 — Small, Focused Agents**
> "Even if LLMs continue to get exponentially more powerful, there will be core engineering techniques that make LLM-powered software more reliable."

→ 우리 v2 redesign의 **이론적 기반**. "거대한 만능 에이전트보다 작은 전문 에이전트들의 협업".

### 3. **Factor 12 — Stateless Reducer**
> "Make your agent a stateless reducer"

→ 우리 PGE 각 에이전트가 외부 상태(`.nova/contracts/`)에서 입력 받고 출력만 반환. 이미 이 원칙 부분 적용 중.

### 4. **Factor 2 — Own Your Prompts**
> "I've tried every agent framework out there... I've been surprised to find that most of the products out there billing themselves as 'AI Agents' are not all that agentic."

→ LangChain/CrewAI 같은 프레임워크 추상화 거부. 우리도 Claude Code wrapper만 쓰고 직접 .md로 프롬프트 관리. **이미 이 철학 따르는 중**.

### 5. **DAG → Agent → DAG의 진동**
> "with agents you've got this loop... it turns out this doesn't quite work"
- 초기 약속: agent에게 목표만 주면 알아서 함
- 현실: deterministic code + LLM 결정 hybrid가 더 신뢰성 있음
- → 우리 룰 §1 "Workflow vs Agent 구분"의 강력한 보강

### 6. **Visual Nav — 12개 다이어그램**
- 각 factor마다 시각적 다이어그램 1개
- → 우리 룰을 **그림으로 압축**하는 방식 차용. 199줄 → 12개 다이어그램 + 짧은 설명.

## 우리와의 차이점

| 항목 | 12-factor-agents | 우리 harness-rules.md |
|---|---|---|
| 분량 | 12개 chapter (각 1~2k 단어) | 199줄 단일 파일 |
| 형식 | 그림 + 코드 + 설명 | 텍스트 위주 |
| 대상 | 프로덕션 LLM 앱 (일반) | Claude Code 메타하네스 (특화) |
| 검증 | 컨퍼런스 토크 + 다수 founder 인터뷰 | 공식 docs 인용 |

## /harness-upgrade가 참조해야 할 시점
- **rules-updater 분기 검토**: 12 factor 중 우리가 다루지 않는 항목 (특히 Factor 5, 6, 7, 9) 검토
- **v2 redesign**: 199줄을 12 factor 스타일로 재구조화 검토
- **신규 워커 정의 시**: Factor 10 ("Small, Focused") 원칙 확인

## 핵심 인용 (2026-05-03 기준)
> "Agents, at least the good ones, don't follow the 'here's your prompt, here's a bag of tools, loop until you hit the goal' pattern. Rather, they are comprised of mostly just software."
>
> "I don't see a lot of frameworks in production customer-facing agents."

## 우선순위 액션
1. **Factor 3 (Own your context window) 정독** — 우리 룰 §5와 직접 비교 (1순위)
2. **Factor 10 (Small, Focused Agents)** — v2 설계의 핵심 원칙
3. **Factor 12 (Stateless reducer)** — 우리 PGE가 이미 충족하는지 검증
4. **`npx create-12-factor-agent` 추적** — 프로젝트 활성도 신호
5. **Visual Nav 12개 다이어그램 → 우리 룰 압축에 영감**
