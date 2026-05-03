---
name: best-practices
type: official-doc
url: https://code.claude.com/docs/en/best-practices
publisher: Claude Code Docs
rules_citation: "[8]"
last_analyzed: 2026-05-03
---

# Best Practices — Claude Code Docs [8]

## 한 줄
Claude Code 운영의 **공식 베스트 프랙티스** — Explore→Plan→Code→Commit 워크플로 + 검증 기준의 중요성.

## 핵심 명제

1. **검증 기준이 최고 레버리지**
   > "Include tests, screenshots, or expected outputs so Claude can check itself. **This is the single highest-leverage thing you can do.**"

2. **Explore → Plan → Code → Commit**
   - 탐색과 실행을 분리
   - 큰 기능은 Plan Mode로 계획 후 새 세션에서 실행

3. **Spec-Driven Development**
   - 큰 기능은 SPEC.md 먼저 작성
   - clean context 새 세션에서 구현

4. **CLAUDE.md 간결성 테스트**
   > "이 줄을 삭제하면 실수가 생기는가?" 묻고 아니면 삭제
   > "Bloated CLAUDE.md files cause Claude to ignore your actual instructions."

5. **2회 수정 실패 → 컨텍스트 리셋**
   > "If you've corrected Claude more than twice on the same issue in one session, the context is cluttered with failed approaches."
   - `/rewind` 먼저, 안 되면 `/clear`

6. **Kitchen sink 세션 안티패턴**
   - 무관한 태스크를 한 프롬프트에 혼합 → `/clear`

7. **`--permission-mode auto` (classifier 기반)** — 중간 안전 옵션

## 우리 룰 매핑
- §3 "검증 기준이 최고 레버리지" — 직접 인용
- §3 "CLAUDE.md 간결성 테스트" — 직접 인용
- §3 "Explore → Plan → Code → Commit" — 직접 인용
- §3 "Spec-Driven Development" — 직접 인용
- §4 "2회 수정 실패 → 컨텍스트 리셋" — 직접 인용
- §6 "Kitchen sink 세션" 안티패턴 — 직접 인용
- §6 "전체 자동 승인" 안티패턴 — 직접 인용

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 신규 best practice 발표 시 (가장 빈번 갱신 대상)
- **diff-reporter**: 우리 워크플로가 Explore→Plan→Code→Commit 따르는지 검수
- **CLAUDE.md 갱신 시**: "삭제 가능한 줄" 자동 테스트

## 우리 v2 영향
- planner = Plan Mode 활용
- commander = Code 단계
- 항상 검증 기준 (artifacts, tests) 강제
- CLAUDE.md를 40~50줄로 슬림화 (간결성 테스트 적용)

## 우선순위 액션
1. **현재 CLAUDE.md (66줄) 간결성 테스트** — 삭제 가능한 줄 식별 (1순위)
2. **각 워커에 검증 기준 필수화** — frontmatter에 expected output 명시
3. **`--permission-mode auto` 활용 검토** — 5개 enforce-* 훅 대체
4. **분기별 best practices 페이지 diff 추적**
