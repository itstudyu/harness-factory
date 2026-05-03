---
name: claude-cookbooks
tier: 2
stars: 42000
url: https://github.com/anthropics/anthropic-cookbook
license: MIT
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
related_official_doc: official-docs/building-effective-agents.md
---

# anthropics/claude-cookbooks (= anthropic-cookbook)

## 한 줄
Anthropic 공식 레시피 모음 — Claude API로 무엇을 어떻게 만드는지의 **표준 코드 예제**. ★42k.

## 자기소개 (원문 발췌)
> "The Claude Cookbooks provide code and guides designed to help developers build with Claude, offering copy-able code snippets that you can easily integrate into your own projects."

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 룰 [3] "Building Effective Agents"의 5가지 패턴(Prompt Chaining / Routing / Parallelization / Orchestrator-Workers / Evaluator-Optimizer)이 **실제 Python 코드로 어떻게 구현되는지**의 1차 자료.

## 핵심 차용 가능 요소

### 1. **Sub-agents 노트북 — 직접적인 모델**
[`multimodal/using_sub_agents.ipynb`](https://github.com/anthropics/anthropic-cookbook/blob/main/multimodal/using_sub_agents.ipynb)
- "Use Haiku as a sub-agent in combination with Opus"
- → 우리 wshobson-agents의 3-tier 모델 전략의 공식 출처 격
- → harness-factory v2에서 planner=opus, worker=sonnet/haiku 분리 근거

### 2. **자동 평가 노트북**
[`misc/building_evals.ipynb`](https://github.com/anthropics/anthropic-cookbook/blob/main/misc/building_evals.ipynb)
- "Use Claude to automate the prompt evaluation process"
- → 우리 harness-auditor를 LLM judge로 자동화하는 모델

### 3. **Prompt caching 노트북**
[`misc/prompt_caching.ipynb`](https://github.com/anthropics/anthropic-cookbook/blob/main/misc/prompt_caching.ipynb)
- 우리 harness-rules.md §5의 캐싱 전략을 코드로 검증

### 4. **JSON mode 강제**
[`misc/how_to_enable_json_mode.ipynb`](https://github.com/anthropics/anthropic-cookbook/blob/main/misc/how_to_enable_json_mode.ipynb)
- 우리 PGE에서 planner→commander 핸드오프 시 구조화 출력 보장

### 5. **Tool use 패턴 모음**
- Customer service agent
- Calculator integration
- SQL queries
- → 단일 에이전트가 도구를 어떻게 쓰는지 표준 예제

## 우리와의 차이점

| 항목 | claude-cookbooks | 우리 |
|---|---|---|
| 범위 | API 레벨 코드 | Claude Code 메타하네스 |
| 형식 | Jupyter notebook | Markdown agent/skill |
| 추상화 | API call 직접 | Claude Code wrapping |
| 다루는 패턴 | 5패턴 모두 | PGE만 |

→ **cookbooks의 패턴 코드를 읽고, Claude Code agent 형태로 재포장**하는 것이 우리 v2 작업.

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 새 capability 추가 시 (예: vision, JSON mode) 우리 룰 §3에 반영
- **generator**: 패턴별 코드 검증 시 (예: Evaluator-Optimizer 구현) 1차 레퍼런스
- **분기 갱신**: 새 노트북 추가 추적 (특히 `tool_use/`, `misc/`)

## 핵심 인용 (2026-05-03 기준)
> "While the code examples are primarily written in Python, the concepts can be adapted to any programming language"
> "If you're new to working with the Claude API, we recommend starting with our Claude API Fundamentals course"

## 우선순위 액션
1. **`multimodal/using_sub_agents.ipynb` 정독** — 모델 분리 전략 (1순위)
2. **`misc/building_evals.ipynb` 분석** — auditor 자동화 모델
3. **`misc/prompt_caching.ipynb`** — 캐시 전략 검증
4. **분기별 issue/PR 활동량 추적** — 신규 패턴 등장 신호
