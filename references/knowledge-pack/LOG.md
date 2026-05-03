# Knowledge Pack — Change Log

Append-only. 새 항목은 **위에** 추가. 시간 흐름이 위→아래가 아닌 **아래→위** (최신 우선).

---

## 2026-05-03 — Initial creation (v1.0)

**Operator**: claude-opus-4-7 (1M context)
**Trigger**: 유저 요청 — Tier 1~4 (20개) + 공식 문서 12개 일괄 분석

### Added (32개)

**Tier 1 (4개)**
- `tier-1-essential/awesome-claude-code.md` — ★42.3k
- `tier-1-essential/wshobson-agents.md` — ★34.6k
- `tier-1-essential/anthropics-skills.md` — ★127k
- `tier-1-essential/voltagent-subagents.md` — ★18.9k

**Tier 2 (4개)**
- `tier-2-strong/claude-cookbooks.md` — ★42k
- `tier-2-strong/12-factor-agents.md` — ★19.6k
- `tier-2-strong/claude-agent-sdk-python.md` — ★6.6k
- `tier-2-strong/anthropic-quickstarts.md` — ★16.4k

**Tier 3 (5개)**
- `tier-3-supporting/karpathy-skills.md` — ★107k
- `tier-3-supporting/openai-swarm.md` — ★21k
- `tier-3-supporting/anthropic-courses.md` — ★21k
- `tier-3-supporting/prompt-eng-tutorial.md` — ★35.2k
- `tier-3-supporting/revfactory-harness.md` — ★2.6k

**Tier 4 (7개)**
- `tier-4-inspiration/opencode.md` — ★153.7k
- `tier-4-inspiration/goose.md` — ★43.7k
- `tier-4-inspiration/dspy.md` — ★34.1k
- `tier-4-inspiration/browser-harness.md` — ★9.7k
- `tier-4-inspiration/openharness.md` — ★11.8k
- `tier-4-inspiration/e2b-awesome.md` — ★27.6k
- `tier-4-inspiration/awesome-system-prompts.md` — ★5.8k

**Official Docs (12개)**
- `official-docs/managed-agents.md` — Anthropic engineering [1]
- `official-docs/effective-harnesses.md` — Anthropic engineering [2]
- `official-docs/building-effective-agents.md` — Anthropic research [3]
- `official-docs/prompt-caching.md` — platform.claude.com [4]
- `official-docs/sub-agents.md` — code.claude.com [5]
- `official-docs/hooks.md` — code.claude.com [6]
- `official-docs/skills.md` — code.claude.com [7]
- `official-docs/best-practices.md` — code.claude.com [8]
- `official-docs/agent-teams.md` — code.claude.com [11]
- `official-docs/agent-skills-blog.md` — claude.com/blog [12]
- `official-docs/claude-agent-sdk-blog.md` — claude.com/blog [13]
- `official-docs/code-execution-with-mcp.md` — Anthropic engineering [14]

### Notes

- 모든 자료는 `last_analyzed: 2026-05-03` 기준
- 각 파일은 frontmatter (name, tier, stars, url, last_analyzed) + 본문 통일 형식
- LOG.md 패턴은 [karpathy/llm-wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)에서 차용

### 도출된 핵심 인사이트 (10가지)

1. **PluginEval 10차원**으로 auditor 12+1 rubric 교체 검토 (T1#2)
2. **Two-agent 패턴** 채택 가능성 — 3에이전트 → 2에이전트 (T2#8)
3. **빌트인 sub-agent (Plan/Explore) 활용**으로 추가 감축 (O5)
4. **265줄 → 70~100줄 압축** 압력 (T3#9 Karpathy)
5. **6패턴 vs 1패턴** — Pipeline, Fan-out/Fan-in 추가 검토 (T3#13)
6. **agent/prompt 훅 핸들러 미사용** — auditor를 agent 핸들러로 통합 (O6)
7. **5기둥 framework** 우리 룰 검증틀 (T4#18 OpenHarness)
8. **`paths` + `context: fork`** SKILL.md 필드 미활용 (O7)
9. **자가 진화 vs 사람 검토 — 중간 지점** 재검토 (T4#17)
10. **agentskills.io 호환 명시** 신뢰도 ↑ (T1#3)

### 다음 갱신 트리거

- **분기**: 2026-08-01 (분기 1회 정기)
- **즉시 갱신 필요**: 다음 중 하나 발생 시
  - Anthropic이 새 frontmatter 필드 추가
  - revfactory/harness 패턴 변경
  - anthropics/skills 표준 변경 (agentskills.io)
  - 12 factor 항목 추가/변경
  - 새 ★50k+ 메타하네스 등장
