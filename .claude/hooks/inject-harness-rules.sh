#!/usr/bin/env bash
# inject-harness-rules.sh — SessionStart hook
# harness-rules.md를 매 세션 context에 주입하고, 갱신일을 체크한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="$SCRIPT_DIR/../../references/harness-rules.md"

# rules 파일이 없으면 빈 JSON 반환
if [ ! -f "$RULES_FILE" ]; then
  echo '{}'
  exit 0
fi

# 갱신일 체크: last_updated frontmatter 필드 읽기
LAST_UPDATED=$(grep -m1 'last_updated:' "$RULES_FILE" 2>/dev/null | sed 's/.*: *"\{0,1\}\([0-9-]*\)"\{0,1\}/\1/' || echo "")

if [ -n "$LAST_UPDATED" ]; then
  # macOS date 호환
  if date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s" &>/dev/null; then
    LAST_TS=$(date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s")
    NOW_TS=$(date "+%s")
    DIFF_DAYS=$(( (NOW_TS - LAST_TS) / 86400 ))

    if [ "$DIFF_DAYS" -ge 7 ]; then
      echo "⚠ harness-rules.md가 ${DIFF_DAYS}일 전에 마지막 갱신됨. /rules-updater 실행을 권장합니다." >&2
    fi
  fi
fi

# rules 내용을 additionalContext로 주입
CONTENT=$(cat "$RULES_FILE")
python3 -c "
import json, sys
content = sys.stdin.read()
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': content
    }
}))
" <<< "$CONTENT"
