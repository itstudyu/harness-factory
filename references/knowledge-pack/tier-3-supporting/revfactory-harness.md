---
name: revfactory-harness
tier: 3
stars: 2600
url: https://github.com/revfactory/harness
license: Apache-2.0
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
note: 우리 harness-rules.md [15] 출처. 가장 직접적인 동일 카테고리 비교 대상.
---

# revfactory/harness

## 한 줄
**우리와 같은 L3 메타-팩토리 카테고리의 직접 경쟁자 / 자매 프로젝트**. 6개 아키텍처 패턴으로 정형화. ★2.6k. Apache-2.0.

## 자기소개 (원문 발췌)
> "Harness is a team-architecture factory for Claude Code. Say 'build a harness for this project' (English) or '하네스 구성해줘' (한국어), and the plugin turns your domain description into an agent team and the skills they use — picked from six pre-defined team-architecture patterns."

## 우리 프로젝트와의 관련성
**핵심 가치**: ⭐ **harness-factory와 가장 직접 비교 대상** ⭐
- 같은 L3 Meta-Factory 카테고리
- 같은 한국어 트리거
- 같은 Claude Code 기반
- 하지만 다른 sub-layer로 자기 위치 정립함 (L3/Team-Architecture Factory)

## 6가지 아키텍처 패턴 (전체)

| # | 패턴 | 용도 |
|---|---|---|
| 1 | **Pipeline** | 순차 처리 |
| 2 | **Fan-out / Fan-in** | 병렬 분산 → 통합 |
| 3 | **Expert Pool** | 전문가 그룹 중 라우팅 |
| 4 | **Producer-Reviewer** | 생성-리뷰 (= Evaluator-Optimizer) |
| 5 | **Supervisor** | 감독자 + 워커 |
| 6 | **Hierarchical Delegation** | 계층적 위임 |

→ **우리는 Producer-Reviewer 1개 (PGE)만 사용 중**. v2에서 6패턴 중 사용자 선택형으로 확장 가능성.

## L3 Meta-Factory 분류 (revfactory가 정의한 분류 체계)

| Layer | 정의 | 대표 |
|---|---|---|
| L3 / Team-Architecture Factory | 도메인 → 팀 + 스킬, 6패턴 | **revfactory/harness** |
| L3 / Runtime-Configuration Factory | 결정론적 런타임 설정 | coleam00/Archon |
| L3 / Codex Runtime Port | Codex용 동일 컨셉 | SaehwanPark/meta-harness |
| L2 / Cross-Harness Workflow | 다중 하네스 표준화 | affaan-m/everything-claude-code |

→ **이 분류에 따르면 우리도 L3 / Team-Architecture Factory**. 하지만 우리는 PGE 1패턴만 → "더 미니멀"이 차별점.

## 핵심 차용 가능 요소

### 1. **6패턴 분류 체계**
→ 우리 룰에 명시 안 된 패턴들 (Fan-out/Fan-in, Expert Pool, Hierarchical) 추가 검토

### 2. **Harness Evolution Mechanism**
> "When a generated harness is used in a real project, the `/harness:evolve` skill captures the delta between the initial architecture and the shipped one, and feeds it back into the factory so the next generation for a similar domain starts closer to the shipped state."

→ **우리 harness-upgrade의 강력한 변형**. "사용 후 피드백을 다음 세대로" 학습 메커니즘. v2 검토 가치.

### 3. **6단계 Workflow**
```
Phase 1: Domain Analysis
Phase 2: Team Architecture Design (Agent Teams vs Subagents)
Phase 3: Agent Definition Generation (.claude/agents/)
Phase 4: Skill Generation (.claude/skills/)
Phase 5: Integration & Orchestration
Phase 6: Validation & Testing
```
→ 우리 PGE 3단계보다 더 정형화. **v2의 단계 명명에 차용 가능**.

### 4. **i18n (다국어 트리거)**
- "build a harness for this project" (EN)
- "하네스 구성해줘" (KO)
- "ハーネスを構成して" (JA)

→ 우리 v2도 다국어 트리거 패턴 차용 가치.

### 5. **with-skill vs without-skill 비교 테스트**
- 검증 패턴
- → 우리 auditor에 A/B 비교 검수 추가 검토

## 우리와의 차이점

| 항목 | revfactory/harness | 우리 (harness-factory) |
|---|---|---|
| 패턴 | 6개 (Pipeline, Fan-out, Expert, Producer-Reviewer, Supervisor, Hierarchical) | 1개 (PGE = Producer-Reviewer) |
| 분류 | L3 Team-Architecture Factory | L3 (sub-layer 미명시) |
| Evolution | `/harness:evolve` 자동 학습 | `/harness-upgrade` (수동 patch) |
| 다국어 | EN/KO/JA | KO 위주 |
| Marketplace | Claude Code marketplace 등록 | 아직 (로컬만) |

## /harness-upgrade가 참조해야 할 시점
- **분기 갱신**: revfactory의 새 패턴 추가/변경 추적
- **v2 redesign**: 6패턴 중 어느 것을 우리가 추가 지원할지 결정
- **rules-updater**: L3 분류 체계 우리 룰에 명시 검토
- **/harness-upgrade 자체 진화**: Evolution Mechanism 차용 검토

## 핵심 인용 (2026-05-03 기준)
> "Harness lives at the L3 Meta-Factory layer of the Claude Code ecosystem — the layer that generates other harnesses rather than being one."
>
> "Different sub-layers of the same L3. Pick Archon for runtime determinism, Harness for team architecture, or combine them."

## 우선순위 액션
1. **6패턴 정의 정독** — 우리 1패턴이 충분한지 검증 (1순위)
2. **`/harness:evolve` 메커니즘 분석** — 우리 upgrade 진화 모델
3. **L3 sub-layer 분류 우리 룰에 추가** — 자기 위치 명확화
4. **with-skill vs without-skill 검수 패턴** — auditor 강화
5. **분기별 ★수 추적** — 직접 경쟁 동향
