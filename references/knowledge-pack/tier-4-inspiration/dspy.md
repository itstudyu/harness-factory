---
name: dspy
tier: 4
stars: 34100
url: https://github.com/stanfordnlp/dspy
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
academic_origin: Stanford NLP
---

# stanfordnlp/dspy

## 한 줄
**"프로그래밍 — 프롬프팅이 아니라"**. Declarative Self-improving Python. 프롬프트와 가중치를 **알고리즘적으로 최적화**. ★34.1k.

## 자기소개 (원문 발췌)
> "DSPy is the framework for programming—rather than prompting—language models. It allows you to iterate fast on building modular AI systems and offers algorithms for optimizing their prompts and weights."
>
> "DSPy stands for Declarative Self-improving Python. Instead of brittle prompts, you write compositional Python code and use DSPy to teach your LM to deliver high-quality outputs."

## 우리에게 주는 영감 (장기)

### 1. **프롬프트 = 코드**라는 패러다임 전환
- 우리는 markdown agent.md로 프롬프트 관리
- DSPy는 프롬프트를 Python 객체로
- → 장기적으로 우리도 코드 기반 워커 정의 검토 (효과 측정 가능)

### 2. **자동 프롬프트 최적화**
- GEPA (Reflective Prompt Evolution) — 강화학습 능가
- MIPRO — Multi-stage Instruction Prompt Optimization
- → 우리 워커 프롬프트를 **자동으로 개선**할 수 있는 미래

### 3. **DSPy Assertions**
- Self-Refining Language Model Pipelines
- → 우리 auditor의 자동 재생성 루프 모델

### 4. **학술적 근거**
- ICLR 2024 paper
- 다수 후속 논문
- → **이론적 토대가 있는 접근**. 한 번 진지하게 학습 가치.

## 우리에게 직접 적용 가능한가?
**현재**: ❌. Claude Code 환경에서 DSPy 직접 통합은 비현실적.
**장기**: ✅ 워커 프롬프트 최적화 백엔드로 검토.

## /harness-upgrade가 참조해야 할 시점
- **장기 v3 연구**: 프롬프트 자동 최적화 도입 검토 시
- **rules-updater**: GEPA/MIPRO 같은 새 알고리즘 등장 시 학습

## 핵심 인용
> "Brittle prompts" vs "compositional Python code"

## 우선순위 액션 (장기)
1. **GEPA 논문 (Jul'25) 일독** — 프롬프트 진화 알고리즘
2. **DSPy Assertions** 개념 학습
3. **현재 적용 안 함**. v3 candidate 후보로만 보관.
