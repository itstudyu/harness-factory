---
name: {{SKILL_NAME}}
description: {{DESCRIPTION_KO}}
# when_to_use: 트리거 조건 보충 (description에 합산, 1536자 cap)
# argument-hint: "[인자]"          # 선택. 자동완성 시 인자 힌트
# disable-model-invocation: true   # 파괴적 커맨드 전용
# user-invocable: true             # false → / 메뉴 숨김, Claude만 호출
# allowed-tools: Bash(git *) Read  # 선택
# model: sonnet                    # 선택. 스킬 활성 시 모델
# effort: high                     # 선택. low | medium | high | xhigh | max
# context: fork                    # 선택. 격리 sub-agent에서 실행
# agent: Explore                   # context:fork 시 sub-agent 타입
# paths: "src/**/*.ts"             # 매칭 파일 작업 시만 활성화
# hooks: {}                        # 선택. 스킬 라이프사이클 훅
# shell: bash                      # 선택. bash (기본) | powershell
---

# {{SKILL_TITLE}}

{{SKILL_OVERVIEW}}

## 절차

### 1. {{STEP_1_TITLE}}

{{STEP_1_DESCRIPTION}}

```bash
{{STEP_1_COMMAND}}
```

### 2. {{STEP_2_TITLE}}

{{STEP_2_DESCRIPTION}}

```bash
{{STEP_2_COMMAND}}
```

### 3. {{STEP_3_TITLE}}

{{STEP_3_DESCRIPTION}}

## 보고 형식

```
### {{SKILL_NAME}} 결과
- {{RESULT_FIELD_1}}: [값]
- {{RESULT_FIELD_2}}: [값]
- {{RESULT_FIELD_3}}: [값]
```
