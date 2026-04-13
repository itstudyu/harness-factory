---
last_updated: "2026-04-13"
version: "2.0.0"
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
notes: |
  2.0.0: 모든 항목을 원문 대조 후 재작성. 출처 미확인 수치/메타포는 제거. 출처 매핑을 항목별로 명시.
---

# Harness Design Rules

각 항목 끝의 `[n]`은 아래 "출처" 각주 번호.

## 1. 아키텍처 원칙

- **3계층 가상화 — Session / Harness / Sandbox.** "We virtualized the components of an agent: a session (the append-only log), a harness (the loop that calls Claude and routes tool calls), and a sandbox." 각 계층은 독립 교체 가능해야 한다. [1]
- **Brain / Hands 분리.** "brain (Claude and its harness)"과 "hands (sandboxes and tools)"를 구조적으로 분리한다. 인증 정보는 brain 측에 보관하고 sandbox로는 프록시로만 노출한다. [1]
- **Workflow vs Agent 구분.** Workflow는 정해진 경로를 따르고 Agent는 스스로 경로를 결정한다. "Start with the simplest solution possible, and only increase complexity when needed." [3]
- **Augmented LLM이 빌딩 블록.** Retrieval, Tools, Memory를 갖춘 LLM이 기본 단위. 도구 정의·문서화는 prompt engineering만큼 신중해야 한다. [3]
- **Sprint 단위 작업.** "Don't try to 'draw the owl' in one mega session." 세션을 명확한 경계의 작업으로 분해하고 각 단위는 머지 가능한 상태로 종료한다. [9]

## 2. 에이전트 설계 규칙

- **에이전트 능력의 최소 집합**: 파일 읽기, 프로그램 실행, HTTP 요청, 그리고 "a way to verify its work"(검증 피드백). Hashimoto: "If you give an agent a way to verify its work, it more often than not fixes its own mistakes." [9]
- **ReAct 루프 — Thought / Action / Observation.** Weng의 원형 표현. 모든 사이클에서 관찰을 기반으로 다음 행동을 결정. 관찰 없는 연속 행동 금지. [10]
- **Evaluator-Optimizer 패턴.** "One LLM call generates a response while another provides evaluation and feedback in a loop." 코드 생성과 코드 리뷰는 별도 에이전트. [3]
- **Orchestrator-Workers 패턴.** "A central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results." 하네스의 메인 스킬이 오케스트레이터, 서브에이전트가 워커. [3]
- **역할별 도구 접근 제어.** Planner에는 `disallowedTools: Edit` + Write 대상을 훅으로 `.nova/contracts/` 한정. Generator에는 `permissionMode: acceptEdits` + (필요 시) `isolation: worktree`. Evaluator에는 `disallowedTools: Write, Edit`. `permissionMode: plan`은 **읽기 전용 탐색 모드**이므로 Bash 등 실행 도구가 필요한 Evaluator에는 쓰지 말 것. [5]
- **Negative Space 섹션 필수.** 각 에이전트 정의에 "하지 않는 것"을 명시해 범위 무한 확장을 막는다. Claude Code 공식 frontmatter에 `role` 필드는 없으므로 PGE 역할은 description에 `[planner]`/`[generator]`/`[evaluator]` 태그로 표기한다. [5]
- **Sub-agent로 연구/탐색/리뷰 위임.** 메인 세션의 컨텍스트를 보호한다. Sub-agent는 "returns only the summary". [5]
- **세션 종료 계약.** 머지 가능한 코드, 서술적 커밋, 다음 세션을 위한 명확한 산출물 남기기. [1][9]

## 3. 스킬 / 프롬프트 설계 규칙

- **CLAUDE.md 간결성 테스트.** 각 줄에 대해 "이 줄을 삭제하면 실수가 생기는가?" 묻고 아니면 삭제. 과도한 CLAUDE.md는 중요한 지시가 noise에 묻혀 모델이 무시하게 만든다. [8]
- **검증 기준이 최고 레버리지.** "Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do." [8]
- **Explore → Plan → Code → Commit.** 탐색과 실행을 분리한다. 큰 기능은 Plan Mode로 계획 후 새 세션에서 실행한다. [8]
- **Spec-Driven Development.** 큰 기능은 SPEC.md를 먼저 작성하고 clean context의 새 세션에서 구현. [8]
- **Skill은 `.claude/skills/<name>/SKILL.md`로.** 필요 시에만 전문이 로드된다(`SKILL.md`는 500라인 이하 권장). 파괴적 슬래시 커맨드는 `disable-model-invocation: true`로 사용자 수동 호출만 허용. [7]

## 4. 에러 처리 & 복구

- **2회 수정 실패 → 컨텍스트 리셋.** "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run `/clear` and start fresh." 오염된 컨텍스트에서 재시도하지 않는다. [8]
- **Stop 루프 방지.** Stop hook이 재진입할 때는 `stop_hook_active` 플래그를 확인한다. [6]
- **실패 이력 보존.** 실패 로그·원인·시도한 해결책을 파일에 기록해 동일 실패 반복을 막는다.
- **세션 시작 시 상태 검증.** 진행 로그·git 히스토리·기본 테스트로 이전 세션의 가정을 재확인한다.

## 5. 성능: 캐싱 & 컨텍스트 관리

- **Context window가 1차 제약.** "Claude's context window fills up fast, and performance degrades as it fills." Context는 비워두는 것이 기본. [8]
- **5가지 관리 패턴**: (a) CLAUDE.md 정적 지식, (b) 필요 시 로드(JIT 검색), (c) `/clear`·`/compact` 구조화 요약, (d) sub-agent 격리, (e) 파일시스템을 외부 메모리로. [8]
- **Prompt caching 계층.** Cache prefixes는 `tools → system → messages` 순서로 생성된다. 도구 정의가 바뀌면 전체 캐시가 무효화되므로 도구 목록은 고정. Breakpoint 최대 4개, 자동 lookback window는 20 블록. [4]
- **캐시 비용.** 읽기 = 기본 입력가 × 0.1, 5분 TTL 쓰기 = × 1.25, 1시간 TTL 쓰기 = × 2. 모델별 최소 캐시 토큰: Opus 4.6/4.5 = 4096, Sonnet 4.6 = 2048, Sonnet 4.5/Opus 4.1/4/Sonnet 4/3.7 = 1024, Haiku 4.5 = 4096, Haiku 3.5/3 = 2048. [4]

## 6. 안티패턴

**아키텍처**
- 단일 컨테이너에 harness + 상태 + 인증을 결합 (교체 불가) [1]
- Context window를 1차 저장소로 사용 (휘발성 메모리에 영구 데이터)

**프롬프트**
- Kitchen sink 세션: 무관한 태스크를 한 프롬프트에 혼합 → `/clear`로 분리 [8]
- CLAUDE.md 과대화 (지시 희석) [8]
- Trust-then-verify gap: 검증 수단 없이 "잘 동작함" 판단 [8]
- 과잉 명세 연쇄 (유연성 상실)

**에이전트**
- 자기 평가 편향 (Generator가 자신의 코드를 리뷰) [1][3]
- 조기 완료 선언 (테스트 미실행 상태에서 "완료")
- 무한 탐색 ("investigate" 지시를 스코핑 없이) [8]

**운영**
- 채팅 인터페이스로 대규모 코딩 시도
- 메가세션 (한 세션에서 모든 것을 해결) [9]
- 전체 자동 승인으로 안전장치 건너뛰기

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
---
```

Body 필수 섹션: 핵심 정체성, 핵심 원칙, Negative Space, 자기검증, 산출물 형식, 에스컬레이션 조건.
**주의:** `role` 필드는 Claude Code 공식 스펙에 없다. 역할 표시는 description 태그로.

### 스킬 (.claude/skills/<name>/SKILL.md) [7]

```yaml
---
name: skill-name
description: 한국어 설명 (자동 로드 판단용)
disable-model-invocation: true   # 파괴적 / 수동 호출 전용
allowed-tools: Bash(git *) Read  # 선택
---
```

### 훅 — Shell (.claude/hooks/*.sh) [6]

```bash
#!/usr/bin/env bash
set -euo pipefail
INPUT=$(cat)   # 입력은 stdin JSON. $TOOL_INPUT_FILE_PATH 같은 환경변수는 존재하지 않는다.
# Exit codes: 0=proceed, 2=block with stderr feedback. 기타 exit는 non-blocking error.
```

### 훅 — Python (.claude/hooks/*.py) [6]

```python
#!/usr/bin/env python3
# stdin: JSON (session_id, cwd, hook_event_name, tool_name, tool_input, ...)
# stdout: {"hookSpecificOutput": {"hookEventName": "...", "additionalContext": "..."}}
```

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
