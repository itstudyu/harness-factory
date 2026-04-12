#!/usr/bin/env bash
# validate-generated.sh — PostToolUse hook for Write|Edit
# 생성된 agent/skill 파일의 frontmatter 필수 필드를 검증한다. (비차단)
set -euo pipefail

FILE_PATH="${1:-}"

# 대상이 아닌 파일은 스킵
IS_AGENT=false
IS_SKILL=false

if [[ "$FILE_PATH" =~ \.claude/agents/.*\.md$ ]]; then
  IS_AGENT=true
elif [[ "$FILE_PATH" =~ \.claude/skills/.*/SKILL\.md$ ]]; then
  IS_SKILL=true
else
  exit 0
fi

# 파일 존재 확인
if [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

WARNINGS=0

check_frontmatter_field() {
  local field="$1"
  local label="$2"
  if ! head -20 "$FILE_PATH" | grep -q "^${field}:"; then
    echo "  WARN: frontmatter에 '${label}' 필드가 없습니다 — $FILE_PATH" >&2
    WARNINGS=$((WARNINGS + 1))
  fi
}

# 에이전트 파일 검증
if [ "$IS_AGENT" = true ]; then
  check_frontmatter_field "name" "name"
  check_frontmatter_field "description" "description"
  check_frontmatter_field "tools" "tools"
  check_frontmatter_field "permissionMode" "permissionMode"

  # Negative Space 섹션 확인
  if ! grep -q "하지 않는 것" "$FILE_PATH"; then
    echo "  WARN: Negative Space 섹션이 없습니다 — $FILE_PATH" >&2
    WARNINGS=$((WARNINGS + 1))
  fi

  # 선택 필드 안내 (경고 수준 낮음)
  if ! head -20 "$FILE_PATH" | grep -q "^maxTurns:"; then
    echo "  INFO: maxTurns 필드 미지정 (기본값 적용됨) — $FILE_PATH" >&2
  fi
fi

# 스킬 파일 검증
if [ "$IS_SKILL" = true ]; then
  check_frontmatter_field "name" "name"
  check_frontmatter_field "description" "description"
fi

if [ "$WARNINGS" -gt 0 ]; then
  echo "" >&2
  echo "  ⚠ $WARNINGS 개 필수 항목 누락 — $FILE_PATH" >&2
  # Strict 모드: HARNESS_STRICT=1 환경변수 설정 시 차단 (exit 2 = block/feedback)
  if [ "${HARNESS_STRICT:-0}" = "1" ]; then
    echo "  HARNESS_STRICT=1이 설정되어 있어 작업을 차단합니다." >&2
    exit 2
  fi
fi
