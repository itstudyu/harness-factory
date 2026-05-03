---
name: karpathy-skills
tier: 3
stars: 107000
url: https://github.com/forrestchang/andrej-karpathy-skills
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
based_on: https://x.com/karpathy/status/2015883857489522876
---

# forrestchang/andrej-karpathy-skills

## 한 줄
Karpathy의 LLM 코딩 함정 트윗을 4개 원칙으로 압축한 **단일 CLAUDE.md**. ★107k. 코드 0줄.

## 자기소개 (원문 발췌)
> "A single CLAUDE.md file to improve Claude Code behavior, derived from Andrej Karpathy's observations on LLM coding pitfalls."

## 우리 프로젝트와의 관련성
**핵심 가치**: "한 파일로 끝낼 수 있다"는 ★107k짜리 증명. 우리 CLAUDE.md(66줄) + harness-rules.md(199줄) = 265줄 검증 압력.

## 4가지 원칙 (전체)

| # | 원칙 | 막는 문제 |
|---|---|---|
| 1 | **Think Before Coding** | 멋대로 가정·헷갈림 숨김·트레이드오프 미제시 |
| 2 | **Simplicity First** | 1000줄짜리 비대 구현 (200→50 룰) |
| 3 | **Surgical Changes** | 인접 코드 "개선"·orphan 발생 |
| 4 | **Goal-Driven Execution** | "잘 작동함" 자기선언 |

## 핵심 차용 가능 요소

### 1. **Goal-Driven Execution — 명령형 → 목표형 변환표**
| ❌ 명령형 | ✅ 목표형 |
|---|---|
| "Add validation" | "Write tests for invalid inputs, then make them pass" |
| "Fix the bug" | "Write a test that reproduces it, then make it pass" |
| "Refactor X" | "Ensure tests pass before and after" |

→ **우리 룰 §3 "검증 기준이 최고 레버리지" [8]의 가장 압축된 표현**.

### 2. **Surgical Changes 테스트**
> "Every changed line should trace directly to the user's request."

→ 우리 harness-auditor가 새로 추가해야 할 검수 항목.

### 3. **Karpathy 인용**
> "LLMs are exceptionally good at looping until they meet specific goals... Don't tell it what to do, give it success criteria and watch it go."

→ 우리 룰 §2 "Sub-agent로 연구/탐색/리뷰 위임"의 이론적 보강.

### 4. **두 가지 설치 방법**
- Plugin marketplace
- 직접 `curl ... > CLAUDE.md`
- → 우리 v2가 단순 curl 1줄로 설치 가능한가? 검증 압력.

### 5. **"How to Know It's Working" 자기검증**
- Fewer unnecessary changes in diffs
- Fewer rewrites due to overcomplication
- Clarifying questions come before implementation
- Clean, minimal PRs

→ 우리도 v2 효과 측정 지표 정의 필요.

## 우리와의 차이점

| 항목 | karpathy-skills | 우리 |
|---|---|---|
| 분량 | 단일 CLAUDE.md (~70줄) | 13개 파일 ~3,300줄 |
| 코드 | 0줄 | 5에이전트 + 5훅 |
| 인용 횟수 | 트윗 1개 | 14개 출처 |
| ★ | 107k | (자체) |

→ **265줄 vs 70줄. 같은 효과를 70줄로?** 검증해야 함.

## /harness-upgrade가 참조해야 할 시점
- **v2 redesign**: 우리 CLAUDE.md + harness-rules.md를 100줄 이내로 압축할 근거
- **rules-updater**: 4원칙 중 우리가 명시적으로 다루지 않는 항목 (Surgical Changes 등) 추가 검토

## 핵심 인용 (2026-05-03 기준)
> "These guidelines bias toward caution over speed. For trivial tasks (simple typo fixes, obvious one-liners), use judgment — not every change needs the full rigor."

## 원본 Karpathy 트윗 (인용)
> "The models make wrong assumptions on your behalf and just run along with them without checking. They don't manage their confusion, don't seek clarifications, don't surface inconsistencies, don't present tradeoffs, don't push back when they should."
>
> "They really like to overcomplicate code and APIs, bloat abstractions, don't clean up dead code... implement a bloated construction over 1000 lines when 100 would do."

## 우선순위 액션
1. **CLAUDE.md 70줄 직접 다운로드** + 우리 것과 diff (1순위)
2. **4원칙 중 우리가 안 다루는 항목 추출** → 룰 보강
3. **v2 CLAUDE.md 압축의 모범 사례로 참조**
