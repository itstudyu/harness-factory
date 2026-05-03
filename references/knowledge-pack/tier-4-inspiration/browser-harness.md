---
name: browser-harness
tier: 4
stars: 9700
url: https://github.com/browser-use/browser-harness
license: MIT
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
created: 2026-04-17
---

# browser-use/browser-harness

## 한 줄
LLM을 실제 Chrome에 직결하는 **자가치유(self-healing) CDP 하네스**. 약 1k 라인. ★9.7k.

## 자기소개 (원문 발췌)
> "Connect an LLM directly to your real browser with a thin, editable CDP harness. For browser tasks where you need complete freedom."
>
> "One websocket to Chrome, nothing between. The agent writes what's missing during execution. The harness improves itself every run."

## 우리에게 주는 영감

### 1. **Self-healing 하네스**
```
에이전트가 헬퍼가 없다 발견
   ↓
에이전트가 직접 헬퍼 작성 → agent_helpers.py
   ↓
다음 실행 시 이미 존재 → 즉시 활용
```
→ **우리 harness-upgrade의 극단적 변형**. 사용자 개입 없이 자가 진화.

### 2. **보호된 코어 + 편집 가능 영역 분리**
- `src/browser_harness/` — 보호 (에이전트 못 건드림)
- `agent-workspace/` — 자유 편집
- → 우리도 v2에서 `references/` (보호) vs `.claude/agents/workers/` (편집 가능) 명시 분리

### 3. **사람이 손글씨 금지 — 에이전트가 작성한 것만**
> "Skills are written by the harness, not by you. Just run your task with the agent — when it figures something non-obvious out, it files the skill itself."
> "Please don't hand-author skill files; agent-generated ones reflect what actually works in the browser."

→ **PR 정책의 새 패러다임**. 우리도 v2에서 사용자 워커 PR을 "에이전트 생성 + 사람 검토" 형태로 제한 검토.

### 4. **The Bitter Lesson of Agent Harnesses**
- 도구를 미리 잘 만들지 마라
- 에이전트가 학습·기록하게 하라
- → Sutton의 "Bitter Lesson"의 에이전트 버전

## 우리와의 차이점

| 항목 | browser-harness | 우리 |
|---|---|---|
| 도메인 | 브라우저 자동화 | 메타하네스 생성 |
| 자가 진화 | 에이전트 자율 (무개입) | 유저 승인 필수 (PGE) |
| 코드량 | ~1k 라인 | ~3.3k 라인 |

## /harness-upgrade가 참조해야 할 시점
- **v2 자가 진화 도입 시**: harness-upgrader를 더 자율화할 때 참조

## 핵심 인용
> "You will never use the browser again."
> "The Bitter Lesson of Agent Harnesses"

## 우선순위 액션
1. **["The Bitter Lesson of Agent Harnesses" 블로그](https://browser-use.com/posts/bitter-lesson-agent-harnesses) 일독** (1순위)
2. **`agent-workspace/domain-skills/<site>/` 구조 분석** — 우리 워커 디렉토리 모델
3. **자가 진화의 한계와 위험 학습** — 무엇을 자율화하면 안 되는가
