---
name: claude-agent-sdk-python
tier: 2
stars: 6600
url: https://github.com/anthropics/claude-agent-sdk-python
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
related_official_doc: official-docs/claude-agent-sdk-blog.md
---

# anthropics/claude-agent-sdk-python

## 한 줄
Claude Agent SDK의 **공식 Python 구현**. ★6.6k. Claude Code CLI 번들링.

## 자기소개 (원문 발췌)
> "Python SDK for Claude Agent. See the Claude Agent SDK documentation for more information."
>
> "The Claude Code CLI is automatically bundled with the package - no separate installation required!"

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 룰 [13] "Building agents with the Claude Agent SDK"의 **공식 Python 코드**. "gather context → take action → verify work" 사이클 구현 검증.

## 핵심 차용 가능 요소

### 1. **`query()` — 가장 단순한 진입점**
```python
async for message in query(prompt="What is 2 + 2?"):
    print(message)
```
- 단일 함수 호출로 에이전트 실행
- → **우리 v2의 commander가 워커 호출하는 패턴의 표준**

### 2. **`ClaudeAgentOptions` — 핵심 설정 11개**
```python
options = ClaudeAgentOptions(
    system_prompt="...",
    max_turns=1,
    allowed_tools=["Read", "Write", "Bash"],
    disallowed_tools=[...],
    permission_mode='acceptEdits',
    cwd="/path/to/project",
    cli_path="/path/to/claude",
    mcp_servers={...},
    # ...
)
```
→ 우리 agent frontmatter 필드와 거의 1:1 매칭. **우리 frontmatter 표준의 코드 출처**.

### 3. **권한 평가 순서 (공식)**
> "`allowed_tools` is a permission allowlist: listed tools are auto-approved, and unlisted tools fall through to `permission_mode` and `can_use_tool` for a decision. It does not remove tools from Claude's toolset."

순서:
1. `allowed_tools` (auto-approve)
2. `permission_mode` (default/acceptEdits/auto/...)
3. `can_use_tool` (콜백)
4. `disallowed_tools` (block)

→ **우리 enforce-planner-write.sh 훅의 대안**. SDK 레벨에서 이미 권한 제어 가능.

### 4. **`ClaudeSDKClient` — 양방향 대화 + 커스텀 도구/훅**
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("Greet Alice")
    async for msg in client.receive_response():
        print(msg)
```
- bidirectional, interactive
- **custom tools + hooks** 지원 (Python 함수로 정의)

### 5. **In-Process MCP Servers (`@tool` 데코레이터)**
```python
@tool("greet", "Greet a user", {"name": str})
async def greet_user(args):
    return {"content": [{"type": "text", "text": f"Hello, {args['name']}!"}]}

server = create_sdk_mcp_server(name="my-tools", version="1.0.0", tools=[greet_user])

options = ClaudeAgentOptions(
    mcp_servers={"tools": server},
    allowed_tools=["mcp__tools__greet"]
)
```
**장점**:
- No subprocess management
- Better performance (no IPC overhead)
- Simpler deployment
- Easier debugging
- Type safety

→ **우리 룰 §5 "Code Execution with MCP" [14]의 in-process 변형**. 토큰 절감 + 디버깅 용이.

### 6. **`ClaudeAgentOptions(cwd=...)`**
- 작업 디렉토리 명시
- → 우리 워커 isolation의 코드 레벨 구현

## 우리와의 차이점

| 항목 | claude-agent-sdk-python | 우리 |
|---|---|---|
| 형식 | Python 코드 | Markdown agent.md |
| 추상화 수준 | API + CLI 통합 | Claude Code 위에 markdown |
| 실행 환경 | 임의 Python 프로젝트 | Claude Code 세션 안 |
| 도구 정의 | `@tool` 데코레이터 | `.claude/agents/*.md` |

→ 우리 markdown 정의가 SDK Python 코드로 어떻게 매핑되는지 = **두 표현의 등가성** 확인 가능.

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: SDK 신규 옵션/필드 추가 시 우리 frontmatter 표준 갱신
- **generator 검증**: 우리 .md frontmatter가 SDK 옵션과 정합성 유지하는지
- **분기 갱신**: ClaudeAgentOptions 신규 필드 추적

## 핵심 인용 (2026-05-03 기준)
> "Custom tools are implemented in-process MCP servers that run directly within your Python application, eliminating the need for separate processes that regular MCP servers require."

## 우선순위 액션
1. **`src/claude_agent_sdk/query.py` 정독** — query() 내부 로직 (1순위)
2. **`examples/mcp_calculator.py`** — 커스텀 도구 end-to-end
3. **`ClaudeAgentOptions` 전체 필드 목록** — 우리 frontmatter 표준 갱신
4. **권한 평가 순서 4단계** — 우리 enforce-* 훅 단순화 근거
5. **TypeScript SDK도 함께 추적** — anthropics/claude-agent-sdk-typescript
