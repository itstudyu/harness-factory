---
name: harness-factory
description: 새 프로젝트를 위한 Claude Code 하네스 구조(에이전트, 스킬, 훅)를 자동 생성하는 메인 스킬. 유저 요구사항 수집 → 설계 → 생성 → 검증의 PGE 플로우를 오케스트레이션한다. /harness-factory로 호출한다.
---

# Harness Factory

새 프로젝트를 위한 Claude Code 하네스를 자동 생성한다.
PGE (Planner-Generator-Evaluator) 패턴에 따라 설계 → 생성 → 검증의 3단계로 진행된다.

## 절차

### 1. 유저 정보 수집

유저에게 다음을 질문한다:

```
하네스 생성을 시작합니다. 다음 정보를 알려주세요:

1. **대상 프로젝트 경로** (예: /Users/name/Documents/GitHub/my-project)
2. **프로젝트 목표** (무엇을 하는 프로젝트인가?)
3. **기술 스택** (언어, 프레임워크, 런타임 버전)
4. **필요한 에이전트 역할** (또는 "자동 설계"를 선택하면 AI가 PGE 최소 구성 제안)
5. **특수 요구사항** (도메인 규칙, 제약 조건 등 — 없으면 skip)
```

### 2. harness-architect 호출

```
Agent(harness-architect)에게 위임:
- Task: "다음 프로젝트를 위한 하네스를 설계하라"
- Context: 수집된 유저 정보
- Constraints: harness-rules.md 준수, PGE 패턴 강제
- Expected Output: .nova/contracts/harness-design.md
- Success Criteria: 12개 체크리스트 통과 가능한 설계
- Related Known Issues: 순환 위임, 역할 침범 방지
```

architect는 Flipped Interaction으로 요구사항을 명확화하며 진행한다.

### 3. 설계 승인 요청

architect가 반환한 설계 문서를 유저에게 보여주고:

```
설계가 완료되었습니다. 승인하시면 생성을 시작합니다.
- 에이전트: N개
- 스킬: N개  
- 훅: N개

승인하시겠습니까? 또는 수정할 부분이 있나요?
```

유저 승인 전에는 다음 단계로 진행하지 않는다.

### 4. harness-generator 호출

```
Agent(harness-generator)에게 위임:
- Task: "설계 문서에 따라 하네스 파일을 생성하라"
- Context: 설계 문서 경로, 대상 프로젝트 경로
- Constraints: 템플릿 기반, 설계 충실성, worktree 격리
- Expected Output: 모든 파일 생성 + 자기검증 통과
- Success Criteria: placeholder 0건, JSON 유효, 필수 필드 완비
- Related Known Issues: placeholder 잔여, chmod 누락
```

### 5. harness-auditor 호출

```
Agent(harness-auditor)에게 위임:
- Task: "생성된 하네스를 12항목 rubric으로 검수하라"
- Context: 대상 경로, 설계 문서
- Constraints: 읽기 전용, 바이너리 판정
- Expected Output: 검수 보고서 (PASS/FAIL)
- Success Criteria: HIGH severity FAIL 0건
- Related Known Issues: evaluator drift
```

### 6. 결과 판정 및 재위임 로직

```bash
# 재위임 카운터 초기화
RETRY_COUNT=0
MAX_RETRIES=2

if [ "$RESULT" = "PASS" ]; then
  echo "완료 보고"
elif [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; then
  # generator에 FAIL 항목을 전달하여 재위임
  RETRY_COUNT=$((RETRY_COUNT + 1))
  # Agent(harness-generator) 재호출
else
  # 3회 FAIL — 유저 에스컬레이션
  echo "3회 FAIL — 수동 개입이 필요합니다"
fi
```

### 7. 완료 보고

최종 결과를 유저에게 보고:

```
### 하네스 생성 완료
- 대상 경로: {경로}
- 생성 파일: N개
- 검수 결과: PASS
- 재위임 횟수: N/2

다음 단계:
- cd {경로}
- claude --agent {primary-agent}
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
- architect/generator/auditor는 반드시 Agent tool로 호출 (Task tool 아님)
- 대상 경로가 이미 `.claude/` 폴더를 가지고 있으면 확인 후 진행
