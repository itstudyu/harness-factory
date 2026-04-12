# harness-factory

새 프로젝트를 위한 Claude Code 하네스 구조(에이전트, 스킬, 훅)를 자동 생성하는 메타-하네스.

## 개요

harness-factory는 유저가 원하는 하네스 구성을 말하면, 불확실한 부분을 해소하고
팩트 기반으로 하네스 구조를 설계/생성/검증하는 도구이다.

검증된 설계 원칙(Anthropic 공식 문서, Mitchell Hashimoto, Simon Willison 등)을
`harness-rules.md`로 압축하여 매 세션마다 hook으로 강제 참조한다.

## 구조

```
harness-factory/
├── .claude/
│   ├── agents/
│   │   ├── harness-architect.md     # Planner: 구조 설계
│   │   ├── harness-generator.md     # Generator: 파일 생성
│   │   └── harness-auditor.md       # Evaluator: 검증
│   ├── hooks/
│   │   ├── inject-harness-rules.sh  # SessionStart: rules 주입 + 갱신일 체크
│   │   └── validate-generated.sh    # PostToolUse: 생성물 검증
│   ├── skills/
│   │   ├── harness-factory/SKILL.md # 메인 스킬 (진입점)
│   │   └── rules-updater/SKILL.md   # reference/rules 갱신 스킬
│   └── settings.local.json
├── references/
│   ├── harness-rules.md             # 설계 원칙 (<2200 words, 자동 주입)
│   ├── harness-references.md        # URL 분석 요약 (수동 참조)
│   └── templates/                   # 생성 템플릿
├── .nova/
│   └── progress.json
├── CLAUDE.md
└── README.md
```

## 사용법

### 하네스 생성

```
/harness-factory
```

1. 프로젝트 경로, 기술 스택, 필요한 에이전트 역할을 입력
2. harness-architect가 Flipped Interaction으로 요구사항을 명확화
3. 설계 결과를 확인하고 승인
4. harness-generator가 모든 파일을 생성
5. harness-auditor가 12항목 체크리스트로 검증
6. PASS → 완료 / FAIL → 자동 재시도 (최대 2회)

### 설계 원칙 갱신

```
/rules-updater
```

- 등록된 URL에서 최신 내용을 가져와 harness-rules.md 업데이트
- 새로운 trusted article URL 추가 가능
- AI가 WebSearch로 최신 article 자동 검색 가능

## 워크플로우

```
유저 요구사항 입력
       │
       v
  ┌─────────────────┐
  │ harness-architect│  Flipped Interaction
  │    (Planner)     │  → 명확화 → 설계
  └────────┬────────┘
           │ harness-design.md
           v
     유저 승인?  ──No──→ 수정 반복
       │ Yes
       v
  ┌─────────────────┐
  │ harness-generator│  템플릿 기반
  │   (Generator)    │  파일 생성
  └────────┬────────┘
           │
           v
  ┌─────────────────┐
  │ harness-auditor  │  12항목
  │   (Evaluator)    │  바이너리 체크
  └────────┬────────┘
           │
     PASS? ──No──→ 재위임 (최대 2회)
       │ Yes
       v
     완료 보고
```

## 설계 원칙 소스

1. [Anthropic: Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
2. [Anthropic: Harness Design](https://www.anthropic.com/engineering/harness-design-long-running-apps)
3. [Anthropic: Managed Agents](https://www.anthropic.com/engineering/managed-agents)
4. [Anthropic: Prompt Caching](https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching)
5. [Claude Code: Sub-agents](https://code.claude.com/docs/en/sub-agents)
6. [Claude Code: Best Practices](https://code.claude.com/docs/en/best-practices)
7. [Mitchell Hashimoto: AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)

상세 분석: `references/harness-references.md` 참조
