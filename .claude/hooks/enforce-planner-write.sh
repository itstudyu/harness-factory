#!/usr/bin/env bash
# enforce-planner-write.sh — PreToolUse hook for Write
# Planner 역할(description에 [planner] 태그) 에이전트가 Write를 호출할 때
# 경로가 .nova/contracts/ 하위가 아니면 차단한다.
# ref: https://code.claude.com/docs/en/hooks (PreToolUse stdin JSON / decision control)
# Exit codes: 0=proceed, 2=block with stderr feedback to Claude
set -euo pipefail

INPUT="$(cat || true)"
[ -n "$INPUT" ] || exit 0

# agent_type이 planner 태그를 가진 경우에만 검사. 공식 필드 agent_type 활용.
# ref: https://code.claude.com/docs/en/hooks (common input fields)
read -r AGENT_TYPE TOOL_NAME FILE_PATH <<EOF
$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get('agent_type') or ''), (d.get('tool_name') or ''), ((d.get('tool_input') or {}).get('file_path') or ''))
except Exception:
    print('', '', '')
" 2>/dev/null)
EOF

# Write 도구가 아니면 스킵
[ "$TOOL_NAME" = "Write" ] || exit 0

# agent_type이 비어있으면(메인 세션) 스킵 — 규칙은 subagent에만 적용
[ -n "$AGENT_TYPE" ] || exit 0

# planner 태그가 아니면 스킵 (agent_type은 에이전트 name과 일치)
# harness-architect를 planner로 취급. 향후 다른 planner는 여기 추가.
PLANNER_AGENTS=("harness-architect")
IS_PLANNER=false
for a in "${PLANNER_AGENTS[@]}"; do
  if [ "$AGENT_TYPE" = "$a" ]; then
    IS_PLANNER=true
    break
  fi
done
[ "$IS_PLANNER" = true ] || exit 0

# 빈 file_path는 (이 도구엔 비정상이지만) 통과
[ -n "$FILE_PATH" ] || exit 0

# 허용 경로: .nova/contracts/ 하위만
case "$FILE_PATH" in
  *.nova/contracts/*) exit 0 ;;
  *)
    echo "Planner(${AGENT_TYPE})는 .nova/contracts/ 외 경로에 Write할 수 없습니다. 차단된 경로: $FILE_PATH" >&2
    exit 2
    ;;
esac
