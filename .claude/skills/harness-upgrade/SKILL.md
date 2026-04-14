---
name: harness-upgrade
description: 하네스 자동 업그레이드 스킬. 현 하네스 구조를 최신 harness-rules.md 기준으로 진단 → 자동 patch 적용 → 검수 → 유저 확인 후 머지. 인자 없으면 현재 repo, 인자 있으면 대상 repo. /harness-upgrade [대상경로]로 호출.
disable-model-invocation: true
argument-hint: "[대상경로]"
---

# Harness Upgrade

하네스 구조를 최신 `harness-rules.md`와 공식 Claude Code 스펙에 맞춰 자동 업그레이드한다.

**Evaluator-Optimizer 루프**:
- **Evaluator 1**: harness-diff-reporter (진단 리포트)
- **Optimizer**: harness-upgrader (worktree patch 적용)
- **Evaluator 2**: harness-auditor (12+1+2 rubric)
- **최종 머지**: 항상 유저 확인

## 실행 모드

- `/harness-upgrade` — 현재 cwd (harness-factory 자기 repo)
- `/harness-upgrade /path/to/other/repo` — 지정된 repo. rules는 harness-factory repo에서 참조

`$ARGUMENTS`로 전달받은 인자(`$0`)를 **절대 경로로 정규화**해 `HARNESS_TARGET`으로 사용한다.

## 절차

### 0. 사전 조건

스킬 본문의 bash 블록은 각 실행이 독립이다. 값은 파일(`.nova/contracts/orchestrator-state.json`)로 넘긴다.

### 1. 대상 경로 결정 & 정규화

```bash
RAW="${ARG:-}"   # $ARGUMENTS의 첫 인자를 skill runner가 $ARG로 전달한다고 가정
if [ -z "$RAW" ]; then
  TARGET="$(pwd)"
else
  TARGET="$(cd "$RAW" 2>/dev/null && pwd || echo "")"
fi
if [ -z "$TARGET" ] || [ ! -d "$TARGET/.claude" ]; then
  echo "ERROR: 유효하지 않은 경로 또는 .claude/ 없음: $RAW" >&2
  exit 1
fi

# rules 원본(harness-factory) 경로
FACTORY_ROOT="$(cd "$(dirname "${BASH_SOURCE:-$0}")/../../.." 2>/dev/null && pwd)"

# orchestrator 상태를 TARGET 쪽에 기록
mkdir -p "$TARGET/.nova/contracts"
cat > "$TARGET/.nova/contracts/orchestrator-state.json" <<EOF
{
  "harness_target": "$TARGET",
  "factory_root": "$FACTORY_ROOT",
  "phase": "init",
  "scope": "all"
}
EOF
```

### 2. progress.json 상태 초기화 (TARGET 측)

```bash
PROGRESS="$TARGET/.nova/progress.json"
[ -f "$PROGRESS" ] || echo '{"schema_version":3}' > "$PROGRESS"

PROGRESS="$PROGRESS" python3 <<'PY'
import json, os, fcntl
from datetime import datetime, timezone
p = os.environ["PROGRESS"]
with open(p, "r+", encoding="utf-8") as f:
    fcntl.flock(f.fileno(), fcntl.LOCK_EX)
    try:
        f.seek(0)
        try: d = json.load(f)
        except: d = {}
        d.setdefault("schema_version", 3)
        d["upgrade_attempts"] = 0
        d["upgrade_started_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        f.seek(0); f.truncate()
        json.dump(d, f, indent=2, ensure_ascii=False)
    finally:
        fcntl.flock(f.fileno(), fcntl.LOCK_UN)
PY
```

### 3. harness-diff-reporter 호출

**프롬프트에 다음 값을 문자열로 포함**(env 대신):
- `HARNESS_TARGET`: 절대 경로
- `FACTORY_ROOT`: rules 원본 경로
- 리포트 저장 경로: `{HARNESS_TARGET}/.nova/contracts/upgrade-report.md`

```
Agent(harness-diff-reporter):
Task: 하네스 구조를 최신 harness-rules.md 기준으로 진단, 리포트를 stdout으로 출력
Context:
  - HARNESS_TARGET: {절대경로}
  - FACTORY_ROOT: {절대경로}
  (reporter는 읽기 전용 — Write/Edit 금지. 파일 저장은 orchestrator가 담당.)
Constraints: severity 분류, 근거 rules 각주, 제안 patch
Expected Output: stdout에 리포트 본문 전체 + 마지막에 `===SUMMARY===` 블록
Success Criteria: 모든 항목에 severity + 근거 + 제안 patch
Related Known Issues: rules 자체 수정 제안 금지
```

reporter 반환 후 orchestrator가 파일 저장:

```bash
REPORT_PATH="$TARGET/.nova/contracts/upgrade-report.md"
# reporter의 stdout을 REPORT_PATH로 저장 (Agent tool return value를 heredoc·변수로 받아 > 리다이렉트)
```

### 4. 유저에 요약 제시 & scope 수신

reporter의 요약(severity별 건수 + rubric 결과)을 보여주고 유저 선택:

```
1. 전체 자동 적용
2. 특정 항목만 (예: #1,#3,#7)
3. 리포트만 검토하고 종료
```

유저 응답을 `orchestrator-state.json`의 `scope`에 기록 (`all` 또는 `#1,#3` 등).

3번 선택 시 종료. 1/2번이면 5단계로.

### 5. harness-upgrader 호출 (worktree, scope는 프롬프트로)

**worktree 생성은 upgrader가 isolation:worktree로 자동 처리.** 단, orchestrator는 prompt에 다음을 명시:

```
Agent(harness-upgrader):
Task: 리포트 patch를 scope에 따라 worktree에 적용
Context:
  - HARNESS_TARGET: {절대경로}
  - UPGRADE_SCOPE: all  (또는 "#1,#3,#7")
  - 리포트 경로: {HARNESS_TARGET}/.nova/contracts/upgrade-report.md
Constraints:
  - worktree 격리 (frontmatter isolation: worktree)
  - 개별 커밋: "upgrade: #N {severity} {요약}"
  - rules 파일 수정 금지 (훅이 차단)
  - upgrade_attempts 2회 상한
Expected Output: .nova/contracts/upgrade-applied.md + git 커밋
Success Criteria: scope 항목 반영, 자기검증 통과
```

### 6. harness-auditor 호출 (UPGRADE_MODE)

```
Agent(harness-auditor):
Task: worktree의 하네스를 12+1 + ext-1/ext-2 rubric으로 검수
Context:
  - HARNESS_TARGET: {upgrader가 작업한 worktree의 절대경로}
  - UPGRADE_MODE: true
  - UPGRADE_SCOPE: {유저 선택}
  - reporter 출력: .nova/contracts/upgrade-report.md
  - upgrader 출력: .nova/contracts/upgrade-applied.md
Constraints: 읽기 전용, 바이너리 판정
Expected Output: 검수 보고서 (PASS/FAIL), base 브랜치 감지 결과
Success Criteria:
  - HIGH severity FAIL 0건
  - ext-1: scope 항목 반영됨
  - ext-2: rules 파일 보존됨 (또는 SKIP — base 없음)
```

### 7. 재위임 로직

```bash
PROGRESS="$PROGRESS" python3 <<'PY'
import json, os, sys
d = json.load(open(os.environ["PROGRESS"]))
if d.get("upgrade_attempts", 0) >= 2:
    print("ABORT_MAX_RETRIES", file=sys.stderr); sys.exit(1)
PY
```

- PASS → 8단계
- FAIL & attempts < 2 → upgrader 재호출 (이전 FAIL 항목 전달)
- FAIL & attempts ≥ 2 → 유저 에스컬레이션 (worktree 유지)

### 8. 유저 최종 확인 (필수)

```
### 업그레이드 준비 완료
- worktree 브랜치: {branch}
- 적용 커밋: {N}개
- rubric: 12+1 PASS, ext-1 PASS, ext-2 PASS/SKIP

### 변경 요약
{git -C <primary-worktree> diff --stat <base>..<upgrade-branch>}

머지할까요?
1. Squash merge
2. worktree 유지하고 수동 검토
3. worktree 폐기
```

### 9. 머지 (유저가 1 선택 시에만)

**중요**: worktree는 동일 브랜치를 다른 워크트리가 체크아웃하면 실패한다. 머지는 **primary worktree**(최초 repo 경로)에서 실행하고 upgrade-worktree는 머지 후 제거한다.

```bash
PRIMARY="$TARGET"                      # orchestrator 진입점 경로 = primary
UP_BRANCH="$(cat "$TARGET/.nova/contracts/orchestrator-state.json" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("upgrade_branch",""))')"
UP_WORKTREE="$(cat "$TARGET/.nova/contracts/orchestrator-state.json" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("upgrade_worktree",""))')"

# primary에서 base 감지 + checkout
BASE=$(git -C "$PRIMARY" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||' || true)
if [ -z "$BASE" ]; then
  for b in main master trunk; do
    git -C "$PRIMARY" rev-parse --verify "$b" &>/dev/null && BASE="$b" && break
  done
fi

# primary가 이미 base를 체크아웃 중이어야 함 (worktree는 upgrade 브랜치만 사용)
git -C "$PRIMARY" merge --squash "$UP_BRANCH"
git -C "$PRIMARY" commit -m "chore: harness 자동 업그레이드 (scope=$SCOPE, $N개 항목)"

# upgrade worktree 정리
if [ -n "$UP_WORKTREE" ] && [ -d "$UP_WORKTREE" ]; then
  git -C "$PRIMARY" worktree remove "$UP_WORKTREE" --force
fi
# push는 유저가 별도로
```

**upgrader가 orchestrator에게 upgrade_branch·upgrade_worktree 경로를 반환하도록 산출물 형식에 명시되어 있다.** 못 받으면 orchestrator는 `git worktree list`로 탐지.

### 10. 완료 보고

```
### harness-upgrade 결과
- 대상: {TARGET}
- base 브랜치: {BASE}
- reporter: N건 진단
- upgrader: N/M 적용 (scope: {SCOPE})
- auditor: PASS (ext-1 PASS, ext-2 PASS/SKIP)
- 최종: 머지 완료 / worktree 유지 / 폐기
- upgrade_attempts: N/2
```

## 주의사항

- 유저 최종 확인 없이 main 머지 금지 (rules [8] 안전장치)
- `upgrade_attempts > 2`에서 무한 재시도 금지
- rules 파일 수정은 이 스킬의 역할이 아님 → `/rules-updater`
- reporter/upgrader/auditor는 Agent tool로 호출, env 아닌 **프롬프트 문자열로 값 전달**
- skill 본문의 `$ARG`/`$ARGUMENTS`는 skill runner가 제공 (`$0` 등으로 접근)
- 7일 이상 rules 갱신이 없으면 SessionStart hook이 자동 제안
- **primary worktree**가 base(main/master/trunk)를 체크아웃 중이어야 머지가 동작. 기본 cwd 진입 시 해당
