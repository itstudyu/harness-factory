# Critical review — round 6 (native re-run after round-5 fix)

**Reviewer:** native `claude --plugin-dir` session, user-driven.
**Mandate:** verify round-5 placeholder fix; retest `/hfx:plan`.
**Verdict:** round-5 fix itself broke the parser. Fixed in this round.

---

## CRIT-RUNTIME-3 — Inline backtick reference to `` ```! `` triggers injection

**Symptom (native session):**
```
/plan create endpoint
Error: Shell command failed for pattern "```! shell-injection
block for this step — the ticket-id is dynamic and a literal`
placeholder would be sent to the shell unchanged.)
...
[stderr] (eval):1: command not found: shell-injection
        (eval):1: command not found: ticket-id
```

**Root cause:** Round 5 fixed the previous bug (literal `<ticket-id>`
inside ` ```! ` blocks) by replacing those blocks with `Bash` tool
instructions. But the replacement prose included a warning like:

```
Use the `Bash` tool (do NOT use a ` ```! ` injection block — the
ticket-id is dynamic) to ...
```

Notice the inline backtick string `` ` ```! ` ``. When the SKILL is
rendered into the prompt, Claude Code's preprocessor scans for fenced
` ```! ` injection blocks. It is **not** strict about requiring the
` ```! ` to begin a line — finding the three-backticks-then-`!`
sequence anywhere triggers it. Everything from that point until the
next ` ``` ` is treated as a shell command. The shell then receives
the warning prose as bash, which obviously fails to parse.

Round 5's fix accidentally documented the very pattern it was telling
the model to avoid — and that documentation got eaten by the
preprocessor.

**Affected sites (fixed in this commit):**

| File | Step | Old wording | New wording |
|---|---|---|---|
| `skills/plan/SKILL.md` | Step 6 | "do NOT use a ` ```! ` injection block ..." | "Use the `Bash` tool at this point — substitute the actual ticket-id ..." |
| `skills/plan/SKILL.md` | Step 7 [a].1 | same warning prose | same fix |
| `skills/run/SKILL.md` | Step 2 | same | same fix |
| `skills/run/SKILL.md` | Step 6 [a] | same | same fix |

The rule going forward: **never mention ` ```! ` in SKILL body prose.**
If a step needs to warn the model away from a pattern, do it by
omission, not by quoting the trigger.

## Validation

After the fix:
- `grep -nE '` + '`' + '`' + '`' + '!' /Users/yu_s/Documents/GitHub/hfx/skills/*/SKILL.md`
  shows only line-leading injection blocks (`^```!` at column 0), which
  are the legitimate ENV-only blocks we kept intentionally.
- All fence counts per file are even (every `` ``` `` opener has a closer).
- No inline backtick references to `!` remain anywhere in prose.

## Why prior rounds and round-5 itself missed it

Round 5 was a static fix written to address round-4's symptom. The
fix was tested by `grep` against the surface pattern (`!` blocks
containing `<ticket-id>`), not by running the SKILL through the
actual preprocessor. The new wording introduced a new instance of
the same surface pattern in a different guise — fenced inline code.

## Lesson for future rounds

A skill body is parsed twice:
1. **Preprocessor:** scans for ` !`...` ` and ` ```! ... ``` ` and
   runs them as shell commands BEFORE the model sees anything. Any
   stray backtick-bang sequence is fuel for this scanner.
2. **Model:** reads the post-preprocess output as ordinary prose.

The model has no way to "see" or "respond to" the preprocessor's
mistakes — they happen earlier in the pipeline. So review must
include rendering the SKILL and looking at what the shell runs,
not just what the prose says.

Round 6 verdict: 1 critical fixed. Native re-run still pending.
