---
last_updated: "2026-04-16"
version: "2.2.0"
sources:
  - https://www.anthropic.com/engineering/managed-agents
  - https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
  - https://www.anthropic.com/research/building-effective-agents
  - https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/hooks
  - https://code.claude.com/docs/en/skills
  - https://code.claude.com/docs/en/best-practices
  - https://mitchellh.com/writing/my-ai-adoption-journey
  - https://lilianweng.github.io/posts/2023-06-23-agent/
  - https://code.claude.com/docs/en/agent-teams
  - https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills
  - https://claude.com/blog/building-agents-with-the-claude-agent-sdk
  - https://www.anthropic.com/engineering/code-execution-with-mcp
notes: |
  2.2.0 (2026-04-16): 14개 URL 전수 재검증. Hooks 4종 핸들러·신규 이벤트, Sub-agent 신규 필드 8종, Skills Agent Skills 오픈 표준화·신규 필드, Caching automatic/1h TTL, Agent Teams plan approval·task locking, Best Practices /rewind·auto mode·plugins 반영.
  2.1.0 (2026-04-14): 새 공식 출처 4종 추가 — Agent Teams, Agent Skills Engineering Blog, Claude Agent SDK, Code Execution with MCP.
  2.0.0 (2026-04-13): 7개 URL 원문 대조 후 재작성. 출처 미확인 수치/메타포 제거.
---

# Harness Design Rules

각 항목 끝의 `[n]`은 하단 "출처" 각주 번호.

## 1. 아키텍처 원칙

- **3계층 가상화 — Session / Harness / Sandbox.** "We virtualized the components of an agent: a session (the append-only log), a harness (the loop that calls Claude and routes tool calls), and a sandbox." 각 계층은 독립 교체 가능. [1]
- **Brain / Hands 분리.** "brain (Claude and its harness)"과 "hands (sandboxes and tools)"를 구조적으로 분리. 인증 정보는 brain 측에 보관하고 sandbox로는 프록시로만 노출. [1]
- **Workflow vs Agent 구분.** Workflow는 정해진 경로를 따르고 Agent는 스스로 경로를 결정한다. "Start with the simplest solution possible, and only increase complexity when needed." [3]
- **Augmented LLM이 빌딩 블록.** Retrieval + Tools + Memory를 갖춘 LLM이 기본 단위. 도구 정의·문서화는 prompt engineering만큼 신중해야 한다. [3]
- **Sprint 단위 작업.** "Don't try to 'draw the owl' in one mega session." 세션을 명확한 경계의 작업으로 분해. [9]

## 2. 에이전트 설계 규칙

- **에이전트 능력의 최소 집합**: 파일 읽기, 프로그램 실행, HTTP 요청, 그리고 "a way to verify its work"(검증 피드백). "If you give an agent a way to verify its work, it more often than not fixes its own mistakes." [9]
- **ReAct 루프 — Thought / Action / Observation.** 모든 사이클에서 관찰을 기반으로 다음 행동을 결정. 관찰 없는 연속 행동 금지. [10]
- **공식 Agent Loop: gather context → take action → verify work → repeat.** Claude Agent SDK가 공식화한 3단계 피드백 사이클. [13]
- **Evaluator-Optimizer 패턴.** "One LLM call generates a response while another provides evaluation and feedback in a loop." 코드 생성과 코드 리뷰는 별도 에이전트. [3]
- **Orchestrator-Workers 패턴.** "A central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results." 하네스 메인 스킬이 오케스트레이터, 서브에이전트가 워커. [3]
- **Sub-agents vs Agent Teams 선택 기준.** Sub-agent는 "focused tasks where only the result matters" — main agent로만 보고. Agent Team은 "complex work requiring discussion and collaboration" — teammate끼리 직접 통신. PGE 같은 sequential 루프에는 sub-agent, 다각도 리뷰/경합 가설 탐색에는 team. [11]
- **역할별 도구 접근 제어.** Planner에는 `disallowedTools: Edit` + Write 대상을 훅으로 `.nova/contracts/` 한정. Generator에는 `permissionMode: acceptEdits` + (필요 시) `isolation: worktree`. Evaluator에는 `disallowedTools: Write, Edit`. **`permissionMode: plan`은 읽기 전용 탐색 모드**이므로 Bash가 필요한 Evaluator에는 쓰지 말 것. [5]
- **Negative Space 섹션 필수.** 공식 Claude Code frontmatter에 `role` 필드는 없으므로 PGE 역할은 description의 `[planner]` / `[generator]` / `[evaluator]` 태그로 표기. [5]
- **Sub-agent로 연구/탐색/리뷰 위임.** 메인 세션 컨텍스트를 보호한다. Sub-agent는 "returns only the summary". 빌트인 sub-agent 3종: **Explore** (Haiku, 읽기 전용), **Plan** (모델 상속, 읽기 전용), **General-purpose** (전체 도구). [5]
- **세션 종료 계약.** 머지 가능한 코드, 서술적 커밋, 다음 세션을 위한 명확한 산출물. [1][9]

## 3. 스킬 / 프롬프트 설계 규칙

- **Progressive Disclosure.** "Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable." 3단계 — Level 1 (metadata: name+description), Level 2 (SKILL.md 본문), Level 3+ (외부 참조 파일). "Like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix." [12]
- **Skill 설계 3원칙.** (a) *Start with evaluation* — 실제 태스크에서 에이전트가 막히는 지점을 관찰, (b) *Structure for scale* — SKILL.md가 비대해지면 별도 파일로 분리 + mutually-exclusive 컨텍스트 분리, (c) *Think from Claude's perspective* — `name`과 `description`이 자동 호출의 트리거이므로 특별 주의. [12]
- **CLAUDE.md 간결성 테스트.** 각 줄에 대해 "이 줄을 삭제하면 실수가 생기는가?" 묻고 아니면 삭제. "Bloated CLAUDE.md files cause Claude to ignore your actual instructions." [8]
- **검증 기준이 최고 레버리지.** "Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do." [8]
- **Explore → Plan → Code → Commit.** 탐색과 실행을 분리. 큰 기능은 Plan Mode로 계획 후 새 세션에서 실행. [8]
- **Spec-Driven Development.** 큰 기능은 SPEC.md를 먼저 작성하고 clean context 새 세션에서 구현. [8]
- **Skill 위치 규약.** `.claude/skills/<name>/SKILL.md`. 파괴적 슬래시 커맨드는 `disable-model-invocation: true`로 사용자 수동 호출만 허용. SKILL.md는 500라인 이하 권장. Skills는 Agent Skills 오픈 표준(agentskills.io)을 따른다. [7][12]
- **Tool 설계가 우선순위 1.** "Tools are prominent in Claude's context window, making them the primary actions Claude will consider." 도구는 primary, high-frequency operation으로 설계. [13]
- **Code as Output.** 복잡하고 재사용 가능한 작업은 자연어 도구 호출 대신 코드 생성으로 표현. "Code is precise, composable, and infinitely reusable." [13][14]

## 4. 에러 처리 & 복구

- **2회 수정 실패 → 컨텍스트 리셋.** "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches." `/rewind`로 이전 상태 복원을 먼저 시도하고, 그래도 안 되면 `/clear`로 fresh start. [8]
- **Stop 루프 방지.** Stop hook이 재진입할 때 `stop_hook_active` 플래그를 확인. [6]
- **실패 이력 보존.** 실패 로그·원인·시도한 해결책을 파일에 기록.
- **세션 시작 시 상태 검증.** 진행 로그·git 히스토리·기본 테스트로 이전 세션의 가정을 재확인.
- **Agent team은 연구·리뷰부터.** "Start with research and review" — PR 리뷰, 라이브러리 조사, 버그 조사. 경계가 불분명한 병렬 구현은 file conflict 위험. [11]

## 5. 성능: 캐싱 & 컨텍스트 관리

- **Context window가 1차 제약.** "Claude's context window fills up fast, and performance degrades as it fills." Context는 비워두는 것이 기본. [8]
- **5가지 관리 패턴**: (a) CLAUDE.md 정적 지식, (b) 필요 시 로드(JIT), (c) `/clear`·`/compact <지시>`·`/rewind`·`/btw`, (d) sub-agent 격리, (e) 파일시스템을 외부 메모리로. [8][13]
- **Context Management in Agent SDK**: (a) 파일시스템 구조를 "a form of context engineering"으로 활용, (b) 초기엔 vector embedding보다 `grep`/`tail` 기반 agentic search 선호, (c) sub-agent로 병렬화 + 대형 context 격리, (d) 토큰 임계 근접 시 자동 compaction. [13]
- **Code Execution with MCP로 토큰 절감.** MCP 도구를 모델 context에 직접 로드하지 않고 `./servers/<name>/` 식 파일 시스템 구조로 노출 → 필요한 것만 on-demand 로드. 한 사례: 10,000행 스프레드시트를 전부 노출하는 대신 코드에서 필터링 → **150,000 → 2,000 토큰 (98.7% 절감)**. [14]
- **Privacy-preserving intermediate results.** 중간 결과는 실행 환경에만 머물고 명시적으로 로그·반환된 것만 모델로 전달. [14]
- **Prompt caching 계층.** Cache prefixes는 `tools → system → messages` 순서. 도구 정의가 바뀌면 전체 캐시 무효화 → 도구 목록은 고정. Breakpoint 최대 4개, 자동 lookback window 20 블록. [4]
- **캐시 비용.** 읽기 = 기본 입력가 × 0.1, 5분 TTL 쓰기 = × 1.25, 1시간 TTL 쓰기 = × 2. Automatic caching(`cache_control` request-level)으로 multi-turn 대화 시 breakpoint를 자동 전진시킬 수 있다. 모델별 최소 캐시 토큰: Opus 4.6/4.5/Haiku 4.5 = 4096, Sonnet 4.6/Haiku 3.5/3 = 2048, Sonnet 4.5/Opus 4.1/4/Sonnet 4/3.7 = 1024. [4]
- **Agent team 토큰 비용.** 각 teammate는 독립 context window → 토큰 사용이 선형으로 증가. 3–5명이 대부분 워크플로우의 스윗스팟, teammate당 5–6개 태스크. [11]

## 6. 안티패턴

**아키텍처**
- 단일 컨테이너에 harness + 상태 + 인증을 결합 (교체 불가) [1]
- Context window를 1차 저장소로 사용 (휘발성 메모리에 영구 데이터)
- 모든 MCP 도구 정의를 세션 시작 시 로드 → context bloat, intermediate 결과 왕복 [14]

**프롬프트 / 스킬**
- Kitchen sink 세션: 무관한 태스크를 한 프롬프트에 혼합 → `/clear` [8]
- CLAUDE.md 과대화 (지시 희석) [8]
- Trust-then-verify gap: 검증 수단 없이 "잘 동작함" [8]
- Skill의 `description`을 단서 없이 짧게 → 자동 트리거 실패 [12]
- 과잉 명세 연쇄 (유연성 상실)

**에이전트**
- 자기 평가 편향 (Generator가 자신의 코드를 리뷰) [1][3]
- 조기 완료 선언 (테스트 미실행 상태에서 "완료")
- 무한 탐색 ("investigate" 지시를 스코핑 없이) [8]
- Agent team에서 teammate끼리 같은 파일 편집 → overwrite [11]
- Team lead가 teammate 작업 대기 없이 직접 구현 시작 [11]

**운영**
- 채팅 인터페이스로 대규모 코딩 시도
- 메가세션 (한 세션에서 모든 것을 해결) [9]
- 전체 자동 승인으로 안전장치 건너뛰기 — `--permission-mode auto`(classifier 기반)가 중간 대안 [8]

## 7. 파일 형식 규약

### 에이전트 (.claude/agents/*.md) — 공식 frontmatter만 사용 [5]

```yaml
---
name: kebab-case
description: "[planner|generator|evaluator] 한국어 설명"
tools: Read, Glob, Grep, Bash
disallowedTools: Edit
model: opus            # sonnet | opus | haiku | full ID | inherit
maxTurns: 30
permissionMode: default # default | acceptEdits | auto | dontAsk | bypassPermissions | plan
isolation: worktree    # 선택. 대상이 현재 repo일 때만 의미 있음
skills: []             # 선택. 스킬 전체 내용을 startup에 프리로드
memory: project        # 선택. user | project | local → MEMORY.md 자동 생성
background: false      # 선택. 백그라운드 태스크로 실행
effort: high           # 선택. low | medium | high | max (Opus 4.6 only)
---
```

Body 필수 섹션: 핵심 정체성, 핵심 원칙, Negative Space, 자기검증, 산출물 형식, 에스컬레이션.
**주의:** `role` 필드는 Claude Code 공식 스펙에 없다. 역할 표시는 description 태그로.
**참고:** `Task` 도구는 v2.1.63에서 `Agent`로 리네임됨. 기존 `Task(...)` 참조는 alias로 동작. [5]

### 스킬 (.claude/skills/<name>/SKILL.md) [7][12]

```yaml
---
name: skill-name
description: 한국어 설명 (자동 로드 판단용. description+when_to_use 합산 1,536자 이내 front-load)
when_to_use: 트리거 조건 추가 설명  # 선택. description에 합산
disable-model-invocation: true   # 파괴적 / 수동 호출 전용
user-invocable: true             # false → / 메뉴에서 숨김, Claude만 호출
allowed-tools: Bash(git *) Read  # 선택
context: fork                    # 선택. 격리된 sub-agent에서 실행
agent: Explore                   # 선택. context:fork 시 사용할 sub-agent 타입
paths: "src/**/*.ts"             # 선택. glob 패턴, 매칭 파일 작업 시만 자동 활성화
hooks: {}                        # 선택. 스킬 라이프사이클 훅
---
```

사용 가능한 문자열 치환: `$ARGUMENTS`, `$ARGUMENTS[N]`/`$N`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_SKILL_DIR}`.
Progressive disclosure: SKILL.md 500라인 초과 시 별도 파일로 분리.

### 훅 — 4종 핸들러 [6]

**command** (shell): 기존 bash/python 스크립트. stdin JSON 입력, exit code로 제어.
**http**: POST로 endpoint 호출. 2xx = 통과, 비-2xx = non-blocking error, decision JSON으로 차단.
**prompt**: LLM 평가. prompt 템플릿 + model 필드.
**agent**: Sub-agent 검증. model 필드 선택 가능.

```bash
#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)   # 입력은 stdin JSON. $TOOL_INPUT_FILE_PATH는 존재하지 않는다.
# 단, $CLAUDE_ENV_FILE은 SessionStart 훅에서 세션 환경변수 영속에 사용 가능.
# 기타 공식 env: $CLAUDE_PROJECT_DIR, ${CLAUDE_PLUGIN_ROOT}
# Exit codes: 0=proceed, 2=block with stderr feedback. 기타 exit는 non-blocking error.
```

**PreToolUse 확장**: `updatedInput`으로 도구 입력을 실행 전 수정 가능 (allow/deny 외 제3옵션). [6]

### Agent Teams (실험적) [11]

`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 설정 시 활성화 (v2.1.32+). Lead 1 + Teammates N + 공유 task list(dependency 지원) + mailbox. Teammate 정의는 sub-agent definition 재사용 가능 (단 `skills`·`mcpServers` frontmatter는 적용되지 않음). 표시 모드: in-process(기본) 또는 split-pane(tmux/iTerm2 필요). Teammate에게 plan approval을 요구할 수 있다. 훅: `TeammateIdle`, `TaskCreated`, `TaskCompleted`. [11]

---

## 출처

1. Anthropic Engineering, *Managed Agents* — https://www.anthropic.com/engineering/managed-agents
2. Anthropic Engineering, *Effective Harnesses for Long-Running Agents* — https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
3. Anthropic Research, *Building Effective Agents* — https://www.anthropic.com/research/building-effective-agents
4. Anthropic, *Prompt Caching* — https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
5. Claude Code Docs, *Sub-agents* — https://code.claude.com/docs/en/sub-agents
6. Claude Code Docs, *Hooks* — https://code.claude.com/docs/en/hooks
7. Claude Code Docs, *Skills* — https://code.claude.com/docs/en/skills
8. Claude Code Docs, *Best Practices* — https://code.claude.com/docs/en/best-practices
9. Mitchell Hashimoto, *My AI Adoption Journey* — https://mitchellh.com/writing/my-ai-adoption-journey
10. Lilian Weng, *LLM Powered Autonomous Agents* — https://lilianweng.github.io/posts/2023-06-23-agent/
11. Claude Code Docs, *Orchestrate teams of Claude Code sessions* — https://code.claude.com/docs/en/agent-teams
12. Anthropic, *Equipping agents for the real world with Agent Skills* — https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills (redirect from `www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills`)
13. Anthropic, *Building agents with the Claude Agent SDK* — https://claude.com/blog/building-agents-with-the-claude-agent-sdk (redirect from `www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk`)
14. Anthropic Engineering, *Code execution with MCP: building more efficient AI agents* — https://www.anthropic.com/engineering/code-execution-with-mcp
