---
name: claude-agent-sdk-blog
type: official-doc
url: https://claude.com/blog/building-agents-with-the-claude-agent-sdk
publisher: Claude.com Blog
rules_citation: "[13]"
last_analyzed: 2026-05-03
related: tier-2-strong/claude-agent-sdk-python.md
note: redirect from www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
---

# Building Agents with the Claude Agent SDK — Claude Blog [13]

## 한 줄
**공식 Agent Loop 정의** — gather context → take action → verify work → repeat.

## 핵심 명제

1. **공식 Agent Loop 3단계**
   > "gather context → take action → verify work → repeat"

2. **Tool 설계가 우선순위 1**
   > "Tools are prominent in Claude's context window, making them the primary actions Claude will consider."
   > "도구는 primary, high-frequency operation으로 설계."

3. **Code as Output**
   > "Code is precise, composable, and infinitely reusable."
   - 복잡하고 재사용 가능한 작업은 자연어 도구 호출 대신 코드 생성으로

4. **Context Management**
   - (a) 파일시스템 구조를 "a form of context engineering"으로 활용
   - (b) 초기엔 vector embedding보다 `grep`/`tail` 기반 agentic search 선호
   - (c) sub-agent로 병렬화 + 대형 context 격리
   - (d) 토큰 임계 근접 시 자동 compaction

## 우리 룰 매핑
- §2 "공식 Agent Loop" — 직접 인용
- §3 "Tool 설계가 우선순위 1" — 직접 인용
- §3 "Code as Output" — 직접 인용
- §5 "5가지 관리 패턴 (e) 파일시스템을 외부 메모리로" — 직접 인용
- §5 "Context Management in Agent SDK" — 직접 인용

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: SDK 신규 capability 발표 시
- **generator**: 워커가 "tool primary" 원칙 따르는지 검증
- **분기 갱신**: SDK 신규 패턴 추적

## 우리 v2 영향
- 모든 워커는 "gather context → take action → verify work" 3단계 명시
- 워커 도구 우선순위 명시 (primary tools를 frontmatter 상단에)
- 파일시스템(`.nova/contracts/`, `references/`)을 1차 메모리로
- vector embedding 안 씀 → grep/tail 기반 INDEX.md 활용

## 우선순위 액션
1. **각 워커에 "verify work" 단계 명시 강제** (1순위)
2. **Code as Output 패턴 활용** — 워커가 결과를 코드로 생성하면 우대
3. **agentic search 패턴** — INDEX.md에 grep-friendly 키워드 풍부화
4. **분기별 SDK 블로그 신규 발행 추적**

## 핵심 인용
> "Tools are prominent in Claude's context window, making them the primary actions Claude will consider."
> "Code is precise, composable, and infinitely reusable."
