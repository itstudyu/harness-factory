---
name: effective-harnesses
type: official-doc
url: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
publisher: Anthropic Engineering
rules_citation: "[2]"
last_analyzed: 2026-05-03
---

# Effective Harnesses for Long-Running Agents — Anthropic Engineering [2]

## 한 줄
**장기 실행 하네스 설계의 공식 가이드**. 메가세션 안티패턴 + sprint 단위 분해.

## 핵심 명제
1. **Sprint 단위 작업** (Mitchell Hashimoto가 [9]에서 인용)
   > "Don't try to 'draw the owl' in one mega session."

2. **에이전트 능력의 최소 집합**
   - 파일 읽기
   - 프로그램 실행
   - HTTP 요청
   - **검증 피드백** ("a way to verify its work")

3. **세션 종료 계약**
   - 머지 가능한 코드
   - 서술적 커밋
   - 다음 세션을 위한 명확한 산출물

## 우리 룰 매핑
- §1 마지막 "Sprint 단위 작업" — 직접 인용
- §2 첫 항목 "에이전트 능력의 최소 집합" — 직접 인용
- §2 마지막 "세션 종료 계약" — 직접 인용

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 장기 실행 패턴 갱신 시
- **diff-reporter**: 우리 워커가 메가세션 안티패턴에 빠졌는지 점검

## 우리 v2 영향
- planner가 task를 sprint 단위로 분해
- commander가 worker 위임 시 명확한 종료 계약 (artifacts) 강제
- 각 worker는 verification 단계 필수

## 우선순위 액션
1. **검증 피드백 메커니즘** v2 워커 정의 시 필수 항목으로
2. sprint 분해 가이드라인 planner 프롬프트에 반영
