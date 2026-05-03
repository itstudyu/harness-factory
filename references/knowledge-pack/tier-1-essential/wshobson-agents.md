---
name: wshobson-agents
tier: 1
stars: 34600
url: https://github.com/wshobson/agents
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
---

# wshobson/agents

## 한 줄
Claude Code용 멀티에이전트 오케스트레이션의 **사실상 표준** — 80개 plugin / 185 agent / 153 skill / 16 orchestrator / 100 command. ★34.6k.

## 자기소개 (원문 발췌)
> "A comprehensive production-ready system combining 185 specialized AI agents, 16 multi-agent workflow orchestrators, 153 agent skills, and 100 commands organized into 80 focused, single-purpose plugins."
>
> "Average 3.6 components per plugin (follows Anthropic's 2-8 pattern)"

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 harness-factory 5에이전트가 **세계 최대 Claude Code 에이전트 컬렉션과 어떻게 다른가** 비교. 우리 architect/generator/auditor가 wshobson의 어떤 패턴에 매핑되는지 즉시 확인 가능.

## 핵심 차용 가능 요소

### 1. **Plugin 단위 설계 — Anthropic 2-8 컴포넌트 패턴**
- 각 plugin = "1-10개 컴포넌트의 단일 목적 묶음"
- 평균 3.6 컴포넌트/plugin
- → 우리도 v2에서 plugin 단위로 재구성 검토 (현재는 단일 거대 스킬)

### 2. **PluginEval — 품질 평가 프레임워크 (NEW)**
3계층 평가:
- Static analysis (즉시)
- LLM judge (의미)
- Monte Carlo simulation (통계)

10가지 품질 차원:
1. Triggering accuracy (자동 호출 정확도)
2. Orchestration fitness
3. Output quality
4. Scope calibration
5. Progressive disclosure
6. Token efficiency
7. Robustness
8. Structural completeness
9. Code template quality
10. Ecosystem coherence

품질 배지: Platinum (★★★★★) / Gold (★★★★) / Silver (★★★) / Bronze (★★)

**Anti-pattern detection**:
- OVER_CONSTRAINED, EMPTY_DESCRIPTION, MISSING_TRIGGER
- BLOATED_SKILL, ORPHAN_REFERENCE, DEAD_CROSS_REF

→ **우리 harness-auditor의 12+1 rubric을 이 10차원으로 교체 검토**. 더 표준화됨.

### 3. **3-tier 모델 전략**
- Opus 4.7 / Sonnet 4.6 / Haiku 4.5 hybrid orchestration
- → 우리도 planner=opus, generator=sonnet, evaluator=haiku 분리 검토

### 4. **"Install only what you need" 철학**
- Plugin 설치 = 그 plugin의 agent/command/skill만 컨텍스트에 로드
- Marketplace 추가 ≠ 모든 것 로드
- → 우리 harness-rules.md §5 "Context window가 1차 제약"의 실전 적용

### 5. **Plugin vs Agent 구분 명확화**
```
✅ /plugin install javascript-typescript@claude-code-workflows
❌ /plugin install typescript-pro  # agent는 직접 설치 불가
```

## 우리와의 차이점

| 항목 | wshobson/agents | 우리 (harness-factory) |
|---|---|---|
| 단위 | Plugin (수십~수백) | Skill (3개) + Agent (5개) |
| 목적 | **사용자가 쓰는 도메인 에이전트** | **새 하네스를 만드는 메타도구** |
| 평가 | PluginEval 자동 | 수동 (auditor 12+1) |
| 모델 | 3-tier hybrid | 모두 opus |

## /harness-upgrade가 참조해야 할 시점
- **rules-updater 갱신 시**: PluginEval 10차원을 우리 12+1 rubric에 통합 검토
- **신규 워커 추가 시** (v2): 유사 도메인 에이전트가 wshobson에 있는지 확인 → 중복 방지
- **anti-pattern 검수 시**: 6가지 anti-pattern을 우리 검수 기준에 추가

## 핵심 인용 (2026-05-03 기준 README)
> "Each plugin is completely isolated with its own agents, commands, and skills"
> "Minimal token usage — No unnecessary resources loaded into context"
> "Mix and match — Compose multiple plugins for complex workflows"

## 우선순위 액션
1. **PluginEval 프레임워크 도입** — auditor 재설계의 핵심 모델
2. **Anthropic 2-8 컴포넌트 패턴 검증** — 우리 단일 스킬 분해 근거
3. **3-tier 모델 전략** — v2에서 모델 비용 최적화
4. **분기별 ★수 추적** — 생태계 영향력 추이
