#!/usr/bin/env python3
# {{HOOK_NAME}} — Claude Code hook
# stdin: JSON payload (session_id, cwd, hook_event_name, tool_name, tool_input, ...)
# stdout: JSON response (universal fields + hookSpecificOutput)
# ref: https://code.claude.com/docs/en/hooks
#
# 지원되는 hook 이벤트명 (2026-04 기준 공식 목록):
#   SessionStart, SessionEnd, UserPromptSubmit,
#   PreToolUse, PostToolUse, PostToolUseFailure,
#   PermissionRequest, PermissionDenied,
#   Notification, Stop, StopFailure,
#   SubagentStart, SubagentStop,
#   TaskCreated, TaskCompleted,
#   InstructionsLoaded, ConfigChange,
#   CwdChanged, FileChanged,
#   WorktreeCreate, WorktreeRemove,
#   PreCompact, PostCompact,
#   Elicitation, ElicitationResult,
#   TeammateIdle
import sys
import json

EVENT_NAME = "{{HOOK_EVENT}}"

EMPTY = json.dumps({})


def read_stdin():
    try:
        return json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return None


def build_output(content):
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
