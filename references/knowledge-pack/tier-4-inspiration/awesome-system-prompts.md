---
name: awesome-system-prompts
tier: 4
stars: 5800
url: https://github.com/dontriskit/awesome-ai-system-prompts
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
note: 유출/공개된 상용 에이전트의 system prompt 모음
---

# dontriskit/awesome-ai-system-prompts

## 한 줄
Cursor, Cline, Devin, v0 등 **상용 에이전트의 system prompt 모음**. ★5.8k. 길이 벤치마크용.

## 자기소개 (원문 발췌)
> "🧠 Curated collection of system prompts for top AI tools. Perfect for AI agent..."

## 8가지 핵심 원칙 (README에서 추출)
1. Clear Role Definition and Scope
2. Structured Instructions and Organization
3. Explicit Tool Integration and Usage Guidelines
4. Step-by-Step Reasoning and Planning
5. Environment and Context Awareness
6. Domain-Specific Expertise and Constraints
7. Safety, Alignment, and Refusal Protocols
8. Consistent Tone and Interaction Style

## 우리에게 주는 영감

### 1. **상용 에이전트 system prompt 길이 벤치마크**
- Vercel v0
- same.new
- Manus
- ChatGPT (GPT-4.5/4o)
- Cline, Bolt, Augment, Claude Code, Clawdbot
- → **우리 architect/generator/auditor 프롬프트와 길이/구조 비교**

### 2. **8개 원칙 = 우리 12+1 rubric의 다른 표현**
| 이쪽 8개 | 우리 룰 매핑 |
|---|---|
| Clear Role Definition | §2 역할별 도구 접근 제어 |
| Structured Instructions | §3 SKILL.md 구조 |
| Explicit Tool Integration | §3 Tool 설계 우선순위 |
| Step-by-Step Reasoning | §2 ReAct 루프 |
| Environment Awareness | §1 Sandbox + 가상화 |
| Domain Expertise | (워커별 정의) |
| Safety / Refusal | §4 에러 처리 |
| Consistent Tone | (우리 룰 명시 안 됨) |

→ **"Consistent Tone" 원칙은 우리 룰에 없음**. v2 검토 항목.

### 3. **Case Study 형식**
- 각 상용 에이전트의 unique convention과 architectural difference 분석
- → 우리도 v2에서 워커별 case study 작성 가치

## 주의 사항

⚠️ **저작권 / 윤리**
- 유출된 prompt 포함 가능
- 우리는 **참고만**, 직접 복사 금지
- 라이선스 불명확

## /harness-upgrade가 참조해야 할 시점
- **프롬프트 길이 검수**: 우리 에이전트 프롬프트가 업계 표준 길이인지
- **8원칙 vs 우리 12+1 rubric 매핑**: 누락 항목 발견

## 우선순위 액션
1. **상용 prompt 길이 통계** — 우리 프롬프트 슬림화 근거
2. **8원칙 매핑** — 우리 rubric 누락 항목 (특히 Consistent Tone) 발굴
3. **직접 복사 절대 금지** — 영감만, 우리 표현으로 재작성

## 핵심 인용
> "A well-crafted system prompt is critical for ensuring the agent acts reliably, safely, and effectively towards the user's goals."
