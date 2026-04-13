---
name: harness-factory
description: 새 프로젝트를 위한 Claude Code 하네스 구조(에이전트, 스킬, 훅)를 자동 생성하는 Orchestrator 스킬. PGE (Planner → Generator → Evaluator) 플로우를 오케스트레이션한다. /harness-factory로 호출.
disable-model-invocation: true
---

# Harness Factory

새 프로젝트를 위한 Claude Code 하네스를 자동 생성한다.
Orchestrator-Workers + Evaluator-Optimizer 패턴(Building Effective Agents)에 따라 설계 → 생성 → 검증 → 재위임 루프.

## 절차

### 1. 유저 정보 수집

```
하네스 생성을 시작합니다. 다음 정보를 알려주세요:

1. **대상 프로젝트 경로** (예: /Users/name/Documents/GitHub/my-project)
2. **프로젝트 목표**
3. **기술 스택** (언어·프레임워크·런타임)
4. **필요한 에이전트 역할** (또는 "자동 설계")
5. **특수 요구사항** (선택)
```

수집한 대상 경로를 환경변수 `HARNESS_TARGET`으로 보존한다.

### 2. 상태 초기화

`.nova/progress.json`에 재위임 카운터 등 세션 state를 기록한다.

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path(".nova/progress.json")
p.parent.mkdir(parents=True, exist_ok=True)
data = {"schema_version": 2, "project": "harness-factory", "retry_count": 0, "max_retries": 2,
        "last_phase": None, "target": None}
p.write_text(json.dumps(data, indent=2))
PY
```

### 3. harness-architect 호출 (6-Field Handoff)

```
Agent(harness-architect):
- Task: "다음 프로젝트를 위한 하네스를 설계하라"
- Context: 수집된 유저 정보 + HARNESS_TARGET
- Constraints: harness-rules.md 준수, PGE 패턴, 공식 frontmatter만(`role:` 금지)
- Expected Output: .nova/contracts/harness-design.md
- Success Criteria: 12항목 rubric 통과 가능한 설계
- Related Known Issues: 순환 위임, permissionMode:plan에 Bash 필요한 Evaluator, 외부 경로 worktree
```

architect는 Flipped Interaction으로 명확화 후 진행.

### 4. 설계 승인 요청

유저 승인 전 다음 단계 진행 금지.

### 5. harness-generator 호출

```
Agent(harness-generator):
- Task: "설계 문서에 따라 하네스 파일을 생성하라"
- Context: .nova/contracts/harness-design.md, HARNESS_TARGET
- Constraints: 템플릿 기반, 공식 frontmatter, worktree는 repo 내부일 때만
- Expected Output: 모든 파일 + 자기검증 통과
- Success Criteria: placeholder 0건, JSON 유효, Negative Space 완비, role 필드 미사용
- Related Known Issues: stdin JSON 훅, chmod 누락, 외부 경로 worktree
```

### 6. harness-auditor 호출

```
Agent(harness-auditor):
- Task: "생성된 하네스를 12+1항목 rubric으로 검수하라"
- Context: HARNESS_TARGET, 설계 문서
- Constraints: 읽기 전용, 바이너리 판정, Bash 사용 가능(permissionMode: default)
- Expected Output: 검수 보고서 (PASS/FAIL)
- Success Criteria: HIGH severity FAIL 0건
```

### 7. 재위임 로직 (Evaluator-Optimizer 루프)

progress.json의 `retry_count`를 기준으로 최대 2회 재위임. 3회 FAIL 시 유저 에스컬레이션.

```bash
python3 - <<'PY'
import json, pathlib, sys
p = pathlib.Path(".nova/progress.json")
d = json.loads(p.read_text())
d["retry_count"] += 1
p.write_text(json.dumps(d, indent=2))
print(d["retry_count"], "/", d["max_retries"])
PY
```

- PASS → 완료 보고
- FAIL & retry_count < max_retries → generator 재호출 (이전 FAIL 항목 전달)
- FAIL & retry_count ≥ max_retries → 유저 에스컬레이션

### 8. 완료 보고

```
### 하네스 생성 완료
- 대상 경로: $HARNESS_TARGET
- 생성 파일: N개
- 검수: PASS
- 재위임: N/2
- 다음 단계: cd $HARNESS_TARGET && claude --agent <primary>
```

## 보고 형식

```
### harness-factory 실행 결과
- 프로젝트: {프로젝트명}
- 설계: 완료 (architect)
- 생성: 완료 (generator, 재시도 N회)
- 검수: PASS / FAIL
- 경과 시간: 약 N분
- 최종 상태: 사용 가능 / 수동 개입 필요
```

## 주의사항

- 유저 승인 없이 생성 단계로 진행 금지
- 3회 FAIL 후 무한 재시도 금지
- architect/generator/auditor는 Agent tool로 호출 (Task tool 아님)
- 대상 경로가 이미 `.claude/`를 포함하면 덮어쓰기 전 확인
- `HARNESS_TARGET`이 현재 repo 바깥이면 generator에 `isolation: worktree`를 요구하지 말 것
