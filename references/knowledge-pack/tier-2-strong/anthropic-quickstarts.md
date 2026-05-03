---
name: anthropic-quickstarts
tier: 2
stars: 16400
url: https://github.com/anthropics/anthropic-quickstarts
license: MIT
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
---

# anthropics/anthropic-quickstarts

## 한 줄
Anthropic 공식 quickstart 모음 — Customer Support, Financial Analyst, Computer Use, Browser Tools, **Autonomous Coding Agent**. ★16.4k. MIT.

## 자기소개 (원문 발췌)
> "Claude Quickstarts is a collection of projects designed to help developers quickly get started with building applications using the Claude API. Each quickstart provides a foundation that you can easily build upon and customize for your specific needs."

## 우리 프로젝트와의 관련성
**핵심 가치**: 5개 quickstart 중 **Autonomous Coding Agent**가 우리 PGE와 직접 비교 대상. 공식이 인정하는 "two-agent pattern"의 모범.

## 5개 Quickstart

### 1. Customer Support Agent
- 자연어 + 지식베이스 접근
- → 단일 에이전트 + RAG 패턴

### 2. Financial Data Analyst
- Claude + 인터랙티브 데이터 시각화
- → 도구 호출 + 차트 생성

### 3. Computer Use Demo
- 데스크탑 컴퓨터 제어
- 최신 `computer_use_20251124` 도구 버전
- 줌 액션 지원

### 4. Browser Tools API Demo
- 브라우저 자동화 (Playwright 기반)
- 네비게이션, DOM inspection, form 조작

### 5. ⭐ **Autonomous Coding Agent** ⭐
> "An autonomous coding agent powered by the Claude Agent SDK. This project demonstrates a **two-agent pattern (initializer + coding agent)** that can build complete applications over multiple sessions, with progress persisted via git and a feature list that the agent works through incrementally."

→ **우리 PGE와 직접 비교 대상**. 공식이 인정하는 minimal pattern.

## 핵심 차용 가능 요소

### 1. **Two-Agent Pattern (공식 단순화)**
```
initializer agent ─→ coding agent
   (셋업)            (실행, 반복)
```
- 우리 PGE 3에이전트 vs 공식 2에이전트
- → **3 → 2로 줄일 가능성**의 공식 근거

### 2. **세션 간 상태 영속화 — git 활용**
> "progress persisted via git and a feature list that the agent works through incrementally"

→ 우리 `.nova/contracts/`도 git에 commit하면 동일 효과. **별도 영속화 메커니즘 불필요**.

### 3. **Feature List 점진적 처리**
- 미리 작성된 feature list
- 에이전트가 하나씩 처리
- → 우리 commander가 task를 나눠 워커에게 위임하는 패턴의 공식 모델

### 4. **Computer Use Demo의 도구 버전 표기**
- `computer_use_20251124` — 도구 버전을 명시적으로 표기
- → 우리 frontmatter에 `tools_version` 필드 추가 검토

## 우리와의 차이점

| 항목 | anthropic-quickstarts | 우리 |
|---|---|---|
| 단위 | 독립 프로젝트 5개 | 단일 메타하네스 |
| 형식 | Python/JS 코드 | Markdown agent + skill |
| 초점 | 사용자 향 도메인 앱 | 메타도구 |
| 패턴 | 개별 quickstart마다 다름 | 통일된 PGE |

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 새 quickstart 추가 시 (특히 agent 관련) 검토
- **v2 redesign**: Autonomous Coding Agent의 two-agent 패턴 차용 검토
- **분기 갱신**: 신규 quickstart 발표 추적

## 핵심 인용 (2026-05-03 기준)
> "Two-agent pattern (initializer + coding agent) that can build complete applications over multiple sessions"

## 우선순위 액션
1. **`autonomous-coding/` 디렉토리 정독** — two-agent 패턴 코드 (1순위)
2. **그 두 에이전트의 system prompt 구조 분석** → 우리 planner/commander와 비교
3. **git 기반 영속화 메커니즘** → 우리 `.nova/` 단순화 근거
4. **Computer Use / Browser Tools API 진화** — 향후 워커 도구로 활용
