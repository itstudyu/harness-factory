#!/usr/bin/env bash
# inject-harness-rules.sh — SessionStart hook
# rules 전문을 매 세션 주입하지 않는다. 대신 경로와 무결성 해시만 알려
# prompt-caching의 messages 계층 재빌드를 최소화한다.
# rules 본문은 CLAUDE.md의 @references/harness-rules.md import로 로드된다.
# ref (caching 계층): https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
# Exit codes: 0=proceed with JSON on stdout
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="$SCRIPT_DIR/../../references/harness-rules.md"

if [ ! -f "$RULES_FILE" ]; then
  echo '{}'
  exit 0
fi

# 갱신일 경고만 판단 (stderr로)
LAST_UPDATED=$(grep -m1 'last_updated:' "$RULES_FILE" 2>/dev/null | sed 's/.*: *"\{0,1\}\([0-9-]*\)"\{0,1\}/\1/' || echo "")
if [ -n "$LAST_UPDATED" ] && date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s" &>/dev/null; then
  LAST_TS=$(date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s")
  NOW_TS=$(date "+%s")
  DIFF_DAYS=$(( (NOW_TS - LAST_TS) / 86400 ))
  if [ "$DIFF_DAYS" -ge 7 ]; then
    echo "⚠ harness-rules.md가 ${DIFF_DAYS}일 전에 마지막 갱신됨. /rules-updater 실행을 권장합니다." >&2
  fi
fi

# 해시·크기·경로만 additionalContext로 주입 (rules 본문은 CLAUDE.md import로)
HASH=$(shasum -a 256 "$RULES_FILE" | awk '{print $1}')
SIZE_BYTES=$(wc -c < "$RULES_FILE" | tr -d ' ')
WORDS=$(wc -w < "$RULES_FILE" | tr -d ' ')

python3 -c "
import json
summary = (
  'harness-rules reference loaded via CLAUDE.md (@references/harness-rules.md). '
  'last_updated=${LAST_UPDATED}  sha256=${HASH}  bytes=${SIZE_BYTES}  words=${WORDS}. '
  '원칙은 CLAUDE.md에 import된 harness-rules.md를 참조하라. /rules-updater로 갱신 가능.'
)
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': summary
    }
}))
"
