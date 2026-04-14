#!/usr/bin/env bash
# suggest-upgrade.sh — SessionStart hook
# harness-rules.md의 last_updated가 7일 이상 지났으면 /harness-upgrade 제안을 세션 컨텍스트에 주입한다.
# 기존 inject-harness-rules.sh와 별개로 동작 (서로 다른 목적).
# ref: https://code.claude.com/docs/en/hooks (SessionStart additionalContext)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="$SCRIPT_DIR/../../references/harness-rules.md"
PROGRESS_FILE="$SCRIPT_DIR/../../.nova/progress.json"

# 조건: rules 파일 존재 + 현재 repo가 harness-factory거나 .claude/ 보유 프로젝트
if [ ! -f "$RULES_FILE" ]; then
  echo '{}'
  exit 0
fi

LAST_UPDATED=$(grep -m1 'last_updated:' "$RULES_FILE" 2>/dev/null | sed 's/.*: *"\{0,1\}\([0-9-]*\)"\{0,1\}/\1/' || echo "")

DIFF_DAYS=0
if [ -n "$LAST_UPDATED" ] && date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s" &>/dev/null; then
  LAST_TS=$(date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s")
  NOW_TS=$(date "+%s")
  DIFF_DAYS=$(( (NOW_TS - LAST_TS) / 86400 ))
fi

# 이미 최근에 업그레이드를 시도했는지 체크 (쿨다운 7일)
UPGRADE_COOLDOWN_DAYS=7
RECENT_UPGRADE=false
if [ -f "$PROGRESS_FILE" ]; then
  LAST_UPGRADE=$(python3 -c "
import json, sys
try:
    d = json.load(open('$PROGRESS_FILE'))
    print(d.get('last_upgrade_at') or '')
except Exception:
    pass
" 2>/dev/null || echo "")
  if [ -n "$LAST_UPGRADE" ] && date -j -f "%Y-%m-%d" "$LAST_UPGRADE" "+%s" &>/dev/null; then
    UP_TS=$(date -j -f "%Y-%m-%d" "$LAST_UPGRADE" "+%s")
    UP_DIFF=$(( (NOW_TS - UP_TS) / 86400 ))
    if [ "$UP_DIFF" -lt "$UPGRADE_COOLDOWN_DAYS" ]; then
      RECENT_UPGRADE=true
    fi
  fi
fi

# 7일 이하면 제안 없음
if [ "$DIFF_DAYS" -lt 7 ] || [ "$RECENT_UPGRADE" = true ]; then
  echo '{}'
  exit 0
fi

# 7일 이상 경과 + 최근 업그레이드 없음 → 제안 주입
python3 -c "
import json
msg = (
  '[harness-upgrade 제안] harness-rules.md가 마지막 갱신 후 ${DIFF_DAYS}일 경과. '
  '자동 업그레이드 루프를 돌리려면 \`/harness-upgrade\`를 실행하세요 '
  '(진단 → 자동 patch → 검수 → 유저 확인 후 머지). '
  '원하지 않으면 무시하세요. 쿨다운: ${UPGRADE_COOLDOWN_DAYS}일.'
)
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': msg
    }
}))
"
