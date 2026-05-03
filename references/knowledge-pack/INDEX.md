# Knowledge Pack — INDEX

harness-factory의 외부 레퍼런스 카탈로그. `/harness-upgrade`가 진단·patch·검수 시 참조하는 1차 자료.

- **last_updated**: 2026-05-03
- **analyst**: claude-opus-4-7
- **purpose**: harness-rules.md의 14개 출처를 보강하는 실전 레퍼런스 + 비교 사례
- **policy**: 분기 1회 갱신 (★수, 새 패턴, deprecated 항목)

## 사용 흐름

```
/harness-upgrade
    │
    ├─ diff-reporter ─── tier-1-essential/* + official-docs/* 우선 참조
    ├─ upgrader     ─── 적용 시 tier-1, tier-2 패턴 비교
    └─ auditor      ─── 검수 시 best practice 대조
```

## Tier 1 — 필수 (★ 합계 222.8k)

| # | 자료 | ★ | 핵심 가치 |
|---|---|---|---|
| 1 | [awesome-claude-code](tier-1-essential/awesome-claude-code.md) | 42.3k | Claude Code 생태계 큐레이션 — 우리 위치 파악 |
| 2 | [wshobson-agents](tier-1-essential/wshobson-agents.md) | 34.6k | 멀티에이전트 오케스트레이션 표준 |
| 3 | [anthropics-skills](tier-1-essential/anthropics-skills.md) | 127k | Agent Skills 공식 표준 + skill-creator |
| 4 | [voltagent-subagents](tier-1-essential/voltagent-subagents.md) | 18.9k | 100+ Claude Code subagent 컬렉션 |

## Tier 2 — 강력 추천 (★ 합계 84.6k)

| # | 자료 | ★ | 핵심 가치 |
|---|---|---|---|
| 5 | [claude-cookbooks](tier-2-strong/claude-cookbooks.md) | 42k | Building Effective Agents 5패턴 코드 |
| 6 | [12-factor-agents](tier-2-strong/12-factor-agents.md) | 19.6k | 원칙 압축 모범 (rules 압축 모델) |
| 7 | [claude-agent-sdk-python](tier-2-strong/claude-agent-sdk-python.md) | 6.6k | 공식 Agent SDK Python |
| 8 | [anthropic-quickstarts](tier-2-strong/anthropic-quickstarts.md) | 16.4k | 공식 quickstart 모음 |

## Tier 3 — 보조 (★ 합계 191.4k)

| # | 자료 | ★ | 핵심 가치 |
|---|---|---|---|
| 9 | [karpathy-skills](tier-3-supporting/karpathy-skills.md) | 107k | CLAUDE.md 4원칙 (단일 파일 극단) |
| 10 | [openai-swarm](tier-3-supporting/openai-swarm.md) | 21k | 멀티에이전트 하한선 |
| 11 | [anthropic-courses](tier-3-supporting/anthropic-courses.md) | 21k | 공식 교육 |
| 12 | [prompt-eng-tutorial](tier-3-supporting/prompt-eng-tutorial.md) | 35.2k | 프롬프트 엔지니어링 |
| 13 | [revfactory-harness](tier-3-supporting/revfactory-harness.md) | 2.6k | 6패턴 정형화 (rules [15] 출처) |

## Tier 4 — 영감 (★ 합계 287.6k)

| # | 자료 | ★ | 핵심 가치 |
|---|---|---|---|
| 14 | [opencode](tier-4-inspiration/opencode.md) | 153.7k | 단일 코딩 에이전트 상한선 |
| 15 | [goose](tier-4-inspiration/goose.md) | 43.7k | 미니멀 에이전트 디자인 |
| 16 | [dspy](tier-4-inspiration/dspy.md) | 34.1k | 프롬프트→프로그래밍 |
| 17 | [browser-harness](tier-4-inspiration/browser-harness.md) | 9.7k | 자가 진화 하네스 |
| 18 | [openharness](tier-4-inspiration/openharness.md) | 11.8k | Claude Code OSS 재구현 |
| 19 | [e2b-awesome](tier-4-inspiration/e2b-awesome.md) | 27.6k | 일반 AI 에이전트 큐레이션 |
| 20 | [awesome-system-prompts](tier-4-inspiration/awesome-system-prompts.md) | 5.8k | 유출 시스템 프롬프트 (벤치마크) |

## 공식 문서 (Anthropic + Claude Code Docs)

| # | 문서 | rules 인용 | 영역 |
|---|---|---|---|
| O1 | [managed-agents](official-docs/managed-agents.md) | [1] | 3계층 가상화 |
| O2 | [effective-harnesses](official-docs/effective-harnesses.md) | [2] | 장기 실행 하네스 |
| O3 | [building-effective-agents](official-docs/building-effective-agents.md) | [3] | 5가지 패턴 |
| O4 | [prompt-caching](official-docs/prompt-caching.md) | [4] | 캐시 계층 |
| O5 | [sub-agents](official-docs/sub-agents.md) | [5] | Sub-agent frontmatter |
| O6 | [hooks](official-docs/hooks.md) | [6] | 4종 훅 핸들러 |
| O7 | [skills](official-docs/skills.md) | [7] | SKILL.md 표준 |
| O8 | [best-practices](official-docs/best-practices.md) | [8] | Explore→Plan→Code |
| O9 | [agent-teams](official-docs/agent-teams.md) | [11] | 실험적 팀 |
| O10 | [agent-skills-blog](official-docs/agent-skills-blog.md) | [12] | Progressive Disclosure |
| O11 | [claude-agent-sdk-blog](official-docs/claude-agent-sdk-blog.md) | [13] | 공식 Agent Loop |
| O12 | [code-execution-with-mcp](official-docs/code-execution-with-mcp.md) | [14] | MCP 토큰 절감 |

## 갱신 정책

- **자동 검사**: SessionStart 훅이 `last_updated`를 보고 90일 초과 시 갱신 제안
- **수동 갱신**: `/harness-upgrade --refresh-knowledge-pack` 명령 (v2에서 추가)
- **이력**: 모든 변경은 [LOG.md](LOG.md)에 append-only 기록

## 색인 — 패턴별 빠른 참조

| 패턴 / 주제 | 1차 자료 |
|---|---|
| Orchestrator-Workers | T2#5 (cookbooks), T1#2 (wshobson), O3 |
| Evaluator-Optimizer | T2#5 (cookbooks), O3 |
| Sub-agent 격리 | O5 (sub-agents), T2#7 (sdk-python) |
| Skill 표준 | T1#3 (anthropics/skills), O7, O10 |
| 훅 4종 | O6 (hooks) |
| Plan Mode | O8 (best-practices), T3#9 (karpathy) |
| Progressive Disclosure | O10, T1#3 |
| Prompt 캐싱 | O4 |
| 12-factor 원칙 | T2#6 |
| 코딩 에이전트 minimal | T4#14 (opencode), T4#15 (goose) |
| 자가 진화 | T4#17 (browser-harness) |
| Code execution MCP | O12 |

## 통계

- **총 32개 자료** (GitHub 20 + 공식 문서 12)
- **총 분석 라인**: ~2,665줄
- **GitHub ★ 합계**: 786.4k (T1~T4)
- **분석 일자**: 2026-05-03 (1회차)
- **다음 갱신 예정**: 2026-08 (분기 1회)

## 핵심 인사이트 (1회차 분석에서 도출)

### 1. **PluginEval 10차원 → auditor 12+1 rubric 교체 후보**
T1#2 (wshobson/agents)의 PluginEval 10차원이 우리 12+1 rubric보다 표준화되고 정량적. 우리 auditor의 다음 갱신에서 통합 검토.

### 2. **Two-agent 패턴 = 우리 PGE 3에이전트 축소 가능 신호**
T2#8 (anthropic-quickstarts)의 Autonomous Coding Agent가 **2에이전트(initializer + coding agent)**로 동작. 우리는 3에이전트(architect + generator + auditor). **하나 줄일 가능성 있음**.

### 3. **혹은 빌트인 sub-agent 활용으로 0~1개로 감축**
O5 (sub-agents)의 빌트인 `Plan` + `Explore`로 우리 architect/auditor 일부 대체 가능.

### 4. **Karpathy의 ★107k가 단일 CLAUDE.md로 가능함을 증명**
T3#9 (karpathy-skills) — 우리 265줄(CLAUDE.md+rules) → 70~100줄 압축 압력.

### 5. **revfactory/harness 6패턴 vs 우리 1패턴**
T3#13 (revfactory/harness)이 6패턴 지원, 우리는 PGE 1패턴. v2에서 패턴 추가 검토 (특히 Pipeline, Fan-out/Fan-in).

### 6. **agent 핸들러 + prompt 핸들러 미사용**
O6 (hooks) — 우리 5개 훅 모두 command 핸들러. agent/prompt 핸들러 활용 시 auditor 통합 가능.

### 7. **HKUDS/OpenHarness의 5기둥 framework**
T4#18 (openharness)의 5기둥(Loop/Toolkit/Memory/Governance/Swarm)이 우리 룰의 정확한 검증틀.

### 8. **`paths` + `context: fork` 활용 부족**
O7 (skills) — 우리 SKILL.md frontmatter에서 `paths`, `context: fork` 같은 신규 필드 미활용.

### 9. **자가 진화 vs 사람 검토 — 균형점 재검토**
T4#17 (browser-harness)는 100% 자가 진화. 우리는 100% 사람 승인. **중간 지점**(예: 위험도별 차등 승인) 검토.

### 10. **anthropics/skills 호환 명시 필요**
T1#3 (anthropics/skills) — agentskills.io 표준 호환을 우리 README에 명시 시 신뢰도 ↑.
