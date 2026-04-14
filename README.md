# harness-factory

새 프로젝트를 위한 Claude Code 하네스 구조(에이전트, 스킬, 훅)를 자동 생성하는 메타-하네스.

## 개요

harness-factory는 유저가 원하는 하네스 구성을 말하면, 팩트 기반으로 하네스 구조를 설계/생성/검증하는 도구이다. **Orchestrator-Workers + Evaluator-Optimizer** 패턴 (Anthropic: *Building Effective Agents*) 을 따른다.

검증된 설계 원칙(Anthropic 공식 문서, Mitchell Hashimoto, Lilian Weng 등)을 `references/harness-rules.md`로 압축하고, 매 세션 `CLAUDE.md`의 `@import`로 로드된다. SessionStart hook은 본문이 아닌 **해시·갱신일만** 주입해 prompt cache를 보호한다.

## 구조

```
harness-factory/
├── .claude/
│   ├── agents/
│   │   ├── harness-architect.md     # [planner]   구조 설계
│   │   ├── harness-generator.md     # [generator] 파일 생성
│   │   └── harness-auditor.md       # [evaluator] 검증
│   ├── hooks/
│   │   ├── inject-harness-rules.sh  # SessionStart: 메타데이터만 주입
│   │   ├── enforce-planner-write.sh # PreToolUse: Planner Write 경로 강제
│   │   └── validate-generated.sh    # PostToolUse: stdin JSON 기반 검증
│   ├── skills/
│   │   ├── harness-factory/SKILL.md # 메인 Orchestrator 스킬
│   │   └── rules-updater/SKILL.md   # references/rules 갱신 스킬
│   ├── settings.json                # 팀 공유 (checked-in)
│   └── settings.local.json          # 개인 override (gitignored)
├── references/
│   ├── harness-rules.md             # 설계 원칙 (CLAUDE.md @import)
│   ├── harness-references.md        # URL별 원문 대조 분석
│   └── templates/                   # 생성 템플릿
├── .nova/
│   └── progress.json                # 세션 상태 (retry_count 등)
├── CLAUDE.md
└── README.md
```

## 사용법

### 하네스 생성

```
/harness-factory
```

1. 프로젝트 경로, 기술 스택, 필요한 에이전트 역할 입력
2. harness-architect가 Flipped Interaction으로 명확화
3. 설계 결과 확인 및 승인
4. harness-generator가 모든 파일 생성 (대상이 현재 repo 내부일 때만 worktree isolation)
5. harness-auditor가 12+1항목 rubric으로 검증
6. PASS → 완료 / FAIL → 자동 재시도 (최대 2회)

### 설계 원칙 갱신

```
/rules-updater
```

- 등록된 URL 재fetch로 harness-rules.md 갱신
- 새 trusted URL 추가 / AI가 WebSearch로 최신 article 제안
- 각 규칙에 출처 각주 번호(`[n]`)가 매핑되어야 함

## 공식 스펙 준수

- **Frontmatter**: 에이전트는 Claude Code 공식 필드만 사용 (`role:` 필드 없음 — PGE 역할은 description의 `[planner]/[generator]/[evaluator]` 태그로)
- **Hooks**: 입력은 stdin JSON만 (공식 문서에 `$TOOL_INPUT_FILE_PATH` 같은 환경변수 없음)
- **permissionMode**: Evaluator에 `plan`을 쓰지 않음 (Bash까지 차단됨 — rubric 실행 불가)
- **settings**: 팀 공유는 `settings.json`, 개인은 `settings.local.json` (공식 scope system)

## 설계 원칙 출처

`references/harness-rules.md`의 각 항목은 `[n]` 각주로 아래 출처에 매핑된다.

1. [Anthropic: Managed Agents](https://www.anthropic.com/engineering/managed-agents)
2. [Anthropic: Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
3. [Anthropic: Building Effective Agents](https://www.anthropic.com/research/building-effective-agents)
4. [Anthropic: Prompt Caching](https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching)
5. [Claude Code: Sub-agents](https://code.claude.com/docs/en/sub-agents)
6. [Claude Code: Hooks](https://code.claude.com/docs/en/hooks)
7. [Claude Code: Skills](https://code.claude.com/docs/en/skills)
8. [Claude Code: Best Practices](https://code.claude.com/docs/en/best-practices)
9. [Mitchell Hashimoto: AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)
10. [Lilian Weng: LLM Powered Autonomous Agents](https://lilianweng.github.io/posts/2023-06-23-agent/)
11. [Claude Code: Agent Teams](https://code.claude.com/docs/en/agent-teams)
12. [Anthropic: Equipping Agents with Agent Skills](https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills)
13. [Anthropic: Building Agents with the Claude Agent SDK](https://claude.com/blog/building-agents-with-the-claude-agent-sdk)
14. [Anthropic: Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)

상세 분석·인용·검증 실패 이력: `references/harness-references.md`
