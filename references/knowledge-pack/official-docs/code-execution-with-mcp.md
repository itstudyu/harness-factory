---
name: code-execution-with-mcp
type: official-doc
url: https://www.anthropic.com/engineering/code-execution-with-mcp
publisher: Anthropic Engineering
rules_citation: "[14]"
last_analyzed: 2026-05-03
---

# Code Execution with MCP — Anthropic Engineering [14]

## 한 줄
**MCP 도구를 모델 context에 직접 로드 안 하고** `./servers/<name>/` 파일시스템으로 노출 → 토큰 98.7% 절감.

## 핵심 명제

1. **온디맨드 로드 패턴**
   - 모든 MCP 도구를 세션 시작 시 로드 ❌
   - 파일시스템 구조로 노출 → 필요한 것만 코드에서 import

2. **사례: 10,000행 스프레드시트**
   - 전부 노출: 150,000 tokens
   - 코드에서 필터링: 2,000 tokens
   - **절감: 98.7%**

3. **Privacy-preserving intermediate results**
   > "중간 결과는 실행 환경에만 머물고 명시적으로 로그·반환된 것만 모델로 전달."

## 우리 룰 매핑
- §5 "Code Execution with MCP로 토큰 절감" — 직접 인용 (98.7% 사례)
- §5 "Privacy-preserving intermediate results" — 직접 인용
- §6 "모든 MCP 도구 정의를 세션 시작 시 로드 → context bloat" 안티패턴

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 신규 MCP 패턴 발표 시
- **v2 redesign**: 우리 워커가 대용량 데이터 다룰 때 이 패턴 강제

## 우리 v2 영향
- 워커가 대형 reference 파일 다룰 때:
  - ❌ 전체 컨텍스트에 로드
  - ✅ 코드(grep/jq)로 필요 부분만 추출
- knowledge-pack/INDEX.md를 grep-friendly로 작성한 이유
- 향후 우리 자체 MCP server 만들 시 이 패턴 적용

## 우선순위 액션
1. **워커 도구 목록 점검** — 큰 데이터 다룰 때 코드 활용 강제 (1순위)
2. **knowledge-pack 검색 시 grep 우선** — vector embedding 도입 보류
3. **분기별 MCP 표준 변경 추적** (modelcontextprotocol.io)

## 핵심 인용
> "MCP 도구를 모델 context에 직접 로드하지 않고 `./servers/<name>/` 식 파일시스템 구조로 노출 → 필요한 것만 on-demand 로드"
> "10,000행 스프레드시트 → 150,000 토큰 vs 2,000 토큰 (98.7% 절감)"
