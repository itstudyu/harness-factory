---
name: openharness
tier: 4
stars: 11800
url: https://github.com/HKUDS/OpenHarness
license: MIT
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
maintainer: HKUDS (홍콩대 데이터과학실)
language: Python (CLI in React+Ink)
---

# HKUDS/OpenHarness

## 한 줄
Claude Code의 **풀스택 오픈소스 재구현**. 43개 도구 + Skills + Hooks + Subagent. ★11.8k. MIT.

## 자기소개 (원문 발췌)
> "OpenHarness delivers core lightweight agent infrastructure: tool-use, skills, memory, and multi-agent coordination."
>
> "ohmo is a personal AI agent built on OpenHarness — not another chatbot, but an assistant that actually works for you over long sessions."

## 우리에게 주는 영감

### 1. **Claude Code의 5대 기둥 명시화**
| 기둥 | 우리 룰의 어디 |
|---|---|
| Agent Loop | §2 ReAct 루프 + 공식 Agent Loop |
| Harness Toolkit (43개 도구) | §2 도구 접근 제어 |
| Context & Memory | §5 5가지 관리 패턴 |
| Governance | §7 4종 훅 + frontmatter |
| Swarm Coordination | §2 sub-agent / agent team |

→ **우리 룰의 정확한 검증** — 5기둥에 빠진 게 없는지 점검.

### 2. **anthropics/skills 호환 명시**
> "Plugin Ecosystem (Skills + Hooks + Agents)"
> "Compatible with anthropics/skills & plugins"

→ **우리도 호환성 명시 가치**. 표준 추종을 README에 명시.

### 3. **Auto-Compaction**
- 컨텍스트 압축이 task 상태 + 채널 로그 보존
- 멀티데이 세션 가능
- → 우리 `.nova/` 영속화의 다른 모델

### 4. **MCP HTTP transport + auto-reconnect**
- MCP 서버 끊김 처리
- → 우리 v2 워커가 외부 도구 사용 시 모범

### 5. **Dry-run safe preview**
> "`oh --dry-run` previews resolved runtime settings, auth state, skills, commands, tools, and configured MCP servers without executing the model, tools, or subagents."
> "Reports a `ready` / `warning` / `blocked` readiness verdict"

→ **우리 `/harness-upgrade --dry-run` 추가의 직접 모델**. 진단만 하고 실제 변경 없음.

### 6. **JSON Schema 자동 추론**
- MCP tool input의 타입을 JSON Schema로 자동 추론
- → 우리 워커 정의 시 자동 검증

## 우리와의 차이점

| 항목 | OpenHarness | 우리 |
|---|---|---|
| 위치 | Claude Code **대체 런타임** | Claude Code **위에서 동작** |
| 형식 | Python 패키지 | Markdown 설정 |
| 목적 | 자기 LLM으로 실행 | Claude Code 활용 |

→ 본질적으로 다른 층위. **우리에겐 코드 레퍼런스로만 가치**.

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 5기둥 framework 우리 룰에 명시
- **`--dry-run` 도입**: harness-upgrade에 dry-run 옵션 추가 시
- **분기 갱신**: v0.1.7 → ? 버전 추적

## 핵심 인용
> "An Agent Harness is the complete infrastructure that wraps around an LLM to make it a functional agent. The model provides intelligence; the harness provides hands, eyes, memory, and safety boundaries."
>
> "Harness = Tools + Knowledge + Observation + Action + Permissions"

## 우선순위 액션
1. **5기둥 framework 우리 룰에 매핑** (1순위)
2. **`oh --dry-run` 동작 학습** — 우리 upgrade에 도입
3. **PermissionChecker 코드 정독** — 우리 enforce-* 훅의 코드 레벨 모델
4. **Auto-Compaction** — 장기 세션 컨텍스트 관리
