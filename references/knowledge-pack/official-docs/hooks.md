---
name: hooks
type: official-doc
url: https://code.claude.com/docs/en/hooks
publisher: Claude Code Docs
rules_citation: "[6]"
last_analyzed: 2026-05-03
---

# Hooks — Claude Code Docs [6]

## 한 줄
4종 훅 핸들러 (command / http / prompt / agent) + PreToolUse `updatedInput` 확장.

## 4종 훅 핸들러 (전체)

| 핸들러 | 입력 | 동작 |
|---|---|---|
| **command** | shell, stdin JSON | exit code로 제어 |
| **http** | POST endpoint | 2xx 통과, decision JSON으로 차단 |
| **prompt** | LLM | prompt 템플릿 + model 필드 |
| **agent** | Sub-agent | model 필드 선택 |

## 환경 변수 (공식)
- `$CLAUDE_PROJECT_DIR`
- `${CLAUDE_PLUGIN_ROOT}`
- `$CLAUDE_ENV_FILE` — SessionStart 훅에서 세션 환경변수 영속

⚠️ **`$TOOL_INPUT_FILE_PATH`는 비공식** — 입력은 stdin JSON이 표준.

## Exit Code 규약
- `0`: proceed
- `2`: block with stderr feedback
- 기타: non-blocking error

## PreToolUse 확장
- `updatedInput`: 도구 입력을 실행 전 수정 가능
- allow/deny 외 **제3옵션**

## 우리 룰 매핑
- §7 "훅 — 4종 핸들러" — 직접 인용
- §7 "PreToolUse 확장 `updatedInput`" — 직접 인용
- §6 "Stop 루프 방지 — `stop_hook_active`" — 직접 인용

## 현재 훅 (우리 5개)
| 훅 | 핸들러 | 비고 |
|---|---|---|
| inject-harness-rules.sh | command | SessionStart inject |
| suggest-upgrade.sh | command | 7일 쿨다운 제안 |
| validate-generated.sh | command | PostToolUse 검수 |
| enforce-planner-write.sh | command | PreToolUse 권한 |
| enforce-upgrader-scope.sh | command | PreToolUse 권한 |

→ 모두 command 핸들러. **prompt / agent 핸들러는 미사용**.

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 신규 훅 이벤트 추가 시 (TeammateIdle 등)
- **diff-reporter**: 훅 4종 핸들러 활용 부족 점검
- **v2 redesign**: 5개 command 훅 → 1개로 압축 + agent 핸들러 활용 검토

## 우리 v2 영향
- 5개 훅 → 1~2개로 축소
- enforce-* 훅들은 frontmatter `disallowedTools`로 대체 가능
- inject-harness-rules.sh는 CLAUDE.md `@import` 한 줄로 대체 가능

## 우선순위 액션
1. **훅 4종 핸들러 매트릭스 작성** — 우리가 어느 핸들러를 안 쓰는지
2. **agent 핸들러 활용** — auditor를 agent 핸들러로 통합 검토
3. PostToolUse `updatedInput` 활용 가능성 (예: org.md 자동 갱신)
