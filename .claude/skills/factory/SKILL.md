---
name: factory
description: "harness-factory 메인 진입점. /factory <요구>로 새 작업 시작. planner가 한국어로 100% 유저 합의 후 commander에 인계, commander가 워커들에게 격리된 sub-agent 컨텍스트로 위임. /factory --todos로 오늘/내일 할 일 표시."
when_to_use: 사용자가 새 기능 추가, 버그 수정, 리팩토링, 또는 '오늘/내일 할 일'을 요청할 때
allowed-tools: Agent, Read, Glob, Grep, Bash, AskUserQuestion
model: opus
---

# /factory — harness-factory 메인 진입점

## 트리거

```
/factory <자연어 요구>      새 작업 시작
/factory --todos            오늘/내일 할 일 표시
```

## 워크플로 (--todos 아닐 때)

### Step 1. Planner 호출

```
Agent(
  description="새 작업 계획",
  subagent_type="planner",
  prompt="<유저의 자연어 요구>"
)
```

planner가:
1. 코드베이스 탐색
2. references/knowledge-pack/INDEX.md 자동 참조 (모호 시)
3. AskUserQuestion으로 100% 합의
4. `.hfx/tickets/active/YYYY-MM-DD-<slug>/plan.md` 작성 (status: ready)

### Step 2. Commander 호출

planner 종료 후 즉시:

```
Agent(
  description="계획 실행",
  subagent_type="commander",
  prompt="@.hfx/tickets/active/<ticket-id>/plan.md 의 계획을 실행해줘"
)
```

commander가:
1. plan.md 읽고 status.md 생성
2. workers/ 스캔, task 매칭
3. 각 task → Agent로 워커 호출 (병렬/순차)
4. artifacts/ 저장, status: done
5. `done/`으로 이동, 유저에게 한국어 보고

## --todos 모드

```bash
ls .hfx/tickets/active/*/status.md
ls .hfx/tickets/backlog/*/plan.md
grep "^$(date +%Y-%m-%d)" .hfx/log.md
```

출력:
```
## 📋 오늘 (YYYY-MM-DD)

### 진행 중
- [ ] <ticket-id> (<status>, <progress>)

### 오늘 한 일
- HH:MM <action>

## 📅 내일 (backlog)
- <ticket-id> (priority)
```

## 워커 없음 처리

commander가 적합 워커 못 찾으면:
1. 유저에게 보고: "이 task에 맞는 워커가 없습니다."
2. 빠른 시작 안내: "`.claude/agents/workers/example-worker.md` 를 복사해서 새 워커를 만들어보세요. 4섹션(Core Identity / Self-Verification / Negative Space / Output Format)을 도메인에 맞게 수정하시면 됩니다."
3. 도메인별 참조: `references/knowledge-pack/tier-1-essential/voltagent-subagents.md` (131+ 워커 사례)
4. 사용자가 `.claude/agents/workers/<new>.md` 추가
5. `/factory <원래 요구>` 재실행

## 실패 시

- planner 실패: 즉시 유저 보고, 티켓 미생성
- commander 실패: status: blocked, 유저 보고
- 워커 실패: commander가 즉시 유저 보고 (재시도 X)

## 활동 로그

모든 작업은 `.hfx/log.md`에 append-only로 기록 (commander가 자동 처리).

## 원칙

`@references/principles.md` — Karpathy 4원칙 무조건 준수.
