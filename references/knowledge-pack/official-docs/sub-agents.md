---
name: sub-agents
type: official-doc
url: https://code.claude.com/docs/en/sub-agents
publisher: Claude Code Docs
rules_citation: "[5]"
last_analyzed: 2026-05-03
---

# Sub-agents — Claude Code Docs [5]

## 한 줄
Sub-agent 공식 frontmatter 표준 + 빌트인 3종 (Explore / Plan / General-purpose).

## Frontmatter 필드 (공식)
```yaml
name, description, tools, disallowedTools, model, maxTurns,
permissionMode, isolation, skills, memory, background, effort,
color, initialPrompt, hooks
```

## 핵심 명제

1. **빌트인 sub-agent 3종**
   - **Explore** (Haiku, 읽기 전용)
   - **Plan** (모델 상속, 읽기 전용)
   - **General-purpose** (전체 도구)

2. **Sub-agent는 summary만 반환**
   > "returns only the summary"

3. **`role` 필드 없음**
   - PGE 역할은 description의 태그로 표기 (`[planner]`, `[generator]`, `[evaluator]`)

4. **`Task` → `Agent` 리네임** (v2.1.63)
   - 기존 `Task(...)` alias로 동작

5. **`permissionMode: plan`은 읽기 전용** — Bash까지 차단

## 우리 룰 매핑
- §2 "Sub-agents vs Agent Teams 선택 기준" — 직접 인용
- §2 "역할별 도구 접근 제어" — 직접 인용
- §2 "Negative Space 섹션 필수 + role 필드 없음" — 직접 인용
- §2 "Sub-agent로 연구/탐색/리뷰 위임" — 직접 인용
- §7 frontmatter 필드 — 직접 인용

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 신규 frontmatter 필드 추가 감지 (가장 빈번)
- **diff-reporter**: 우리 에이전트 frontmatter가 표준 따르는지 검수
- **분기 갱신**: 빌트인 sub-agent 추가 시

## 우리 v2 영향
- planner 정의 시 빌트인 `Plan` 활용 검토 (직접 만들지 말고)
- worker 정의 시 빌트인 `Explore` 활용 검토 (탐색 작업)
- commander만 커스텀 정의 (오케스트레이션 도메인)

## 우선순위 액션
1. **빌트인 3종 활용 가능성 재점검** — 우리 에이전트 절반이 빌트인으로 대체 가능?
2. **frontmatter 필드 변경 추적** (월 1회)
3. **`Agent` vs `Task` 표기 통일** — 우리 코드는 Agent 사용
