---
name: anthropic-courses
tier: 3
stars: 21000
url: https://github.com/anthropics/courses
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
---

# anthropics/courses

## 한 줄
Anthropic 공식 5개 코스 — API fundamentals부터 Tool Use까지의 **공식 학습 경로**. ★21k.

## 5개 코스 (권장 순서)

| # | 코스 | 핵심 |
|---|---|---|
| 1 | **Anthropic API fundamentals** | API key, model parameters, multimodal, streaming |
| 2 | **Prompt engineering interactive tutorial** | 9 chapters of prompting techniques (별도 repo) |
| 3 | **Real world prompting** | 복잡한 실전 프롬프트 |
| 4 | **Prompt evaluations** | 프롬프트 품질 측정 |
| 5 | **Tool use** | 도구 사용 워크플로 |

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 에이전트 프롬프트 작성·평가·도구 사용의 **공식 교과서**. 특히 **Prompt evaluations**가 우리 harness-auditor 자동화의 직접 모델.

## 핵심 차용 가능 요소

### 1. **Prompt evaluations — Auditor 자동화 모델**
- "Learn how to write production prompt evaluations to measure the quality of your prompts."
- → 우리 12+1 rubric을 LLM judge로 자동화하는 표준 접근

### 2. **Real world prompting — 복잡 프롬프트 구조**
- AWS Workshop / Google Vertex 버전 존재
- → 우리 architect/generator의 프롬프트 구조화 모범

### 3. **Tool use 코스 — 워커 도구 정의**
- 우리 v2 워커가 도구를 어떻게 정의해야 하는지
- → claude-cookbooks의 tool_use 카테고리와 함께 정독

### 4. **Anthropic API fundamentals — 기초 검증**
- API key, multimodal, streaming
- → 우리가 SDK를 직접 쓰는 게 아니라 Claude Code 위에 있지만, 기초 이해 필수

### 5. **모델 비용 의식**
> "Please note that these courses often favor our lowest-cost model, Claude 3 Haiku, to keep API costs down for students following along with the materials."

→ 우리도 워커는 haiku 활용 가능성 검토.

## 우리와의 차이점

| 항목 | anthropic-courses | 우리 |
|---|---|---|
| 목적 | 학습 | 프로덕션 메타하네스 |
| 형식 | 단계별 노트북 | 운영 가능한 .md 파일 |
| 깊이 | 기초→고급 | 전문 영역 (메타하네스) |

## /harness-upgrade가 참조해야 할 시점
- **분기 갱신**: 새 코스 추가 추적 (특히 agent 관련)
- **rules-updater**: Prompt evaluations 코스의 rubric을 우리 12+1과 통합 검토

## 우선순위 액션
1. **Prompt evaluations 코스 완수** — auditor 자동화 (1순위)
2. **Tool use 코스** — 워커 도구 정의 표준
3. **Real world prompting** — 우리 architect 프롬프트 검증
4. **분기별 신규 코스 모니터링**

## 비고
- 단독으로는 영향이 크지 않지만 **공식 자료 컬렉션**이라는 권위
- prompt-eng-interactive-tutorial이 별도 repo (T3#12)로 분리되어 있음
