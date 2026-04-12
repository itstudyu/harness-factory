---
name: rules-updater
description: harness-rules.md와 harness-references.md를 최신 공식 문서 및 trusted article 기반으로 갱신하는 유틸리티 스킬. 유저가 새 URL을 제공하거나 AI가 최신 article을 자동 검색하여 반영한다.
---

# Rules Updater

`harness-rules.md`와 `harness-references.md`를 최신 상태로 유지한다.
신뢰할 수 있는 공식 문서와 trusted article을 주기적으로 반영한다.

## 실행 모드

### 모드 1: 기존 URL 갱신

등록된 모든 URL을 재fetch하여 변경사항을 반영한다.

### 모드 2: 새 URL 추가 (유저 제공)

유저가 제공한 URL을 검증 후 references에 추가하고 rules에 반영한다.

### 모드 3: 최신 article 자동 검색

WebSearch로 최신 trusted article을 찾아 제안하고, 유저 승인 후 추가한다.

## 절차

### 1. 모드 선택

유저에게 질문:

```
rules-updater를 어떤 모드로 실행할까요?

1. 기존 URL 전체 갱신 (정기 갱신용)
2. 새 URL 추가 (제공하실 URL이 있나요?)
3. AI가 최신 article 자동 검색
```

### 2. 모드 1: 기존 URL 갱신

```bash
# 기존 URL 추출
grep -oE 'https://[^\s)]+' references/harness-references.md | sort -u
```

각 URL에 대해:
1. WebFetch로 최신 내용 가져오기
2. 핵심 요약 비교 (이전 버전 vs 현재)
3. 차이가 있으면 `harness-references.md` 해당 섹션 업데이트
4. 주요 변경사항을 `harness-rules.md`에 반영

### 3. 모드 2: 새 URL 추가

유저가 URL 제공 시:

```bash
# 신뢰성 검증
python3 << 'EOF'
url = "{유저_제공_URL}"
trusted_domains = [
    "anthropic.com",
    "docs.anthropic.com",
    "code.claude.com",
    "mitchellh.com",
    "simonwillison.net",
    "lilianweng.github.io",
    "openai.com/blog",
    "deepmind.google",
    "karpathy.ai",
    "morphllm.com",
]
is_trusted = any(d in url for d in trusted_domains)
print(f"Trusted: {is_trusted}")
EOF
```

신뢰할 수 있는 도메인이 아니면 유저에게 확인:
```
이 도메인은 기본 신뢰 목록에 없습니다. 
이유와 함께 추가를 진행할까요? (Y/N)
```

승인 후:
1. WebFetch로 내용 가져오기
2. `harness-references.md`에 새 섹션 추가
3. `harness-rules.md`에 핵심 규칙 반영
4. 신뢰 목록에도 추가 (선택적)

### 4. 모드 3: AI 자동 검색

```
WebSearch 쿼리 예시:
- "AI agent harness design 2026"
- "Claude Code best practices new features"
- "prompt caching optimization patterns"
- "multi-agent orchestration evaluator pattern"
```

결과 중 trusted 도메인의 것만 필터링하여 유저에게 제안:
```
다음 새 article을 발견했습니다. 추가할까요?

1. [제목] - {URL} (도메인: anthropic.com) — 핵심 요약
2. ...
```

### 5. harness-rules.md 재압축

references 업데이트 후 반드시:

```bash
# 토큰 수 확인
wc -w references/harness-rules.md

# 2200 words 초과 시 압축 필요
if [ $(wc -w < references/harness-rules.md) -gt 2200 ]; then
  echo "WARN: 토큰 한도 초과. 재압축 필요"
fi
```

압축 원칙:
- 각 섹션당 핵심 3-5 bullet만 유지
- "왜"보다 "무엇을/어떻게"에 집중
- 중복 제거
- 예시는 references로 이동, rules에는 원칙만

### 6. 갱신일 업데이트

```bash
# harness-rules.md의 frontmatter 갱신
TODAY=$(date +%Y-%m-%d)
# last_updated: "..." 라인을 오늘 날짜로 변경
```

### 7. 갱신 이력 기록

`references/harness-references.md`의 "갱신 이력" 테이블에 항목 추가:

```markdown
| 2026-04-13 | 모드 1: 7개 URL 전체 갱신 (변경: 2건) |
| 2026-04-20 | 모드 2: Simon Willison 새 article 추가 |
| 2026-04-27 | 모드 3: AI 자동 검색으로 Karpathy 발표 추가 |
```

## 신뢰 도메인 목록

```yaml
trusted_domains:
  official:
    - anthropic.com
    - docs.anthropic.com
    - code.claude.com
    - openai.com/blog
    - deepmind.google
  individuals:
    - mitchellh.com
    - simonwillison.net
    - lilianweng.github.io
    - karpathy.ai
  companies:
    - morphllm.com
    - huggingface.co/blog
  papers:
    - arxiv.org  # 단, 인용 100회 이상 필요
```

## 보고 형식

```
### rules-updater 실행 결과
- 모드: 1 / 2 / 3
- 갱신된 URL: N개
- 추가된 URL: N개
- harness-rules.md 토큰 수: N words (한도 2200)
- harness-references.md 섹션 수: N개
- 최종 last_updated: YYYY-MM-DD

### 주요 변경사항
- {URL 1}: {변경 요약}
- {URL 2}: {변경 요약}
```

## 주의사항

- 모든 변경 전에 git diff로 차이 확인
- 압축 시 기존 규칙 삭제 전 유저 확인
- AI 자동 검색 결과는 반드시 유저 승인 필요
- 신뢰 도메인이 아닌 경우 반드시 에스컬레이션
