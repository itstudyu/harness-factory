#!/usr/bin/env python3
# {{HOOK_NAME}} — hook
# stdin: JSON payload from Claude Code
# stdout: JSON response (hookSpecificOutput)
import sys
import json
import os

# 훅 이벤트명: SessionStart | PreToolUse | PostToolUse | SubagentStart | Stop
EVENT_NAME = "{{HOOK_EVENT}}"

EMPTY = json.dumps({})


def read_stdin():
    """Claude Code가 전달하는 JSON payload를 읽는다."""
    try:
        return json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return None


def build_output(content):
    """hookSpecificOutput JSON을 생성한다."""
    return json.dumps({
        "hookSpecificOutput": {
            "hookEventName": EVENT_NAME,
            "additionalContext": content,
        }
    })


def main():
    data = read_stdin()
    if not data:
        sys.stdout.write(EMPTY)
        return

    # {{HOOK_LOGIC}}

    sys.stdout.write(EMPTY)


if __name__ == "__main__":
    main()
