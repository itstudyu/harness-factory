# Harness Design References

이 문서는 `harness-rules.md`의 원본 소스 상세 분석을 담는다.
각 섹션 번호는 `harness-rules.md`의 출처 각주 번호 `[n]`과 일치한다.
갱신 시 `/rules-updater` 스킬을 사용한다.

---

## [1] Anthropic: Managed Agents
**URL**: https://www.anthropic.com/engineering/managed-agents

### 검증된 인용
- *"We virtualized the components of an agent: a session (the append-only log of everything that happened), a harness (the loop that calls Claude and routes Claude's tool calls), and a sandbox"*
- *"The solution we arrived at was to decouple what we thought of as the 'brain' (Claude and its harness) from both the 'hands' (sandboxes and tools)"*
- *"We're opinionated about the shape of these interfaces, not about what runs behind them."*

### 성능 수치 (원문 확인)
- p50 TTFT 약 60% 감소, p95 90% 이상 감소 (Lazy provisioning 관련 컨텍스트에서 언급)

### 적용 규칙
- 3계층 가상화 (session / harness / sandbox)
- brain / hands 분리 → 인증 정보 격리
- 도구 인터페이스는 "shape만 고정" — 내부 구현 무관

### 검증 실패 (이전 오류)
- "Evaluator drift 감지, 연속 PASS 10회 임계값" → 본문 없음 (제거)
- "도구 인터페이스 = name+input→string" → 본문에 명시 없음 (제거)

---

## [2] Anthropic: Effective Harnesses for Long-Running Agents
**URL**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

### 검증된 인용
- *"agents need a way to bridge the gap between coding sessions"*
- *"a feature list file... expanded on the user's initial prompt"*
- *"leave clear artifacts for the next session"*

### 실제 구성
- **Initializer agent**: 초기 환경 설정
- **Coding agent**: 점진적 진행
- `claude-progress.txt` + git 히스토리로 세션 간 상태 복구

### 적용 규칙
- 명확한 세션 간 핸드오프 산출물
- 기능 목록 파일 사용 (형식 무관, 현재 rules는 JSON 주장 제거)

### 검증 실패 (이전 오류)
- "Harness=OS, Model=CPU, Context=RAM" 메타포 → 본문 없음 (제거)
- "wake(sessionId) / getEvents()" API → 본문 없음 (제거)
- "TTFT 60-90% 감소" 수치 → 본문이 아닌 Managed Agents에 있음 (이동)

---

## [3] Anthropic: Building Effective Agents
**URL**: https://www.anthropic.com/research/building-effective-agents

### 검증된 인용
- Workflow vs Agent: *"LLMs and tools follow predefined code paths"* vs *"LLMs dynamically direct their own processes and tool usage"*
- Evaluator-Optimizer: *"One LLM call generates a response while another provides evaluation and feedback in a loop"*
- Orchestrator-Workers: *"A central LLM dynamically breaks down tasks, delegates them to worker LLMs, and synthesizes their results"*
- 원칙: *"Start with simple prompts, optimize them with comprehensive evaluation, and add multi-step agentic systems only when simpler solutions fall short."*

### 다섯 가지 프로덕션 패턴
1. Prompt Chaining
2. Routing
3. Parallelization (sectioning / voting)
4. Orchestrator-Workers
5. Evaluator-Optimizer

### 빌딩 블록
- **Augmented LLM** = Retrieval + Tools + Memory
- 도구 문서화는 프롬프트 엔지니어링만큼 중요

### 적용 규칙
- PGE는 Evaluator-Optimizer 패턴에 해당 (Generator ↔ Evaluator 루프)
- harness-factory 스킬은 Orchestrator, 3개 에이전트는 Workers

---

## [4] Anthropic: Prompt Caching
**URL**: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
(이전 `docs.anthropic.com/en/docs/build-with-claude/prompt-caching`은 301로 redirect됨)

### 검증된 수치 (2026-04 기준 공식)
- 캐시 읽기 = 기본 입력가 × 0.1 (= 10%)
- 5분 TTL 쓰기 = × 1.25 (125%)
- 1시간 TTL 쓰기 = × 2.0 (200%)
- 최대 cache breakpoint = 4개
- 자동 lookback window = 20 블록

### 최소 캐시 토큰 (모델별)
- Opus 4.6 / 4.5 / Haiku 4.5: 4096
- Sonnet 4.6 / Haiku 3.5 / Haiku 3: 2048
- Sonnet 4.5 / Opus 4.1 / Opus 4 / Sonnet 4 / Sonnet 3.7: 1024

### Cache prefix 생성 순서
`tools → system → messages` (원문 그대로)

### 적용 규칙
- SessionStart hook은 messages 계층에 주입되므로 rules 본문을 넣으면 캐시가 자주 무효화됨 → 현재는 해시만 주입, 본문은 CLAUDE.md의 `@import`로 system 계층에 포함
- 도구 정의는 세션 중 변경 금지

---

## [5] Claude Code: Sub-agents
**URL**: https://code.claude.com/docs/en/sub-agents

### 공식 지원 frontmatter 필드 (2026-04 기준)
`name` (필수), `description` (필수), `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `memory`, `background`, `effort`, `isolation`, `color`, `initialPrompt`, `hooks`

### permissionMode 값
`default` | `acceptEdits` | `auto` | `dontAsk` | `bypassPermissions` | `plan`
- **`plan`은 read-only exploration** — Bash 등 실행 도구 불가

### 주의
- **`role:` 필드는 공식 스펙에 없음** — 커스텀 필드는 무시됨
- `isolation: worktree`는 대상이 **현재 repo**일 때만 의미 — 변경이 없으면 자동 정리

### 적용 규칙
- PGE 역할은 description 태그로 (`[planner]` / `[generator]` / `[evaluator]`)
- Evaluator에 `permissionMode: plan`을 주지 않는다 — Bash 기반 rubric이 실패

---

## [6] Claude Code: Hooks
**URL**: https://code.claude.com/docs/en/hooks

### 공식 hook 이벤트 (전체 목록)
`SessionStart`, `SessionEnd`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`, `Notification`, `Stop`, `StopFailure`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `TeammateIdle`

### 입력 규약
- **입력은 stdin JSON으로만 전달** — `$TOOL_INPUT_FILE_PATH` 같은 환경변수는 **존재하지 않음**
- 공통 필드: `session_id`, `cwd`, `hook_event_name`, `permission_mode`, `tool_name`, `tool_input`, `tool_response`, `agent_type`, `agent_id`, `transcript_path`

### Exit code 의미
- `0`: 통과 (SessionStart/UserPromptSubmit은 stdout이 context로 주입)
- `2`: 차단 + stderr가 Claude에 피드백
- 기타: non-blocking error (공식 문서 경고: "exit 1은 차단하지 않으므로 정책 시행에는 exit 2 사용")

### 적용 규칙
- bash/python 훅 모두 `cat` / `json.load(sys.stdin)`으로 입력 수신
- PostToolUse에서 file_path가 필요하면 `.tool_input.file_path` 추출

---

## [7] Claude Code: Skills
**URL**: https://code.claude.com/docs/en/skills

### 공식 frontmatter 필드
`name`, `description`, `argument-hint`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context` (`fork`), `agent`, `hooks`, `paths`, `shell`

### 파일 위치 우선순위
Enterprise > Personal (`~/.claude/skills/`) > Project (`.claude/skills/`) > Plugin

### 적용 규칙
- 파괴적 슬래시 커맨드에는 `disable-model-invocation: true`
- SKILL.md는 500라인 이하 권장, 큰 참조 자료는 별도 파일로 분리
- 설명은 앞에 핵심 용도를 두기 — 250자 초과 시 skill 리스트에서 잘림

---

## [8] Claude Code: Best Practices
**URL**: https://code.claude.com/docs/en/best-practices
(`www.anthropic.com/engineering/claude-code-best-practices`는 308로 여기로 redirect)

### 검증된 인용
- *"Include tests, screenshots, or expected outputs so Claude can check itself. This is the single highest-leverage thing you can do."*
- *"Claude's context window fills up fast, and performance degrades as it fills."*
- *"If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches. Run `/clear` and start fresh with a more specific prompt that incorporates what you learned."*
- *"Would removing this cause Claude to make mistakes? If not, cut it."* (CLAUDE.md 간결성 테스트)

### 워크플로우
Explore → Plan → Code → Commit (4단계)

### 적용 규칙
- **2회 실패 후 컨텍스트 초기화** 규칙의 **정식 출처는 여기** (이전에는 Hashimoto로 잘못 매핑되어 있었음)
- CLAUDE.md 간결성 테스트의 출처

---

## [9] Mitchell Hashimoto: My AI Adoption Journey
**URL**: https://mitchellh.com/writing/my-ai-adoption-journey

### 검증된 인용
- *"the agent must have the ability to: read files, execute programs, and make HTTP requests"*
- *"If you give an agent a way to verify its work, it more often than not fixes its own mistakes"*
- *"Break down sessions into separate clear, actionable tasks. Don't try to 'draw the owl' in one mega session"*
- *"Harness Engineering"*: 에이전트 오류마다 재발방지 시스템을 구축

### 적용 규칙
- 최소 4가지 능력 (파일 읽기 / 실행 / HTTP / 검증)
- Sprint 단위 작업
- AGENTS.md / 유사 파일로 세션 간 문서화

### 검증 실패 (이전 오류)
- "Initializer vs Executor 에이전트 분리" → 본문 없음 (제거)
- "Red/Green 테스트 우선" → 본문 없음 (제거)
- "2회 실패 후 컨텍스트 초기화" → 본문 없음. 출처는 [8]로 이동

---

## [10] Lilian Weng: LLM Powered Autonomous Agents
**URL**: https://lilianweng.github.io/posts/2023-06-23-agent/

### 검증된 인용
- ReAct 패턴: *"Thought: ... Action: ... Observation: ... (Repeated many times)"*
- 3대 구성요소: **Planning**, **Memory** (short-term / long-term with MIPS like HNSW/FAISS), **Tool Use**
- Self-reflection: Reflexion, Chain of Hindsight

### 적용 규칙
- ReAct 루프의 **원형**은 Thought-Action-Observation 3단계
- 현재 rules는 5단계(`READ→PLAN→ACT→OBSERVE→CHECKPOINT`) 주장을 철회하고 이 3단계 원형으로 복원

---

---

## [11] Claude Code: Orchestrate teams of Claude Code sessions
**URL**: https://code.claude.com/docs/en/agent-teams

### 검증된 인용
- *"Agent teams let you coordinate multiple Claude Code instances working together. One session acts as the team lead, coordinating work, assigning tasks, and synthesizing results."*
- *"Agent teams are experimental and disabled by default. Enable them by adding `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to your settings.json or environment."*
- Requires Claude Code v2.1.32+

### Sub-agents vs Agent Teams (공식 비교)
|  | Subagents | Agent teams |
|---|---|---|
| Communication | Report to main agent only | Teammates message each other |
| Coordination | Main agent manages | Shared task list, self-coordination |
| Best for | Focused tasks where only the result matters | Complex work requiring discussion |
| Token cost | Lower (summarized back) | Higher (each is separate Claude) |

### Best use cases
- Research and review (여러 teammate가 다각도 투입)
- New modules / features (각자 다른 부분 담당)
- Debugging with competing hypotheses (scientific debate 구조)
- Cross-layer coordination (frontend/backend/tests)

### Architecture 구성요소
| Component | Role |
|---|---|
| Team lead | 메인 세션, 팀 생성·teammate 소환·작업 조율 |
| Teammates | 독립 Claude Code 인스턴스 |
| Task list | 공유 작업 리스트 (pending/in_progress/completed, dependency 지원) |
| Mailbox | 에이전트 간 메시징 |

### 저장 경로
- Team config: `~/.claude/teams/{team-name}/config.json`
- Task list: `~/.claude/tasks/{team-name}/`

### 한계
- In-process teammate는 `/resume`·`/rewind` 복원 안 됨
- Teammate가 task completed 마킹을 놓쳐 의존 task가 막히는 경우 있음
- Lead 승격·변경 불가, nested team 불가, 세션당 1팀
- tmux / iTerm2 없으면 split-pane 불가 (VS Code / Windows Terminal / Ghostty 비지원)

### 적용 규칙
- PGE 같은 sequential 루프는 sub-agent 유지
- 향후 "다각 리뷰 / 경합 가설 조사" 기능 추가 시 agent team 고려

---

## [12] Anthropic: Equipping agents for the real world with Agent Skills
**URL**: https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills
(`www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills`는 308로 redirect)

### 검증된 인용
- *"Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable."*
- *"organized folders of instructions, scripts, and resources that agents can discover and load dynamically to perform better at specific tasks"*
- *"Like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix."*

### Progressive Disclosure 3 레벨
- **Level 1 — Metadata**: `name` + `description`만 startup에 로드
- **Level 2 — Core Context**: 관련 태스크 시 `SKILL.md` 본문 로드
- **Level 3+ — Granular Details**: 필요 시점에만 외부 참조 파일

### Skill 설계 3대 원칙
1. **Start with evaluation** — 실제 태스크에서 에이전트가 막히는 지점을 관찰
2. **Structure for scale** — SKILL.md 비대해지면 별도 파일 분리, mutually-exclusive 컨텍스트 분리
3. **Think from Claude's perspective** — `name`·`description`이 자동 트리거이므로 특별히 관리

### 적용 규칙
- rules 3장에 Progressive Disclosure 추가
- SKILL.md 500라인 이하 권장, 초과 시 분리

---

## [13] Anthropic: Building agents with the Claude Agent SDK
**URL**: https://claude.com/blog/building-agents-with-the-claude-agent-sdk
(`www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk`는 308로 redirect)

### 검증된 인용
- Canonical loop: *"gather context -> take action -> verify work -> repeat."*
- *"giving Claude a computer unlocks the ability to build agents that are more effective than before."*
- *"Tools are prominent in Claude's context window, making them the primary actions Claude will consider."*
- *"Code is precise, composable, and infinitely reusable."*

### Agent Loop 3단계
1. **Gather context** — agentic search via bash, semantic search, subagents, context compaction
2. **Take action** — tools, bash/scripts, code generation, MCP integrations
3. **Verify work** — rules-based feedback (linting), visual feedback, LLM judging

### Context Management 원칙
- 파일시스템 구조를 "a form of context engineering"으로 활용
- 초기엔 vector embedding보다 `grep`/`tail` agentic search 선호
- Sub-agent로 대형 context 격리
- 토큰 임계 근접 시 자동 compaction

### 적용 규칙
- rules 2장에 공식 gather-act-verify 루프 추가
- rules 3장에 "Tools as primary operations"·"Code as Output" 추가
- rules 5장에 agentic search 선호 원칙 추가

---

## [14] Anthropic: Code execution with MCP
**URL**: https://www.anthropic.com/engineering/code-execution-with-mcp

### 검증된 인용
- *"Tool descriptions occupy more context window space, increasing response time and costs."*
- 10,000행 스프레드시트 필터링 사례: *"reducing from 150,000 tokens to 2,000 tokens... a time and cost saving of 98.7%"*

### 핵심 주장
- 모든 MCP 도구 정의를 upfront 로드하면 (a) context bloat, (b) intermediate 결과가 context를 2회 왕복 → 비효율
- 대안: MCP 서버를 code API로 노출 (`./servers/google-drive/getDocument.ts` 같은 파일 구조) → 에이전트가 필요한 것만 탐색·로드

### 하네스 설계 3원칙
1. **Progressive disclosure** — 도구를 upfront 전부가 아니라 on-demand
2. **Privacy-preserving** — 중간 결과는 실행 환경에만, 명시적 반환만 모델로
3. **State persistence** — 중간 결과를 파일로 저장해 resume·재사용

### 적용 규칙
- rules 5장에 Code Execution with MCP 토큰 절감 원칙 추가
- 큰 데이터 처리 도구는 파일 저장 + 요약 반환 패턴 채택

---

## 추가 소스 (미검증 or 보조)

### Simon Willison
주요 URL 2개는 404 응답. 현재 rules에서 제거. 추후 WebSearch로 유효 URL 확인 후 재등록.

### MorphLLM: Agent Engineering Primer
URL·본문 재검증 필요. 현재 rules에는 포함하지 않음.

### Anthropic: 2026 Agentic Coding Trends Report (PDF)
`resources.anthropic.com/hubfs/2026%20Agentic%20Coding%20Trends%20Report.pdf` — 통계·예측 report. 현재 rules에 반영하지 않음 (근거 원칙 중심).

### Anthropic: Building a C compiler with agents
`www.anthropic.com/engineering/building-c-compiler` — 16 agents / 2,000 세션 사례. case study이므로 출처 각주에서 제외.

---

## 신뢰할 수 있는 소스 판단 기준

1. **공식 문서**: anthropic.com, platform.claude.com, code.claude.com, docs.anthropic.com
2. **검증된 개인 블로그**: Mitchell Hashimoto, Simon Willison, Lilian Weng, Andrej Karpathy 등
3. **메이저 AI 기업 엔지니어링 블로그**: OpenAI, Google DeepMind, DeepSeek 공식
4. **피어 리뷰 / 인용 100회 이상 논문**: arXiv
5. **메이저 컨퍼런스 발표**: NeurIPS, ICML, ICLR 등

**제외**: 익명 블로그, 광고성 콘텐츠, 미검증 Twitter 스레드, 3개월 이상 경과한 beta 관련 자료.

---

## 갱신 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2026-04-13 | 초기 작성 — 7개 URL + 2개 추가 소스 분석 |
| 2026-04-13 | v2.0 재검증 — 7개 URL + 공식 hooks/skills/settings 4종 원문 대조 후 오매핑 5건 제거, 출처 각주 시스템 도입 |
| 2026-04-14 | v2.1 — 새 공식 출처 4종 추가: [11] Agent Teams, [12] Agent Skills blog, [13] Claude Agent SDK, [14] Code Execution with MCP. Progressive disclosure / gather-act-verify / code-based orchestration 원칙 rules에 반영 |
