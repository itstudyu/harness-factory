#!/usr/bin/env bash
# inject-harness-rules.sh — SessionStart hook
# rules 전문을 매 세션 주입하지 않는다. 경로와 무결성 해시만 주입해
# prompt-caching의 messages 계층 재빌드를 최소화한다.
# 갱신일 경고는 suggest-upgrade.sh가 단독 담당 (중복 출력 방지).
# rules 본문은 CLAUDE.md의 @references/harness-rules.md import로 로드된다.
# ref: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_FILE="$SCRIPT_DIR/../../references/harness-rules.md"

if [ ! -f "$RULES_FILE" ]; then
  echo '{}'
  exit 0
fi

LAST_UPDATED=$(grep -m1 'last_updated:' "$RULES_FILE" 2>/dev/null | sed 's/.*: *"\{0,1\}\([0-9-]*\)"\{0,1\}/\1/' || echo "")
HASH=$(shasum -a 256 "$RULES_FILE" | awk '{print $1}')
SIZE_BYTES=$(wc -c < "$RULES_FILE" | tr -d ' ')
WORDS=$(wc -w < "$RULES_FILE" | tr -d ' ')

# 값은 env로 전달, f-string 내부의 백슬래시 이스케이프 불가 제약을 피하려고
# os.environ.get()을 본문 바깥에서 변수에 받는다.
LAST_UPDATED="$LAST_UPDATED" HASH="$HASH" SIZE_BYTES="$SIZE_BYTES" WORDS="$WORDS" python3 <<'PY'
import json, os
lu = os.environ.get("LAST_UPDATED", "")
sh = os.environ.get("HASH", "")
sz = os.environ.get("SIZE_BYTES", "")
wd = os.environ.get("WORDS", "")
summary = (
    "harness-rules reference loaded via CLAUDE.md (@references/harness-rules.md). "
    f"last_updated={lu}  sha256={sh}  bytes={sz}  words={wd}. "
    "원칙은 CLAUDE.md에 import된 harness-rules.md를 참조하라."
)
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": summary
    }
}))
PY
