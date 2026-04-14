---
name: harness-upgrade
description: 하네스 자동 업그레이드 스킬. 현 하네스 구조를 최신 harness-rules.md 기준으로 진단 → 자동 patch 적용 → 검수 → 유저 확인 후 머지. 인자 없으면 현재 repo, 인자 있으면 대상 repo. /harness-upgrade [대상경로]로 호출.
disable-model-invocation: true
argument-hint: "[대상경로]"
---

# Harness Upgrade

하네스 구조를 최신 `harness-rules.md`와 공식 Claude Code 스펙에 맞춰 자동 업그레이드한다.

**Evaluator-Optimizer 루프** ([3] Building Effective Agents):
- **Evaluator**: harness-diff-reporter (진단 리포트) + harness-auditor (적용 검수)
- **Optimizer**: harness-upgrader (worktree에서 patch 적용)
- **최종 머지**: **항상 유저 확인** (자동화지만 destructive 머지 전엔 반드시 1회 확인)

## 실행 모드

### A. 자기 repo 업그레이드
```
/harness-upgrade
```
→ 현재 cwd(harness-factory repo)를 대상

### B. 타 repo 업그레이드
```
/harness-upgrade /path/to/other/repo
```
→ 지정된 경로를 대상. rules는 현 harness-factory에서 가져옴

## 절차

### 1. 대상 경로 결정

```bash
TARGET="${1:-$(pwd)}"
if [ ! -d "$TARGET/.claude" ]; then
  echo "ERROR: $TARGET에 .claude/ 디렉토리가 없습니다. 먼저 /harness-factory로 하네스를 생성하세요." >&2
  exit 1
fi
export HARNESS_TARGET="$TARGET"
echo "대상: $HARNESS_TARGET"
```

### 2. progress 상태 초기화

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path(".nova/progress.json")
p.parent.mkdir(parents=True, exist_ok=True)
d = {}
if p.exists():
    try: d = json.loads(p.read_text())
    except: d = {}
d.setdefault("schema_version", 2)
d.setdefault("project", "harness-factory")
d["upgrade_attempts"] = 0
d["upgrade_started_at"] = __import__("datetime").datetime.utcnow().strftime("%Y-%m-%d")
p.write_text(json.dumps(d, indent=2))
PY
```

### 3. harness-diff-reporter 호출 (Evaluator 1)

```
Agent(harness-diff-reporter):
- Task: "대상의 하네스 구조를 최신 harness-rules.md 기준으로 진단하고 severity 있는 리포트를 생성하라"
- Context: HARNESS_TARGET, rules 파일 경로
- Constraints: 읽기 전용, severity 분류, 각 항목에 근거 rules 각주
- Expected Output: stdout에 upgrade-report 전문. 오케스트레이터가 .nova/contracts/upgrade-report.md로 저장
- Success Criteria: 모든 항목에 severity + 근거 + 제안 patch
- Related Known Issues: rules 자체 수정 제안 금지 (rules-updater 영역), 자기 평가 편향
```

반환된 리포트를 파일로 저장:
```bash
mkdir -p .nova/contracts
# (reporter의 stdout을 오케스트레이터가 heredoc으로 저장)
```

### 4. 리포트 유저 제시

리포트의 **요약 부분만** 유저에게 보여줌:
```
### 진단 결과
- 총 N건 발견 (MISSING: N, WARN: N, SUGGEST: N, INFO: N)
- 12+1 rubric: PASS / FAIL (N건)

전체 리포트: .nova/contracts/upgrade-report.md

어떻게 진행할까요?
1. 전체 자동 적용 후 최종 머지 시 확인
2. 특정 항목만 적용 (예: #1,#3,#7)
3. 리포트만 검토하고 종료
```

유저 선택에 따라 `UPGRADE_SCOPE` 환경변수 설정.

### 5. harness-upgrader 호출 (Optimizer, worktree)

```
Agent(harness-upgrader):
- Task: "리포트의 patch를 UPGRADE_SCOPE에 따라 worktree에 적용하라"
- Context: .nova/contracts/upgrade-report.md, HARNESS_TARGET, UPGRADE_SCOPE
- Constraints: worktree 격리, 개별 커밋, main 직접 수정 금지, rules 파일 건드리지 않음
- Expected Output: 적용 로그 + .nova/contracts/upgrade-applied.md
- Success Criteria: 리포트 항목 반영, 자기검증 통과
- Related Known Issues: 자기 평가 편향 (auditor가 별도 검수), upgrade_attempts 2회 상한
```

### 6. harness-auditor 호출 (Evaluator 2)

```
Agent(harness-auditor):
- Task: "worktree의 하네스를 12+1 rubric + 업그레이드 확장 rubric으로 검수하라"
- Context: worktree 경로, upgrade-report.md, upgrade-applied.md
- Constraints: 읽기 전용, 바이너리 판정
- Expected Output: 검수 보고서 (PASS/FAIL)
- Success Criteria:
  - HIGH severity FAIL 0건
  - upgrade-report.md의 MISSING/WARN 항목 중 scope 내 항목이 전부 반영됨
- Related Known Issues: evaluator drift, self-approval
```

### 7. 재위임 로직

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path(".nova/progress.json")
d = json.loads(p.read_text())
if d["upgrade_attempts"] >= 2:
    print("ABORT: 2회 재시도 상한 도달. 유저 에스컬레이션.")
PY
```

- PASS → 8단계로
- FAIL & attempts < 2 → harness-upgrader 재호출 (이전 FAIL 항목 전달)
- FAIL & attempts ≥ 2 → 유저 에스컬레이션 (worktree 유지, 수동 검토 권장)

### 8. 유저 최종 확인 (필수)

```
### 업그레이드 준비 완료

worktree 브랜치: {branch}
적용된 커밋: {N}개
12+1 rubric: PASS
업그레이드 확장 rubric: PASS

### 변경 요약
{git diff --stat main..HEAD}

main에 머지할까요?
1. 머지 (squash merge 권장)
2. worktree 유지하고 수동 검토
3. worktree 폐기
```

### 9. 머지 (유저가 1 선택 시에만)

```bash
git checkout main
git merge --squash {upgrade-branch}
git commit -m "chore: harness v{VERSION} 자동 업그레이드 (N개 항목 반영)"
# push는 유저가 별도로
```

### 10. 완료 보고

```
### harness-upgrade 실행 결과
- 대상: {TARGET}
- 진단 (reporter): N건
- 적용 (upgrader): N/M (scope: {SCOPE})
- 검수 (auditor): PASS
- 최종 상태: 머지 완료 / worktree 유지 / 폐기
- upgrade_attempts: N/2
```

## 보고 형식

```
### harness-upgrade 최종 결과
- rules version: {현재}
- 대상 경로: {TARGET}
- 진단 → 적용 → 검수 → 머지: {각 단계 상태}
- 경과 시간: 약 N분
```

## 주의사항

- 유저 최종 확인 없이 main 머지 금지 (destructive 안전장치 — rules [8])
- upgrade_attempts 2회 초과 시 무한 재시도 금지
- rules.md·references 파일 수정은 이 스킬의 역할이 아님 → `/rules-updater` 사용
- reporter/upgrader/auditor는 Agent tool로 호출
- 타 repo 업그레이드 시 대상의 `.claude/` 구조를 먼저 확인하고 없으면 `/harness-factory` 안내
- 7일 이상 rules 갱신이 없으면 SessionStart 훅이 자동으로 이 스킬 실행을 제안함
