---
name: voltagent-subagents
tier: 1
stars: 18900
url: https://github.com/VoltAgent/awesome-claude-code-subagents
license: unknown
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
---

# VoltAgent/awesome-claude-code-subagents

## 한 줄
**131개+ Claude Code subagent 컬렉션**. 카테고리 9개 plugin으로 묶임. ★18.9k.

## 자기소개 (원문 발췌)
> "The awesome collection of Claude Code subagents."
>
> "This repository serves as the definitive collection of Claude Code subagents, specialized AI assistants designed for specific development tasks."

## 우리 프로젝트와의 관련성
**핵심 가치**: 우리 PGE 3에이전트(planner/generator/evaluator)에 가장 가까운 패턴이 이 131개 중 어떤 것인지 즉시 확인. v2에서 사용자가 "워커 추가"를 할 때 **이 컬렉션의 frontmatter 형식이 우리 표준이 됨**.

## 핵심 차용 가능 요소

### 1. **카테고리 9개 plugin 구조**
- `voltagent-core-dev` — 11개 (api-designer, backend-developer, frontend-developer, ...)
- `voltagent-lang` — 27개 (typescript-pro, python-pro, golang-pro, ...)
- `voltagent-infra` — DevOps 전문
- `voltagent-meta` — **오케스트레이션 에이전트** ← 우리와 가장 직접 관련
- 그 외 5개

### 2. **4가지 설치 옵션 (Sub-agent 배포 모범)**
- Plugin marketplace (권장)
- Manual: `~/.claude/agents/` (글로벌) or `.claude/agents/` (프로젝트)
- Interactive installer: `./install-agents.sh`
- Standalone curl: 클론 없이 직접 다운로드
- Agent Installer: **에이전트가 다른 에이전트를 설치** (재귀적 패턴)

### 3. **agent-installer 패턴 (재귀적 메타)**
```
curl ... agent-installer.md -o ~/.claude/agents/agent-installer.md
# 그 후 Claude Code에서:
"Use the agent-installer to show me available categories"
```
→ **우리 v2의 "워커 자동 발견·설치" 메커니즘 모델**.

### 4. **에이전트 명명 규약**
- `<domain>-<role>`: backend-developer, api-designer
- `<lang>-<expertise>`: python-pro, golang-pro, typescript-pro
- `<framework>-<level>`: nextjs-developer, django-developer, fastapi-developer
- `<role>-architect`: graphql-architect, microservices-architect

→ 우리 워커 명명 규약 표준화에 직접 활용.

### 5. **VoltAgent 생태계 패밀리**
- awesome-agent-skills (스킬 모음)
- awesome-codex-subagents (Codex용)
- awesome-openclaw-skills (OpenClaw용)
- awesome-ai-agent-papers (논문)

→ 우리도 harness-factory + harness-skills 형태로 분리 검토 (장기).

## 우리와의 차이점

| 항목 | VoltAgent | 우리 |
|---|---|---|
| 단위 | 단일 에이전트 .md | PGE 3에이전트 + 5훅 |
| 도메인 | 개발 언어/프레임워크별 | 메타하네스 자체 |
| 카테고리 | 9개 plugin | 1개 스킬 |
| Marketplace | claude plugin marketplace | 로컬만 |

## /harness-upgrade가 참조해야 할 시점
- **사용자 워커 추가 시** (v2): 유사 에이전트가 이미 존재하는지 확인
- **명명 규약 검수**: 우리 워커가 표준 규약을 따르는지 검증
- **분기 갱신**: 131 → ? 증가 추이로 생태계 활성도 측정
- **카테고리 변경 감지**: 새 카테고리 등장 시 우리 워커 분류 영향

## 핵심 인용 (2026-05-03 기준)
> "The voltagent-meta orchestration agents work best when other categories installed."
> 131+ subagents
> "Last update" 배지로 갱신 활성도 노출

## agent-installer 패턴 (인용)
```bash
curl -s https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/categories/09-meta-orchestration/agent-installer.md -o ~/.claude/agents/agent-installer.md
```
→ **에이전트가 에이전트를 추가하는 재귀 메커니즘**. v2에서 차용.

## 우선순위 액션
1. **`agent-installer.md` 정독** — 우리 v2 commander의 워커 자동 발견 모델 (1순위)
2. **`09-meta-orchestration/` 디렉토리 분석** — orchestration 패턴 비교
3. **명명 규약 확정** — 우리 워커 이름 정책 표준화
4. **131개 frontmatter 통계** — 평균 필드 수, description 길이 → 우리 템플릿 슬림화 근거
