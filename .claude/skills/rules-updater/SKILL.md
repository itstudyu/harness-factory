---
name: rules-updater
description: harness-rules.md와 harness-references.md를 최신 공식 문서 및 trusted article 기반으로 갱신한다. 유저가 새 URL을 제공하거나 AI가 WebSearch로 최신 article을 검색해 반영한다.
disable-model-invocation: true
---

# Rules Updater

`harness-rules.md`와 `harness-references.md`를 최신 상태로 유지한다.

## 실행 모드

1. **기존 URL 갱신** — 등록된 모든 URL 재fetch
2. **새 URL 추가** — 유저 제공 URL 검증 후 추가
3. **AI 자동 검색** — WebSearch로 최신 trusted article 제안

## 절차

### 0. 출처 유형 판별

새 URL이나 자동 검색 결과를 처리할 때 먼저 출처 유형을 분기한다:

```bash
URL="{후보_URL}"
case "$URL" in
  *github.com/*/*)
    KIND="community_repo"   # GitHub 저장소 → 섹션 G 절차
    ;;
  *anthropic.com*|*docs.anthropic.com*|*platform.claude.com*|*code.claude.com*|*openai.com*|*deepmind.google*)
    KIND="official"         # 공식 문서 → 모드 1·2 일반 절차
    ;;
  *)
    KIND="article"          # 개인/회사 블로그 등 → 모드 1·2 일반 절차
    ;;
esac
```

`KIND=community_repo`이면 섹션 G의 GitHub repo 등재 절차를 적용한다.

### 1. 모드 선택

```
rules-updater를 어떤 모드로 실행할까요?
1. 기존 URL 전체 갱신
2. 새 URL 추가 (URL을 제공해주세요)
3. AI가 최신 article 자동 검색
```

### 2. 모드 1: 기존 URL 갱신

```bash
grep -oE 'https://[^\s)]+' references/harness-references.md | sort -u
```

각 URL에 대해:
1. WebFetch로 최신 내용 수집
2. 핵심 요약 비교 (이전 vs 현재)
3. 차이 있으면 `harness-references.md` 해당 섹션 업데이트
4. 주요 변경을 `harness-rules.md`에 반영하며 **각 항목에 출처 각주 번호 유지**

### 3. 모드 2: 새 URL 추가

```bash
python3 - <<'PY'
url = "{유저_제공_URL}"
trusted = ["anthropic.com","docs.anthropic.com","platform.claude.com","code.claude.com",
           "mitchellh.com","simonwillison.net","lilianweng.github.io",
           "openai.com/blog","deepmind.google","karpathy.ai","morphllm.com",
           "github.com"]
is_github = "github.com/" in url
print("Trusted:", any(d in url for d in trusted))
print("is_github:", is_github)
PY
```

신뢰 도메인 아니면 유저에게 사유 질의 후 승인.
승인되면 WebFetch → references에 새 섹션 추가 → rules에 핵심 규칙 반영(출처 번호 부여).
**`is_github=True`이면 일반 article 절차 대신 섹션 G(GitHub repo 등재 절차)를 따른다.**

### 4. 모드 3: AI 자동 검색

WebSearch 쿼리 예시: `AI agent harness design 2026`, `Claude Code best practices`, `prompt caching patterns`, `evaluator-optimizer pattern`.

trusted 도메인 필터 후 유저에게 제안.

### 5. 변경 검증

```bash
# 현재 크기 확인 (하드 한도가 아니라 캐시/context 예산 관점의 예산)
wc -w references/harness-rules.md
wc -c references/harness-rules.md

# rules.md의 각 섹션은 출처 각주 번호 [n]과 매핑되어야 함
grep -nE '\[[0-9]+\]' references/harness-rules.md | head -30
```

단어 수 경계는 하드 한도가 아니다. 기준은 두 가지:
- **Caching 관점**: rules는 CLAUDE.md import로 system 계층에 들어가므로 자주 바뀌면 캐시 무효화. 한 번 정한 뒤 변경 빈도를 낮게 유지한다.
- **Signal-to-noise**: "이 줄을 지우면 실수가 생기는가?"를 모든 bullet에 적용. 해당 안 되면 제거(Best Practices #8).

### 6. 갱신일 / 이력

```bash
TODAY=$(date +%Y-%m-%d)
# references/harness-rules.md frontmatter last_updated을 $TODAY로
# references/harness-references.md 갱신 이력 테이블에 1줄 추가
```

## 신뢰 도메인

```yaml
trusted_domains:
  official:
    - anthropic.com
    - docs.anthropic.com
    - platform.claude.com
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
    - arxiv.org  # 인용 100회 이상 권장
  community_repos:
    - github.com  # 섹션 G 절차로 등재. ★ 1k 이상 + 활발한 유지보수 권장
```

## G. GitHub repo 등재 절차

`KIND=community_repo`로 판별된 GitHub 저장소를 references/rules에 추가할 때만 사용한다.

### G.1 사전 검증

```bash
URL="{후보_URL}"  # https://github.com/{owner}/{repo}
OWNER_REPO=$(echo "$URL" | sed -E 's|https?://github.com/([^/]+/[^/]+).*|\1|')

# 메타데이터 수집 (gh CLI 우선, 없으면 API 직접 호출)
if command -v gh &>/dev/null; then
  gh repo view "$OWNER_REPO" --json name,stargazerCount,licenseInfo,pushedAt,defaultBranchRef
else
  curl -sSL "https://api.github.com/repos/$OWNER_REPO" \
    | python3 -c 'import json,sys; d=json.load(sys.stdin); print({k:d.get(k) for k in ["full_name","stargazers_count","license","pushed_at","default_branch"]})'
fi
```

기준:
- ★ 1,000 이상 권장 (예외 시 사유 명시)
- license가 OSI-approved (Apache-2.0/MIT/BSD/MPL 등). proprietary/no-license는 거절
- 최근 6개월 내 commit (pushed_at 확인)
- README가 영어 또는 한국어로 명확한 아키텍처 설명 포함

### G.2 인용 무결성 — SHA + 줄 번호 고정

community repo는 main 브랜치가 변경되므로 인용 시 **commit SHA + 파일 경로 + 줄 번호**를 고정한다:

```bash
# 최신 default branch의 HEAD SHA
SHA=$(curl -sSL "https://api.github.com/repos/$OWNER_REPO/commits/HEAD" \
      | python3 -c 'import json,sys; print(json.load(sys.stdin)["sha"][:7])')

# permalink 형식 (줄 번호 포함)
echo "https://github.com/$OWNER_REPO/blob/$SHA/path/to/file.md#L10-L25"
```

references에 기록할 때:

```markdown
15. {owner}/{repo} — https://github.com/{owner}/{repo} ({license}, ★ {stars}, {YYYY-MM-DD} 확인 @ {SHA}). {핵심 요약}. 공식 문서 충돌 시 공식 우선.
```

### G.3 충돌 정책

- 공식 문서(anthropic.com / code.claude.com 등)와 충돌하면 **공식이 우선**
- community repo의 패턴이 공식 스펙을 보강(공식이 침묵)하는 경우에만 rules에 반영
- 인용 시 항상 "공식 문서 충돌 시 공식 우선" 문구를 함께 명시

### G.4 갱신 주기

- 모드 1(전체 갱신) 실행 시 community_repo 항목은 **SHA를 다시 fetch**해 변경 감지
- SHA가 바뀐 경우 인용한 줄 번호의 의미 변화 여부를 수동 확인 후 references 업데이트

## 보고 형식

```
### rules-updater 실행 결과
- 모드: 1 / 2 / 3
- 갱신된 URL: N개
- 추가된 URL: N개
- rules.md: N words / N bytes
- 최종 last_updated: YYYY-MM-DD

### 주요 변경사항
- {URL}: {변경 요약}
```

## 주의사항

- 모든 변경 전 git diff로 차이 확인
- 기존 규칙 삭제 전 유저 확인
- AI 자동 검색 결과는 반드시 유저 승인
- 신뢰 도메인이 아니면 에스컬레이션
- rules의 각 항목에 출처 번호가 매핑되는지 반드시 확인 — 출처 미매핑 항목 추가 금지
