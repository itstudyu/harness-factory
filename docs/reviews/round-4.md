# Critical review — round 4 (scenario run)

**Reviewer:** scenario simulation run in `/Users/yu_s/Documents/GitHub/5-13-hfx-test/`.
**Mandate:** exercise the end-to-end flow against the actual scripts/SKILLs.
**Verdict:** 1 runtime-critical issue found and fixed.

Round 3 had declared "zero critical issues" but was purely
static-analysis — it never executed the gate sequence step by step.
Running the actual flow surfaced a real bug on the very first
`verify-approval.sh` call.

---

## CRIT-RUNTIME-1 — `compute-sha.sh` did not strip `status:` line

**Symptom:** `/hfx:plan` Step 7 [a] flow:
1. compute sha against `plan.md` (state = `status: draft`, `approved_at: null`, `content_sha: null`).
2. Write that sha into `content_sha`, fill `approved_at`, and **flip `status: draft → ready`**.
3. Call `verify-approval.sh`, which recomputes sha and compares.

`compute-sha.sh` only stripped `content_sha:` and `approved_at:` lines.
So step 1's hash was over a body containing `status: draft`, but step 3's
hash was over a body containing `status: ready` — **always different,
exit 3 (sha mismatch)** on the very first verify. The hard gate was
unusable as specified.

**Fix applied:**
```diff
-  sed -E '/^(content_sha|approved_at):.*$/d' "$plan"
+  sed -E '/^(content_sha|approved_at|status):.*$/d' "$plan"
```
Plus header comment updated to explain *why* `status` is excluded
(it's a workflow flag, not content the user agreed to).

**End-to-end re-test (in scenario run):**
- Fresh draft → compute-sha → flip to ready + write sha + approved_at →
  `verify-approval.sh` → `ok: ...` exit 0. ✓
- Then append a line to `plan.backend.md` → `verify-approval.sh` →
  exit 3 with "content_sha mismatch". ✓ (tamper detection still works)
- Remove the appended line → `verify-approval.sh` → exit 0 again. ✓

## Why prior rounds missed it

- Round 1 looked at namespace/dispatch correctness.
- Round 2 looked at path bugs after the namespace fix.
- Round 3 walked all 11 critical-issue categories but did **static-only**
  inspection (read SKILLs and scripts, did not execute the gate sequence).

None traced the actual sequence `draft → compute → flip status → verify`.

## Round-4 sequence test (the test that worked)

This is a 5-command repro that should be added as a unit-style smoke
test in future rounds:

```bash
T=$(mktemp -d)
mkdir -p "$T/.harness/tickets/active/X"
cat > "$T/.harness/tickets/active/X/plan.md" <<'EOF'
---
ticket-id: X
status: draft
approved_at: null
content_sha: null
---

## Context
EOF
cat > "$T/.harness/tickets/active/X/plan.x.md" <<'EOF'
## Tasks
- [ ] t1
EOF
SHA=$(bash scripts/compute-sha.sh "$T/.harness/tickets/active/X")
# Simulate /hfx:plan Step 7 [a]:
sed -i.bak "s/^status: draft/status: ready/" "$T/.harness/tickets/active/X/plan.md"
sed -i.bak "s/^approved_at: null/approved_at: 2026-05-13T00:00:00Z/" "$T/.harness/tickets/active/X/plan.md"
sed -i.bak "s/^content_sha: null/content_sha: $SHA/" "$T/.harness/tickets/active/X/plan.md"
# /hfx:run Step 2:
bash scripts/verify-approval.sh "$T/.harness/tickets/active/X"   # MUST exit 0
```

## Other things confirmed working under the scenario run

- `move-ticket.sh active → done` succeeded; ticket no longer in active/.
- `INDEX.md` left unmodified after [n] memory candidates.
- `Agent` tool sub-agent dispatch (simulated via `general-purpose`)
  followed worker `## Output format` and respected hard rules
  (the backend worker refused to touch `console.log` flagged by a
  PostToolUse hook, citing principle.md #3 — exactly the intended
  behavior).
- All 5 plan.md Verification checkboxes ran with passing output.

## Outstanding (deferred to follow-up)

- **Native plugin-loader exercise**: this run simulated SKILL bodies
  manually because the host session was launched in the hfx repo, not
  in the test fixture. A separate session
  `claude --plugin-dir /Users/yu_s/Documents/GitHub/hfx` from inside
  `/Users/yu_s/Documents/GitHub/5-13-hfx-test/` should walk the same
  scenario natively via `/hfx:init`, `/hfx:plan`, `/hfx:run`, etc.

- **Worker dispatch with the real `subagent_type`**: simulation used
  `general-purpose`. The native run will use
  `subagent_type="backend"` / `"docupdater"` resolving against
  `.claude/agents/<name>.md`. Behavior should be equivalent; verify.

Round 4 verdict: 1 runtime-critical fixed; ready for v0.0.2 patch
commit and a native re-run.
