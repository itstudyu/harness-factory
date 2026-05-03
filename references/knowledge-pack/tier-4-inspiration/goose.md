---
name: goose
tier: 4
stars: 43700
url: https://github.com/aaif-goose/goose (전 block/goose)
license: Apache-2.0
last_analyzed: 2026-05-03
analyst: claude-opus-4-7
note: Linux Foundation의 Agentic AI Foundation으로 이전됨 (aaif.io)
---

# block/goose (현 aaif-goose/goose)

## 한 줄
범용 AI 에이전트 — desktop app + CLI + API. Rust 기반. 15+ provider, 70+ MCP extension. ★43.7k.

## 자기소개
> "your native open source AI agent — desktop app, CLI, and API — for code, workflows, and everything in between"
>
> "Built in Rust for performance and portability."

## 우리에게 주는 영감

### 1. **3-form deployment**
- Desktop app (macOS/Linux/Windows)
- Full CLI
- API
- → 우리 v2도 단일 trigger 방식보다 다중 진입점 검토 가치

### 2. **15+ Provider 지원**
- Anthropic, OpenAI, Google, Ollama, OpenRouter, Azure, Bedrock 등
- ACP (Agent Client Protocol)로 Claude/ChatGPT/Gemini **구독 그대로 사용**
- → Claude Code 외부 모델 연동 모범

### 3. **70+ MCP Extensions**
- MCP가 표준임을 증명
- → 우리도 MCP 활용 가능성 (rules §5 Code Execution with MCP [14])

### 4. **Custom Distributions**
- "build your own goose distro with preconfigured providers, extensions, and branding"
- → **우리도 v2에서 "사전 구성된 워커 팩" 배포 가능**

### 5. **거버넌스 — Linux Foundation**
- block/goose → aaif-goose/goose (Agentic AI Foundation)
- → 단일 회사가 아닌 **재단 거버넌스의 모범**. 장기 프로젝트의 신뢰성

## /harness-upgrade가 참조해야 할 시점
- **MCP 확장 추적**: 70+ extension 중 우리에게 유용한 것 발굴
- **Custom Distribution 패턴**: 우리 v2의 워커 팩 배포 모델

## 우선순위 액션
1. **Custom Distributions 가이드 정독** — 워커 팩 모델 (1순위)
2. ACP (Agent Client Protocol) 학습 — 외부 LLM 연동
3. AAIF 거버넌스 모델 참고
