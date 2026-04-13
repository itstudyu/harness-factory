#!/usr/bin/env bash
# validate-generated.sh — PostToolUse hook for Write|Edit
# 공식 Claude Code hook 스펙: 입력은 stdin JSON으로 전달된다.
# ref: https://code.claude.com/docs/en/hooks (PostToolUse input schema)
# Exit codes: 0=pass, 2=block (HARNESS_STRICT=1 시), 그 외=non-blocking error
set -euo pipefail

# stdin JSON payload에서 file_path 추출 (jq 없으면 python3로 폴백)
INPUT="$(cat || true)"

FILE_PATH=""
if [ -n "$INPUT" ]; then
  if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
  else
    FILE_PATH=$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get('tool_input') or {}).get('file_path') or '')
except Exception:
    pass
" 2>/dev/null || true)
  fi
fi

# 파일 경로가 없으면 non-file 도구 호출이므로 스킵
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# 대상 분류
IS_AGENT=false
IS_SKILL=false
if [[ "$FILE_PATH" =~ \.claude/agents/.*\.md$ ]]; then
  IS_AGENT=true
elif [[ "$FILE_PATH" =~ \.claude/skills/.*/SKILL\.md$ ]]; then
  IS_SKILL=true
else
  exit 0
fi

# 파일 존재 확인 (PostToolUse 시점에는 존재해야 함)
[ -f "$FILE_PATH" ] || exit 0

WARNINGS=0

check_frontmatter_field() {
  local field="$1"
  local label="$2"
  if ! head -20 "$FILE_PATH" | grep -q "^${field}:"; then
    echo "  WARN: frontmatter에 '${label}' 필드가 없습니다 — $FILE_PATH" >&2
    WARNINGS=$((WARNINGS + 1))
  fi
}

if [ "$IS_AGENT" = true ]; then
  check_frontmatter_field "name" "name"
  check_frontmatter_field "description" "description"
  check_frontmatter_field "tools" "tools"
  check_frontmatter_field "permissionMode" "permissionMode"

  # PGE 역할 태그 확인 (공식 frontmatter에 role이 없으므로 description 태그로 관례화)
  if ! head -20 "$FILE_PATH" | grep -qE "^description:.*\[(planner|generator|evaluator)\]"; then
    echo "  INFO: description에 [planner]/[generator]/[evaluator] 태그가 없습니다 — $FILE_PATH" >&2
  fi

  if ! grep -q "하지 않는 것" "$FILE_PATH"; then
    echo "  WARN: Negative Space 섹션이 없습니다 — $FILE_PATH" >&2
    WARNINGS=$((WARNINGS + 1))
  fi

  if ! head -20 "$FILE_PATH" | grep -q "^maxTurns:"; then
    echo "  INFO: maxTurns 필드 미지정 (기본값 적용됨) — $FILE_PATH" >&2
  fi
fi

if [ "$IS_SKILL" = true ]; then
  check_frontmatter_field "name" "name"
  check_frontmatter_field "description" "description"
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "" >&2
  echo "  ⚠ $WARNINGS 개 필수 항목 누락 — $FILE_PATH" >&2
  if [ "${HARNESS_STRICT:-0}" = "1" ]; then
    echo "  HARNESS_STRICT=1이 설정되어 있어 작업을 차단합니다." >&2
    exit 2
  fi
fi
