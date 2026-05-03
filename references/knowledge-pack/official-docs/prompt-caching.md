---
name: prompt-caching
type: official-doc
url: https://platform.claude.com/docs/en/docs/build-with-claude/prompt-caching
publisher: Anthropic Platform
rules_citation: "[4]"
last_analyzed: 2026-05-03
---

# Prompt Caching — Claude Platform [4]

## 한 줄
프롬프트 캐싱 공식 가이드 — **5분 / 1시간 TTL, breakpoint 4개, 자동 lookback 20**.

## 핵심 명제
1. **캐시 prefix 순서**: `tools → system → messages`
2. **도구 정의가 바뀌면 전체 캐시 무효화** → 도구 목록은 고정
3. **Breakpoint 최대 4개**, 자동 lookback window 20 블록
4. **캐시 비용**:
   - 읽기: 기본 입력가 × 0.1
   - 5분 TTL 쓰기: × 1.25
   - 1시간 TTL 쓰기: × 2

## 모델별 최소 캐시 토큰
| 모델 | 최소 토큰 |
|---|---|
| Mythos Preview / Opus 4.7 / 4.6 / 4.5 / Haiku 4.5 / Haiku 3 | 4096 |
| Sonnet 4.6 / Haiku 3.5 | 2048 |
| Sonnet 4.5 / Opus 4.1 / 4 / Sonnet 4 / 3.7 | 1024 |

## Automatic Caching
- `cache_control` request-level
- multi-turn 대화 시 breakpoint 자동 전진

## 우리 룰 매핑
- §5 "Prompt caching 계층" — 직접 인용
- §5 "캐시 비용" — 직접 인용

## /harness-upgrade가 참조해야 할 시점
- **rules-updater**: 새 모델 추가 시 (Mythos 후속 등) 최소 토큰 표 갱신
- **분기 갱신**: 모델별 가격 변동

## 우리 v2 영향
- 워커 system prompt를 **고정** + 입력만 변경 → 캐시 적중 극대화
- harness-rules.md import는 모든 에이전트에서 동일 → 캐시 prefix 공유

## 우선순위 액션
1. **모델 목록 분기별 갱신**
2. 우리 워커 system prompt 길이가 최소 토큰 충족하는지 점검
3. Automatic caching 동작 검증
