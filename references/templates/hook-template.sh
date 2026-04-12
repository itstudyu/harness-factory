#!/usr/bin/env bash
# {{HOOK_NAME}} — {{HOOK_EVENT}} hook for {{PURPOSE}}
# Exit codes: 0=pass, 1=error, 2=block/feedback
set -euo pipefail

FILE_PATH="${1:-}"

# Early exit: 대상 파일이 아니면 스킵
if [[ ! "$FILE_PATH" =~ {{FILE_PATTERN}} ]]; then
  exit 0
fi

# 파일 존재 확인
if [ ! -f "$FILE_PATH" ]; then
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
  echo "  Fix before completing the task." >&2
fi
