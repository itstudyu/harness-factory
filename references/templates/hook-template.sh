#!/usr/bin/env bash
# {{HOOK_NAME}} — {{HOOK_EVENT}} hook for {{PURPOSE}}
# 입력은 stdin JSON으로 전달된다 (공식 Claude Code hook 규약).
# ref: https://code.claude.com/docs/en/hooks
# Exit codes: 0=proceed, 2=block with stderr feedback. 기타=non-blocking error.
set -euo pipefail

INPUT="$(cat || true)"
[ -n "$INPUT" ] || exit 0

# stdin JSON에서 필요한 값 추출 (jq 우선, 없으면 python3 폴백)
FILE_PATH=""
TOOL_NAME=""
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
  TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
else
  read -r TOOL_NAME FILE_PATH <<EOF
$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print(d.get('tool_name') or '', (d.get('tool_input') or {}).get('file_path') or '')
except Exception:
    print('', '')
" 2>/dev/null)
EOF
fi

# Early exit: 대상 파일 패턴에 맞지 않으면 스킵
if [ -n "$FILE_PATH" ] && [[ ! "$FILE_PATH" =~ {{FILE_PATTERN}} ]]; then
  exit 0
fi

# 파일 검증 (존재할 때만)
if [ -n "$FILE_PATH" ] && [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

VIOLATIONS=0

check_pattern() {
  local pattern="$1"
  local description="$2"
  local matches
  matches=$(grep -n "$pattern" "$FILE_PATH" 2>/dev/null || true)
  if [ -n "$matches" ]; then
    echo "  WARN: $description" >&2
    echo "$matches" | sed 's/^/    /' >&2
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
}

# {{VALIDATION_RULES}}
# check_pattern '패턴' '설명'

if [ "$VIOLATIONS" -gt 0 ]; then
  echo "" >&2
  echo "  ⚠ $VIOLATIONS violation(s) found in $FILE_PATH" >&2
  # 정책 시행은 exit 2. (참조: https://code.claude.com/docs/en/hooks)
  # exit 2
fi
