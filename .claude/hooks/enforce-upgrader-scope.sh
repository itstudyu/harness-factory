#!/usr/bin/env bash
# enforce-upgrader-scope.sh — PreToolUse hook for Write|Edit
# harness-upgrader 에이전트가 references/harness-rules.md 또는
# references/harness-references.md를 수정하려 할 때 exit 2로 차단한다.
# rules 자체 수정은 /rules-updater의 영역이며 upgrader의 Negative Space.
# ref: https://code.claude.com/docs/en/hooks (PreToolUse decision control)
set -euo pipefail

INPUT="$(cat || true)"
[ -n "$INPUT" ] || exit 0

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

# Write/Edit가 아니면 스킵
case "$TOOL_NAME" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

# 대상이 upgrader agent인 경우만 적용
[ "$AGENT_TYPE" = "harness-upgrader" ] || exit 0

[ -n "$FILE_PATH" ] || exit 0

# 차단 경로: rules.md, references.md (절대 경로/상대 경로 모두)
case "$FILE_PATH" in
  */references/harness-rules.md|references/harness-rules.md|*/references/harness-references.md|references/harness-references.md)
    echo "harness-upgrader는 references/harness-rules.md 및 harness-references.md를 수정할 수 없습니다. rules 변경은 /rules-updater의 영역입니다. 차단된 경로: $FILE_PATH" >&2
    exit 2
    ;;
esac

exit 0
