---
last_updated: "2026-04-13"
version: "1.0.0"
sources:
  - https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
  - https://www.anthropic.com/engineering/harness-design-long-running-apps
  - https://www.anthropic.com/engineering/managed-agents
  - https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
  - https://code.claude.com/docs/en/sub-agents
  - https://code.claude.com/docs/en/best-practices
  - https://mitchellh.com/writing/my-ai-adoption-journey
---

# Harness Design Rules

## 1. 아키텍처 원칙

- **Harness = OS, Model = CPU, Context = RAM.** Harness는 실행 환경을 제공하고 모델은 연산만 담당한다. Context window는 휘발성 작업 메모리다.
- **3계층 가상화**: Session(상태 유지), Harness(제어 흐름), Sandbox(격리 실행). 각 계층은 독립 교체 가능해야 한다. 모놀리식 결합 금지.
- **Generator와 Evaluator 분리 필수.** 자기 산출물을 자기가 평가하면 편향이 발생한다. 코드 생성과 코드 리뷰는 별도 에이전트가 수행한다.
- **Lazy provisioning.** 컨테이너, worktree, 도구 연결 등 비용이 드는 리소스는 실제 필요 시점에만 할당한다. 세션 시작 시 모든 것을 준비하지 않는다.
- **Sprint 단위 작업.** 하나의 context window에서 전체 기능 구현을 시도하지 않는다. 명확한 경계를 가진 작업 단위로 분할하고, 각 단위는 머지 가능한 상태로 종료한다.

## 2. 에이전트 설계 규칙

- **최소 능력 4가지**: 파일 읽기/쓰기, 프로그램 실행, HTTP 요청, 검증/피드백. 이 중 하나라도 빠지면 자율 작업이 불가능하다.
- **ReAct 루프**: `READ → PLAN → ACT → OBSERVE → CHECKPOINT`. 매 사이클마다 관찰 결과를 기반으로 다음 행동을 결정한다. 관찰 없는 연속 행동 금지.
- **역할별 도구 접근 제어.** Planner는 `disallowedTools: Edit` (Write는 설계 산출물 `.nova/contracts/` 한정), Generator는 `permissionMode: acceptEdits` + `isolation: worktree`, Evaluator는 `disallowedTools: Write, Edit` + `permissionMode: plan`. 역할 분리를 프롬프트가 아닌 도구 수준에서 강제한다.
- **Negative Space 섹션 필수.** 모든 에이전트 정의에 "하지 않는 것"을 명시한다. 경계가 없으면 범위가 무한 확장된다.
- **6-Field Handoff**: Task, Context, Constraints, Expected Output, Success Criteria, Related Known Issues. Sub-agent 호출 시 6개 필드를 모두 채워야 한다.
- **Sub-agent로 연구/탐색/리뷰 위임.** 메인 에이전트의 context를 보호한다. 탐색적 작업은 항상 별도 세션에서 수행한다.
- **세션 종료 계약**: 머지 가능한 코드, 서술적 커밋 메시지, 진행 파일(PROGRESS.md 등) 업데이트. 미완료 상태로 종료하지 않는다.

## 3. 스킬/프롬프트 설계 규칙

- **CLAUDE.md 간결성 테스트**: "이 줄을 삭제하면 실수가 생기는가?" 아니면 삭제한다. 불필요한 지시는 noise다.
- **검증 기준이 최고 레버리지.** 테스트 명령어, 스크린샷 비교, 기대 출력 예시를 제공하면 모델이 스스로 품질을 확인할 수 있다.
- **Spec-Driven Development**: 큰 기능은 먼저 SPEC.md를 작성하고, 새 세션에서 해당 스펙을 입력으로 실행한다. 스펙 작성과 구현을 같은 세션에서 하지 않는다.
- **Feature 목록은 JSON 형식.** Markdown 체크리스트보다 구조화된 JSON이 모델의 조작 저항성이 높다. 항목 추가/삭제/변조가 어렵다.
- **스킬 정의는 `.claude/skills/`에 SKILL.md로.** 필요 시에만 로드하여 context를 절약한다. 모든 스킬을 세션 시작 시 주입하지 않는다.

## 4. 에러 처리 & 복구

- **복구 계층** (우선순위 순): 컨텍스트 재시도 → 체크포인트 롤백 → 태스크 분해 → 인간 에스컬레이션. 상위 단계에서 해결되지 않을 때만 하위로 내려간다.
- **실패 이력 보존.** 실패 로그를 삭제하면 동일 실패를 반복한다. 실패 원인과 시도한 해결책을 파일에 기록한다.
- **세션 시작 시 상태 검증**: 진행 로그 확인 + git 히스토리 점검 + 기본 테스트 실행. 이전 세션의 상태를 가정하지 않는다.
- **2회 수정 실패 규칙.** 동일 이슈에 2번 수정 시도가 실패하면 컨텍스트를 초기화하고 새 세션에서 재시도한다. 오염된 context에서 계속 시도하는 것은 비효율적이다.

## 5. 성능: 캐싱 & 컨텍스트 관리

- **Context window가 1차 제약.** 채워질수록 추론 품질이 저하된다. Context는 비워두는 것이 기본이다.
- **5가지 관리 패턴**: (1) CLAUDE.md로 정적 지식 주입, (2) JIT 검색으로 필요 시 로드, (3) 요약/압축으로 이력 축소, (4) Sub-agent 격리로 탐색 비용 분산, (5) 파일시스템을 외부 메모리로 활용.
- **컨텍스트 리셋 > 압축.** 이어쓰기보다 구조화된 핸드오프 문서를 작성하고 새 세션을 시작하는 것이 품질이 높다.
- **~50회 도구 호출 후 목표 재확인.** 장기 세션에서 주의력이 감쇠한다. 주기적으로 원래 목표를 다시 읽는다.
- **Prompt caching**: 정적 콘텐츠(system prompt, 도구 정의)에 cache breakpoint를 설정한다. 도구 정의를 변경하면 KV-cache가 무효화되므로 도구 목록은 고정한다.
- **캐시 경제성**: 캐시 읽기 비용 = 기본 입력가의 10%. TTL은 5분. 정적 prefix를 길게 유지할수록 비용 절감 효과가 크다.

## 6. 안티패턴

**아키텍처**:
- 단일 컨테이너에 harness + 상태 + 인증을 결합 (교체 불가)
- Context window를 1차 저장소로 사용 (휘발성 메모리에 영구 데이터 보관)

**프롬프트**:
- 무관한 태스크를 하나의 프롬프트에 혼합
- CLAUDE.md 과대화 (noise로 인한 지시 희석)
- 모호한 의도 전달 ("적절히 처리해줘")
- 과잉 명세 연쇄 (모든 단계를 지정하면 오히려 유연성 상실)

**에이전트**:
- 조기 완료 선언 (테스트 미실행 상태에서 "완료")
- 자기 평가 편향 (Generator가 자신의 코드를 리뷰)
- 테스트 없이 완료 보고
- 무한 탐색 (목표 없는 코드 읽기 반복)

**운영**:
- 채팅 인터페이스로 대규모 코딩 시도
- 메가세션 (하나의 세션에서 모든 것을 해결하려는 시도)
- 전체 자동 승인으로 안전장치 건너뛰기

## 7. 파일 형식 규약

### 에이전트 (.claude/agents/*.md)

```yaml
---
name: kebab-case
description: 한국어 설명
tools: Read, Glob, Grep, Bash, Write, Edit
disallowedTools: Edit  # 역할에 따라 제한
model: opus
maxTurns: 30
permissionMode: auto | acceptEdits | plan
isolation: worktree  # Generator만 적용
---
```

Body 필수 섹션: 핵심 정체성, 핵심 원칙, Negative Space, 자기검증, 산출물 형식, 에스컬레이션 조건.

### 스킬 (.claude/skills/*/SKILL.md)

```yaml
---
name: skill-name
description: 한국어 설명
---
```

Body: 절차적 마크다운으로 작성. 실행 가능한 bash 코드 블록을 포함한다.

### 훅 — Shell (.claude/hooks/*.sh)

```bash
#!/usr/bin/env bash
set -euo pipefail
# Exit codes: 0=pass, 1=error, 2=block/feedback
```

### 훅 — Python (.claude/hooks/*.py)

```python
#!/usr/bin/env python3
# stdin: JSON, stdout: JSON
# {"hookSpecificOutput": {"hookEventName": "...", "additionalContext": "..."}}
```
