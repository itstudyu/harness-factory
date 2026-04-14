#!/usr/bin/env bash
# suggest-upgrade.sh — SessionStart hook
# harness-rules.md의 last_updated가 7일 이상 지났으면 /harness-upgrade 제안을
# 세션 컨텍스트에 주입한다. inject-harness-rules.sh는 해시만 주입하고
# "갱신일 경고"는 이 훅의 단일 책임.
# ref: https://code.claude.com/docs/en/hooks (SessionStart additionalContext)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="$SCRIPT_DIR/../../references/harness-rules.md"
PROGRESS_FILE="$SCRIPT_DIR/../../.nova/progress.json"

if [ ! -f "$RULES_FILE" ]; then
  echo '{}'
  exit 0
fi

# NOW_TS는 최상단에서 정의 (set -u 안전)
NOW_TS=$(date "+%s")

LAST_UPDATED=$(grep -m1 'last_updated:' "$RULES_FILE" 2>/dev/null | sed 's/.*: *"\{0,1\}\([0-9-]*\)"\{0,1\}/\1/' || echo "")

DIFF_DAYS=0
if [ -n "$LAST_UPDATED" ] && date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s" &>/dev/null; then
  LAST_TS=$(date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s")
  DIFF_DAYS=$(( (NOW_TS - LAST_TS) / 86400 ))
  [ "$DIFF_DAYS" -lt 0 ] && DIFF_DAYS=0
fi

UPGRADE_COOLDOWN_DAYS=7
RECENT_UPGRADE=false
if [ -f "$PROGRESS_FILE" ]; then
  LAST_UPGRADE=$(PROGRESS_FILE="$PROGRESS_FILE" python3 -c "
import json, os
try:
    d = json.load(open(os.environ['PROGRESS_FILE']))
    print(d.get('last_upgrade_at') or '')
except Exception:
    pass
" 2>/dev/null || echo "")
  if [ -n "$LAST_UPGRADE" ] && date -j -f "%Y-%m-%d" "$LAST_UPGRADE" "+%s" &>/dev/null; then
    UP_TS=$(date -j -f "%Y-%m-%d" "$LAST_UPGRADE" "+%s")
    UP_DIFF=$(( (NOW_TS - UP_TS) / 86400 ))
    if [ "$UP_DIFF" -ge 0 ] && [ "$UP_DIFF" -lt "$UPGRADE_COOLDOWN_DAYS" ]; then
      RECENT_UPGRADE=true
    fi
  fi
fi

if [ "$DIFF_DAYS" -lt 7 ] || [ "$RECENT_UPGRADE" = true ]; then
  echo '{}'
  exit 0
fi

# env 전달 + f-string 바깥에서 값 수령 (백슬래시 이스케이프 제약 회피)
DIFF_DAYS="$DIFF_DAYS" UPGRADE_COOLDOWN_DAYS="$UPGRADE_COOLDOWN_DAYS" python3 <<'PY'
import json, os
dd = os.environ.get("DIFF_DAYS", "?")
cd = os.environ.get("UPGRADE_COOLDOWN_DAYS", "7")
msg = (
    "[harness-upgrade 제안] harness-rules.md가 마지막 갱신 후 "
    f"{dd}일 경과. "
    "자동 업그레이드 루프를 돌리려면 `/harness-upgrade`를 실행하세요 "
    "(진단 → 자동 patch → 검수 → 유저 확인 후 머지). "
    "원하지 않으면 무시하세요. 쿨다운: "
    f"{cd}일."
)
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": msg
    }
}))
PY
