---
name: prompt-eng-tutorial
tier: 3
stars: 35200
url: https://github.com/anthropics/prompt-eng-interactive-tutorial
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
---

# anthropics/prompt-eng-interactive-tutorial

## 한 줄
Anthropic 공식 **9 chapter 프롬프트 엔지니어링 인터랙티브 튜토리얼**. ★35.2k. Claude 3 Haiku 기반.

## 9개 Chapter (전체)

### Beginner
- **Chapter 1**: Basic Prompt Structure
- **Chapter 2**: Being Clear and Direct
- **Chapter 3**: Assigning Roles

### Intermediate
- **Chapter 4**: Separating Data from Instructions
- **Chapter 5**: Formatting Output & Speaking for Claude
- **Chapter 6**: Precognition (Thinking Step by Step)
- **Chapter 7**: Using Examples

### Advanced
- **Chapter 8**: Avoiding Hallucinations
- **Chapter 9**: Building Complex Prompts (Industry Use Cases)
  - Chatbot
  - Legal Services
  - Financial Services
  - Coding

### Appendix: Beyond Standard Prompting
- Chaining Prompts
- Tool Use
- Search & Retrieval

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 5개 에이전트 프롬프트가 **공식 9개 챕터 원칙을 따르는지 점검**의 1차 자료. 특히 Chapter 4 (데이터 vs 지시 분리), Chapter 6 (Step by Step)이 우리에게 직결.

## 핵심 차용 가능 요소

### 1. **Chapter 3 — Assigning Roles**
- 우리 PGE의 "[planner]/[generator]/[evaluator]" 태그 정확성 검증
- 역할 할당 best practice

### 2. **Chapter 4 — Separating Data from Instructions**
> "Separating Data from Instructions"

→ 우리 architect→generator 핸드오프 시 `.nova/contracts/` 활용이 이 원칙 따름. 강화 필요.

### 3. **Chapter 6 — Precognition (Step by Step)**
- ReAct 루프의 이론 (Lilian Weng [10])
- 우리 룰 §2 "ReAct 루프 — Thought / Action / Observation"의 구현 가이드

### 4. **Chapter 8 — Avoiding Hallucinations**
- 우리 워커가 잘못된 가정으로 작업하는 것 방지
- → harness-auditor가 hallucination 검사 항목 추가 검토

### 5. **Chapter 9 — Coding 산업 케이스**
- 코딩 도메인 복잡 프롬프트 베스트 프랙티스
- → 우리 generator/워커 프롬프트 검증 모델

### 6. **Appendix — Chaining / Tool Use / Search**
- **Chaining Prompts** = 우리 룰 §2 "Prompt Chaining" 패턴 [3]
- **Tool Use** = 워커 도구 정의
- **Search & Retrieval** = 우리 INDEX.md 활용

## 우리와의 차이점

| 항목 | prompt-eng-tutorial | 우리 |
|---|---|---|
| 형식 | 인터랙티브 노트북 + Sheets | 프로덕션 .md |
| 모델 | Claude 3 Haiku (학습용) | Opus (실전) |
| 깊이 | 기초 → 고급 | 전문 영역 |

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 9 chapter 원칙별 우리 룰 매핑 점검
- **architect/generator/auditor 갱신 시**: 각자 chapter 3, 4, 8 원칙 충족 검증

## 핵심 인용 (2026-05-03 기준)
> "Master the basic structure of a good prompt"
> "Recognize common failure modes and learn the '80/20' techniques to address them"

## 우선순위 액션
1. **Chapter 4 (데이터/지시 분리) 완수** — 우리 핸드오프 검증 (1순위)
2. **Chapter 6 (Step by Step)** — ReAct 루프 구현 정확성
3. **Chapter 8 (Hallucinations)** — 새 auditor 항목 도출
4. **Appendix Chaining** — 우리 룰 §2 보강

## 비고
- 별도 Google Sheets 버전도 존재 (더 user-friendly하다고 함)
- AWS Workshop catalog에도 호스팅됨
