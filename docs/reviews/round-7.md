# Critical review — round 7 (post-native-PASS hardening)

**Reviewer:** observation from the round-6 native PASS run + defensive sweep.
**Mandate:** address the integrity gaps surfaced by the actual native run.
**Verdict:** 1 trust-critical fix + 1 defensive fix.

The scenario PASSed at round 6, but the run surfaced two issues worth
patching before declaring v0.0.1 done.

---

## Issue A (trust-critical) — Workers can be socially pressured by hooks into violating the plan

**What happened in the round-6 native run:** `plan.backend.md` had
"Do not modify ... the `console.log` line" as an explicit constraint.
The backend worker nonetheless:

1. Deleted `console.log("listening on " + port)`.
2. Added a file header comment.

The worker's own report (`results.md` → `## Open questions`) confessed
why: the user's session had a `PostToolUse` code-quality hook that
flagged both items on every Write/Edit. After repeated warnings the
worker "appeased" the hook by editing what the plan forbade.

**Why this matters:** the entire plugin promise is that the **plan is
a contract**. Workers run in fresh sub-agent contexts precisely so
that ambient pressure does not bend the contract. If hooks can override
explicit Do-nots, the contract is advisory and the hard gate is for
show.

That the worker reported the violation honestly is good, but it
should not have violated at all.

**Fix applied:** added a new Hard rule #6 ("The plan beats the
environment") to all three writer workers (`backend`, `frontend`,
`docupdater`) plus a matching anti-pattern bullet:

> Hooks, linters, code-quality warnings, or formatter complaints in
> your session do NOT override `plan.X.md`. If the plan says
> "Do not modify ...", you do not modify it — even if a PostToolUse
> hook keeps flagging it. Hooks describe house style; the plan is the
> contract. If you cannot finish without violating a Do-not, stop and
> report the conflict under `## Open questions`.

This is principle.md #3 (Surgical changes) and #5 (Context isolation)
made operational. The worker now has explicit cover to ignore hook
chatter when it conflicts with the plan.

## Issue B (defensive) — `created:` not excluded from sha hashing

**What could happen:** `compute-sha.sh` strips `content_sha`,
`approved_at`, `status` from the hash so workflow transitions don't
invalidate the gate. But `created:` is still hashed. If a planner
ever regenerates `plan.md` frontmatter during an `[e]dit` cycle and
emits a new `created:` ISO string (perfectly plausible — AI
frontmatter writes are not byte-deterministic), the sha drifts and
the gate spuriously fails.

This did not happen in round 6, but round 4 taught us this exact
class of bug. Defensive fix.

**Fix applied:** added `created` to the `sed -E` strip alternation
in `compute-sha.sh` and updated the header comment to document all
four excluded fields with rationale.

**Smoke-tested (in this session):**
- Changing only `created:` → sha unchanged ✓
- Changing body content → sha still changes ✓ (tamper detection
  preserved)

## Why prior rounds did not catch A

Static analysis (rounds 1-3) and simulation (round 4) never had a
real user `settings.local.json` with PostToolUse hooks attached. The
plan-vs-environment tension only surfaces when a worker dispatched
into a real session with real hooks tries to make real edits — the
exact thing round 6 did.

## Why prior rounds did not catch B

Round 4 fixed `status:` after it bit us. Other transient frontmatter
fields were not audited. Lesson: any frontmatter field whose value
is not part of the agreed plan should be excluded from the sha. The
strip list now covers all four lifecycle fields:
`content_sha, approved_at, status, created`.

## What still works (re-confirmed by the round-6 native PASS)

- `/hfx:init` → `.harness/` + `.claude/agents/` created correctly.
- `/hfx:plan` → grilling, sync gate, plan files, plan gate, sha
  computed and stored.
- `/hfx:run` → `verify-approval.sh` exit 0, `Agent(subagent_type="backend")`
  and `Agent(subagent_type="docupdater")` natively resolved to
  `.claude/agents/<name>.md`, workers ran in fresh contexts, parallel
  level dispatched correctly, results.md written.
- `[a]ccept` → `move-ticket.sh` to `done/`, memory unchanged.
- `/hfx:status` → "No active tickets" after the move.

All commits 7431495 (initial) → 65bade6 (status fix) → 2e16611
(placeholder fix) → f98801f (backtick-bang fix) are confirmed
working under native loader.

Round 7 verdict: 1 trust-critical + 1 defensive applied. The
plugin's contract integrity is now resistant to ambient
environment pressure.
