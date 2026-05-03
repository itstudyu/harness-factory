---
name: agent-teams
type: official-doc
url: https://code.claude.com/docs/en/agent-teams
publisher: Claude Code Docs
rules_citation: "[11]"
status: experimental
flag: CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
min_version: v2.1.32
last_analyzed: 2026-05-03
---

# Agent Teams — Claude Code Docs [11] ⚠️ Experimental

## 한 줄
**실험적 멀티에이전트 팀** — Lead 1 + Teammates N + 공유 task list + mailbox.

## 활성화
```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

## 구조

| 컴포넌트 | 역할 |
|---|---|
| **Lead** | 1명 |
| **Teammates** | N명 |
| **Shared Task List** | dependency 지원 |
| **Mailbox** | teammate끼리 직접 통신 |

## 표시 모드
- **in-process** (기본)
- **split-pane** (tmux/iTerm2 필요)

## Sub-agents vs Agent Teams 선택 기준

| 기준 | Sub-agent | Agent Team |
|---|---|---|
| 용도 | "focused tasks where only the result matters" | "complex work requiring discussion and collaboration" |
| 통신 | main agent로만 보고 | teammate끼리 직접 통신 |
| 토큰 비용 | 낮음 | **선형 증가** (각 teammate가 독립 context window) |
| Sweet spot | 단일 task | 3–5명, teammate당 5–6 태스크 |

## 신규 훅 (Agent Teams 전용)
- `TeammateIdle`
- `TaskCreated`
- `TaskCompleted`

## 주의
- Teammate 정의는 sub-agent definition 재사용 가능
- ⚠️ **`skills`·`mcpServers` frontmatter는 적용 안 됨**
- Teammate에게 plan approval 요구 가능

## 우리 룰 매핑
- §2 "Sub-agents vs Agent Teams 선택 기준" — 직접 인용
- §4 "Agent team은 연구·리뷰부터" — 직접 인용
- §5 "Agent team 토큰 비용" — 직접 인용
- §6 "Agent team에서 teammate끼리 같은 파일 편집" 안티패턴 — 직접 인용
- §7 "Agent Teams (실험적)" 섹션 전체

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: experimental → stable 전환 시
- **v2 redesign**: planner+commander+workers를 Agent Team으로 재구성 가능?
  - Lead = commander
  - Teammates = workers
  - Mailbox = .nova/contracts/ 영속화 대체

## 우리 v2 영향 (검토)
- 현재 PGE는 sub-agent 방식
- Agent Teams 전환 시:
  - ✅ 장점: teammate끼리 직접 통신, 복잡 협업
  - ❌ 단점: 토큰 비용 선형 증가, skills frontmatter 무시
- → **현 시점에서는 sub-agent 유지가 합리적** (cost 효율)
- → 장기 v3에서 재검토

## 우선순위 액션
1. **현재 안 씀 — 실험 단계** (적용 보류)
2. v2.1.32+ 환경에서 토이 프로젝트로 테스트 (분기 1회)
3. stable 전환 시점 모니터링
