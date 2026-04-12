# Harness Design References

이 문서는 `harness-rules.md`의 원본 소스 상세 분석을 담고 있다.
갱신 시 `/rules-updater` 스킬을 사용한다.

---

## 1. Anthropic: Effective Harnesses for Long-Running Agents
**URL**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

### 핵심 요약
- Harness = OS 메타포: model은 CPU, context window는 RAM, harness는 운영체제
- 3계층 가상화: Session(상태 로그) / Harness(제어 루프) / Sandbox(실행 환경) 분리
- Sandbox를 도구처럼 취급: `execute(name, input) → string` 인터페이스
- 세션 복구: `wake(sessionId)` + `getEvents()`로 상태 복원
- Lazy provisioning으로 TTFT 60-90% 감소

### 적용 가능한 패턴
- 모든 컴포넌트 독립 교체 가능하게 설계
- 상태를 외부 저장소에 보관 (context window ≠ 저장소)
- 샌드박스 실패 시 harness가 도구 호출 에러로 처리

### 인용할 규칙
- "세션, 하네스, 샌드박스를 분리하라"
- "실행 환경을 도구처럼 취급하라"

---

## 2. Anthropic: Harness Design for Long-Running Apps
**URL**: https://www.anthropic.com/engineering/harness-design-long-running-apps

### 핵심 요약
- Agent loop = ReAct: READ → PLAN → ACT → OBSERVE → CHECKPOINT
- 도구 호출 = 함수 시그니처: `name + input → string output`
- Many brains, many hands: 여러 harness가 여러 실행 환경에 접속
- 인증 정보를 샌드박스에 전달하지 않음 — 구조적 분리로 prompt injection 방어

### 적용 가능한 패턴
- 도구 인터페이스 통일: `name + input → string`
- 인증 격리: 토큰은 보안 vault에, 샌드박스는 프록시로만 접근
- 컨테이너 실패 시 모델에게 재시도 결정권

### 인용할 규칙
- "모든 도구는 `name + input → string` 인터페이스를 따른다"
- "인증 정보는 구조적으로 격리한다"

---

## 3. Anthropic: Managed Agents
**URL**: https://www.anthropic.com/engineering/managed-agents

### 핵심 요약
- Generator/Evaluator 분리: 에이전트는 자기 산출물을 일관되게 과대평가
- Evaluator에 구체적 rubric 제공 — "품질 확인" 같은 모호한 지시 금지
- Evaluator drift 감지: 연속 PASS 횟수 추적, 임계값(10) 초과 시 경고
- Sprint 단위: 한 context window에서 전체 구현 시도하면 조기 완료 선언
- Feature 목록을 JSON으로 관리 (Markdown보다 모델 조작 저항성 높음)

### 적용 가능한 패턴
- PGE (Planner-Generator-Evaluator) 아키텍처
- Rubric 기반 바이너리 판정 (PASS/FAIL, 모호한 점수 금지)
- Sprint contract: 사전에 완료 기준 합의
- 재위임 상한 설정 (무한 루프 방지)

### 인용할 규칙
- "Generator와 Evaluator를 분리하라"
- "Evaluator에 구체적 rubric을 제공하라"
- "Feature 목록은 JSON으로 관리하라"

---

## 4. Anthropic: Prompt Caching
**URL**: https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching

### 핵심 요약
- 캐시 읽기 = 기본 입력가의 10%, 캐시 쓰기 = 125% (5분 TTL) 또는 200% (1시간 TTL)
- Agent 워크로드: ~100:1 prefill 대 decode 비율 → 캐시 효율이 핵심 성능 지표
- Breakpoint를 정적 콘텐츠 끝에 배치: `tools → system instructions → messages`
- 최소 임계값: 모델에 따라 1024-4096 토큰
- 도구 정의를 대화 중 변경하면 전체 캐시 계층 무효화
- 자동 캐싱: top-level `cache_control` 설정 시 breakpoint 자동 이동

### 적용 가능한 패턴
- `harness-rules.md`를 SessionStart에서 주입 → 정적 콘텐츠로 캐시됨
- 도구 정의를 세션 중 수정하지 않음
- 20블록 lookback window 초과 시 중간 breakpoint 추가

### 인용할 규칙
- "정적 콘텐츠에 캐시 breakpoint를 배치하라"
- "도구 정의를 대화 중 변경하지 마라"

---

## 5. Claude Code: Sub-agents
**URL**: https://code.claude.com/docs/en/sub-agents

### 핵심 요약
- Sub-agent = 전용 context window로 작업 위임
- `.claude/agents/*.md`로 정의: YAML frontmatter + markdown body
- Frontmatter 필드: `name`, `description`, `tools`, `disallowedTools`, `model`, `maxTurns`, `permissionMode`, `isolation`
- `isolation: worktree`로 git 안전성 확보
- Sub-agent는 요약만 반환 — 메인 에이전트 context 오염 방지
- 비용 제어: 읽기 전용 태스크는 haiku 모델로 라우팅 가능

### 적용 가능한 패턴
- Agent tool로 서브에이전트 직접 호출
- description을 명확히 작성하여 orchestrator가 적절한 시점에 위임
- Generator에 `isolation: worktree` 적용
- Evaluator에 `permissionMode: plan` + `disallowedTools: Write, Edit`

### 인용할 규칙
- "서브에이전트로 탐색/연구/리뷰를 위임하라"
- "메인 에이전트의 context를 보호하라"

---

## 6. Claude Code: Best Practices
**URL**: https://code.claude.com/docs/en/best-practices

### 핵심 요약
- CLAUDE.md를 간결하게 유지 — 각 줄에 대해 "삭제하면 실수가 생기는가?" 확인
- 탐색 → 계획 → 구현 → 검증 순서
- 검증 기준이 가장 높은 레버리지: 테스트, 스크린샷, 기대 출력 제공
- 무관한 태스크 사이에 `/clear`로 컨텍스트 초기화
- Plan Mode로 탐색과 변경을 분리
- Spec-Driven Development: 큰 기능은 SPEC.md 작성 후 새 세션에서 실행

### 적용 가능한 패턴
- CLAUDE.md에는 Claude가 코드에서 유추할 수 없는 정보만 기록
- 복잡한 태스크는 Plan Mode → Spec → 새 세션 순서
- 검증 기준을 모든 위임에 포함

### 인용할 규칙
- "CLAUDE.md는 간결하게 — 유추 가능한 내용은 제외하라"
- "검증 기준 제공이 가장 높은 레버리지이다"

---

## 7. Mitchell Hashimoto: My AI Adoption Journey
**URL**: https://mitchellh.com/writing/my-ai-adoption-journey

### 핵심 요약
- 최소 에이전트 능력: 파일 읽기/쓰기, 프로그램 실행, HTTP 요청, 검증/피드백
- Initializer vs Executor 에이전트 분리: 초기 설정과 점진적 작업을 다른 에이전트로
- Test-First (Red/Green): 실패하는 테스트 먼저 → 에이전트가 진단 → 구현 → 통과
- 단일 기능 집중: 한 세션에 한 기능만 (여러 기능 시도 → 맥락 고갈)
- 세션 종료 계약: 머지 가능한 코드 + 서술적 커밋 + 진행 파일 업데이트
- 2회 수정 실패 시 컨텍스트 초기화 후 재시도 (오류 이력이 컨텍스트를 오염)

### 적용 가능한 패턴
- Initializer/Executor 분리 (harness-architect vs harness-generator)
- 6-Field Handoff Bundle로 위임 품질 보장
- 세션 시작 시 상태 검증 프로토콜 (init.sh)
- known-issues.json으로 반복 실패 패턴 등록

### 인용할 규칙
- "한 세션에 한 기능만 집중하라"
- "세션 종료 시 머지 가능한 코드를 남겨라"
- "2회 실패 후 컨텍스트를 초기화하라"

---

## 추가 소스

### Simon Willison: Agentic Engineering Patterns
- 에이전트 워크로드의 100:1 prefill-to-decode 비율 → KV-cache 효율이 핵심
- 추론 흔적(reasoning trace) 삭제 시 ~30% 성능 저하
- 전체 코드베이스를 미리 로드하지 말 것 — 경량 참조 + 주문형 로드

### MorphLLM: Agent Engineering Primer
- ~50회 도구 호출 후 목표 재확인으로 주의력 감쇠 대응
- 압축보다 컨텍스트 리셋이 효과적 (구조화된 핸드오프로 새 세션)
- 알림/인터럽트 비용이 높음 — 인간이 인터럽트 타이밍 통제

---

## 신뢰할 수 있는 소스 판단 기준

새 소스를 추가할 때 다음 기준을 만족해야 한다:

1. **공식 문서**: anthropic.com, docs.anthropic.com, code.claude.com
2. **검증된 개인 블로그**: Mitchell Hashimoto, Simon Willison, Lilian Weng, Andrej Karpathy 등
3. **메이저 AI 기업 엔지니어링 블로그**: OpenAI, Google DeepMind, DeepSeek 공식 블로그
4. **피어 리뷰 또는 인용 많은 논문**: arXiv에 게재되고 엔지니어링 커뮤니티에서 널리 인용된 것
5. **메이저 컨퍼런스 발표**: NeurIPS, ICML, ICLR 등 발표 자료

**제외 기준**:
- 익명 블로그, 광고성 콘텐츠
- 검증되지 않은 Twitter/X 스레드 (단, 공식 계정 제외)
- 오래된 자료 (3개월 이상 경과한 beta API 관련 자료)

---

## 갱신 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2026-04-13 | 초기 작성 — 7개 URL + 2개 추가 소스 분석 |
