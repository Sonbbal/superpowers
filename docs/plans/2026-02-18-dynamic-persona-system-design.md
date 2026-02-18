# Dynamic Persona System Design

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:team-driven-development
> for parallel agent team execution, or superpowers:executing-plans for sequential batch execution.

**Goal:** team-driven-development 스킬에서 Worker spawn 시 태스크를 분석하여 역할/전문성 기반의 상세 페르소나를 동적으로 주입하는 시스템을 구축한다.

**Architecture:** skills/team-driven-development/ 디렉토리 내에 personas/ 참조 자료 폴더를 추가하고, SKILL.md에 페르소나 선택/주입 가이드라인을 추가한다. Team Lead가 Worker를 spawn할 때 태스크를 분석하여 해당 personas/ 파일에서 필요한 내용을 추출하고 Worker 프롬프트에 주입한다.

**Tech Stack:** Claude Code Skills, Markdown 참조 파일

---

## 1. 배경 및 동기

### 현재 문제

현재 team-driven-development 스킬에서 Worker를 spawn할 때:
- `general-purpose` 타입으로 범용 생성
- 특별한 페르소나 없이 "이 태스크를 구현하라" 지시만 제공
- Worker의 전문성, 역할 의식, 도메인 지식이 부족

### 업계 사례 조사 결과

7개 멀티 에이전트 프레임워크(CrewAI, AutoGen, MetaGPT, ChatDev, CAMEL, LangGraph, OpenAI Agents SDK)를 조사한 결과:

- **CrewAI**: role + goal + backstory 3-필드 시스템이 가장 구조적이고 효과적
- **AutoGen**: 라우팅용 description과 행동용 system_message 분리가 중요
- **MetaGPT**: profile + goal + constraints 패턴
- **CAMEL**: "Never flip roles!" anti-drift 메커니즘이 장기 대화에 필수
- **OpenAI SDK**: callable instructions로 런타임 동적 페르소나 생성

### 결론

CrewAI의 3-필드 시스템 + CAMEL의 anti-drift 메커니즘을 결합한 페르소나 템플릿을 채택한다.

---

## 2. 페르소나 템플릿 구조

각 Worker에게 주입되는 페르소나는 다음 5개 필드로 구성된다:

```
You are a {ROLE_TITLE}.

DOMAIN EXPERTISE:
{해당 태스크에 필요한 구체적 기술 영역 2-3문장}

GOAL:
{이 Worker가 달성해야 할 명확한 목표 1문장}

CONSTRAINTS:
- Query API/EDR Manager before ANY API-related code
- Follow existing project conventions
- {1-2개 태스크 특성에 맞는 추가 제약}
- Never skip error handling or tests

ANTI-DRIFT REMINDER:
You are {ROLE_TITLE}. Stay focused on your domain.
Do not attempt work outside your expertise — coordinate with Team Lead.
```

**필드 설명:**
- **ROLE_TITLE**: 태스크에서 추론한 역할명
- **DOMAIN EXPERTISE**: 해당 태스크에 필요한 구체적 기술 영역
- **GOAL**: Worker가 달성해야 할 명확한 목표
- **CONSTRAINTS**: 기본 제약 + 태스크별 추가 제약
- **ANTI-DRIFT REMINDER**: 역할 이탈 방지 메커니즘 (CAMEL 차용)

---

## 3. 파일 구조

```
skills/
└── team-driven-development/
    ├── SKILL.md                        ← 페르소나 선택/주입 로직 추가
    └── personas/                       ← 참조 자료 폴더
        ├── index.md                    ← 전체 인덱스
        │
        │  # Web Frontend
        ├── frontend-svelte5.md
        ├── frontend-react.md
        ├── frontend-vue.md
        │
        │  # Web Backend
        ├── backend-rails8.md
        ├── backend-csharp.md
        ├── backend-node.md
        ├── backend-python.md
        ├── backend-go.md
        │
        │  # Mobile
        ├── mobile-swift.md
        ├── mobile-kotlin.md
        ├── mobile-flutter.md
        ├── mobile-react-native.md
        │
        │  # Specialized
        ├── database-specialist.md
        ├── infrastructure.md
        ├── qa-engineer.md
        ├── security-engineer.md
        ├── performance-engineer.md
        └── api-designer.md
```

총 18개 페르소나 파일 + 1개 인덱스 파일.

---

## 4. 활용 흐름

```
1. Team Lead가 team-driven-development 스킬 실행
2. Worker spawn 단계에서 태스크 분석
   - 어떤 파일들을 다루는가?
   - 어떤 기술을 사용하는가?
   - 복잡도는? (model-assignment 스킬과 연계)
3. personas/index.md에서 적합한 페르소나 파일 확인
4. 해당 personas/*.md 파일을 읽어서 필요한 섹션 추출
   - Identity + Domain Expertise + Constraints + Anti-Drift는 항상 포함
   - Technical Knowledge는 태스크와 관련된 부분만 선택적 포함
5. 추출한 페르소나를 Worker 프롬프트 맨 앞에 주입
6. 기존 태스크 상세, API/EDR 쿼리 의무 등은 그대로 유지
7. Worker spawn
```

**복합 태스크의 경우** (예: "Svelte 5 프론트엔드 + Rails 8 API"):
- 각각 별도 Worker로 spawn하며, 각 Worker에 해당 페르소나를 주입

---

## 5. 페르소나 파일 상세 구조

각 `.md` 파일은 다음 섹션으로 구성된다:

```markdown
# {Role Title}

## Identity
- **Role Title**: {역할명}
- **Seniority**: Senior-level specialist

## Domain Expertise
- {핵심 기술 1}
- {핵심 기술 2}
- {핵심 기술 3}
- {핵심 기술 4}

## Technical Knowledge

### Core Patterns
- {패턴 1}
- {패턴 2}
- ...

### Best Practices
- {모범 사례 1}
- {모범 사례 2}
- ...

### Anti-Patterns to Avoid
- {안티패턴 1}
- {안티패턴 2}
- ...

### Testing Approach
- {테스트 프레임워크}
- {테스트 전략}
- ...

## Goal Template
"{역할 관점에서의 기본 목표 문장}"

## Constraints
- Query API/EDR Manager before {역할 관련 API 작업}
- {역할별 필수 제약 1}
- {역할별 필수 제약 2}
- ...

## Anti-Drift
"You are {Role Title}. Stay focused on {역할 도메인}.
Do not {역할 외 금지 행동} — coordinate with Team Lead."
```

---

## 6. 각 페르소나 기술 버전 명세 (2026년 2월 기준 최신 안정 버전)

### Web Frontend

| 페르소나 | 핵심 기술 | 버전 |
|---|---|---|
| **frontend-svelte5** | Svelte 5.51.2, SvelteKit 2.52.0, TypeScript 5.9 | 2026-02 |
| **frontend-react** | React 19.2.4, Next.js 16.1.6, TypeScript 5.9 | 2026-02 |
| **frontend-vue** | Vue 3.5.28, Nuxt 4.3.0, TypeScript 5.9 | 2026-02 |

### Web Backend

| 페르소나 | 핵심 기술 | 버전 |
|---|---|---|
| **backend-rails8** | Ruby 4.0.1, Rails 8.1.2 | 2026-01 |
| **backend-csharp** | C# 13, .NET 10.0.3, ASP.NET Core 10.0.3 | 2026-02 |
| **backend-node** | Node.js 24.13.1 LTS, Express 5.2.1, Fastify 5.7.4, NestJS 11.1.14 | 2026-02 |
| **backend-python** | Python 3.14.3, Django 6.0.2, FastAPI 0.129.0 | 2026-02 |
| **backend-go** | Go 1.26.0, Gin 1.11.0 | 2026-02 |

### Mobile

| 페르소나 | 핵심 기술 | 버전 |
|---|---|---|
| **mobile-swift** | Swift 6.2.1, SwiftUI (iOS 26 SDK), Xcode 26.2 | 2025-12 |
| **mobile-kotlin** | Kotlin 2.3.10, Jetpack Compose BOM 2026.01.01, Android Studio Otter 3 | 2026-01 |
| **mobile-flutter** | Flutter 3.41.0, Dart 3.11 | 2026-02 |
| **mobile-react-native** | React Native 0.84.0, React 19.2.4 | 2026-02 |

### Database & Infrastructure

| 기술 | 버전 |
|---|---|
| PostgreSQL | 18.2 |
| MySQL | 8.4.8 LTS |
| MongoDB | 8.2.5 |
| Redis | 8.6 |
| Docker Engine | 29.2.1 |

---

## 7. team-driven-development 스킬 변경 사항

### 추가될 섹션: Worker 페르소나 생성

SKILL.md의 Worker spawn 단계에 다음 가이드라인을 추가한다:

```markdown
## Worker 페르소나 주입

Worker를 spawn하기 전에, 해당 태스크를 분석하여 페르소나를 생성하라:

1. **페르소나 파일 선택**: 태스크의 파일 유형과 기술 도메인으로 판단
   - `personas/index.md`를 읽어서 적합한 파일 확인
   - 해당 `personas/*.md` 파일을 읽기

2. **필요한 섹션 추출**:
   - Identity + Domain Expertise + Constraints + Anti-Drift는 항상 포함
   - Technical Knowledge는 태스크와 관련된 부분만 선택적 포함

3. **페르소나 템플릿 조합**:
   - 추출한 내용을 페르소나 템플릿에 대입
   - Worker 프롬프트의 맨 앞에 배치
   - 기존 태스크 상세 내용은 페르소나 뒤에 배치

4. **Worker spawn**:
   - 조합된 프롬프트로 Worker spawn
   - model-assignment 결과 (Opus/Sonnet)와 독립적으로 적용
```

### 변경 전/후 비교

**변경 전 (Worker spawn 프롬프트):**
```
Task 3을 구현하라. 파일: src/api/auth.ts.
API/EDR Manager에게 먼저 쿼리하라.
```

**변경 후 (Worker spawn 프롬프트):**
```
You are a Backend API Engineer.

DOMAIN EXPERTISE:
RESTful API design and implementation,
request validation and error handling middleware,
authentication/authorization flow integration,
database query optimization and ORM usage.

GOAL:
Implement well-structured API endpoints with proper
input validation, error responses, and comprehensive test coverage.

CONSTRAINTS:
- Query API/EDR Manager for exact endpoint contracts BEFORE coding
- Never assume request/response shapes — confirm with API registry
- Always validate input at the controller boundary
- Return consistent error response format across all endpoints
- Write integration tests that cover success and error paths

ANTI-DRIFT REMINDER:
You are Backend API Engineer. Stay focused on API layer.
Do not modify frontend components or CI/CD configuration —
coordinate with Team Lead for cross-layer changes.

---
Task 3: [태스크 상세 내용]
Files: src/api/auth.ts
...
```

---

## 8. 설계 원칙

1. **동적 생성, 정적 참조**: 페르소나는 태스크별로 동적 생성하지만, 생성의 기반은 정적 참조 파일
2. **역할 + 전문성 중심**: 성격/사고방식이 아닌 역할과 기술적 전문성에 집중
3. **Anti-Drift 필수**: 모든 페르소나에 역할 이탈 방지 메커니즘 포함
4. **기존 흐름 유지**: API/EDR 쿼리, Audit 검증 등 기존 필수 단계는 변경 없음
5. **확장 가능**: 새로운 기술/역할이 필요하면 personas/ 폴더에 파일 추가만으로 확장
