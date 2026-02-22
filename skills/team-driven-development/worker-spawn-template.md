# Worker Spawn Template

## Worker Naming Rules

**Worker 이름은 역할 기반으로 지정합니다.** 번호 기반 이름(`worker-1`, `worker-2`)은 금지합니다.

태스크 내용에서 역할을 추출하여 의미 있는 이름을 지정합니다:

| 태스크 도메인 | Worker 이름 예시 |
|-------------|----------------|
| 인증 백엔드 | `auth-backend` |
| 결제 API | `payment-api` |
| 테스트 작성 | `test-engineer` |
| UI 대시보드 | `ui-dashboard` |
| 데이터 마이그레이션 | `data-migration` |
| 성능 최적화 | `perf-optimizer` |

**Before/After 예시:**
- Before: `worker-1` → After: `auth-backend`
- Before: `worker-2` → After: `payment-api`
- Before: `worker-3` → After: `test-engineer`

## Spawn Template

```
Task (Worker):
  name: "<role-based-name>"
  subagent_type: "general-purpose"
  model: "<opus or sonnet from task metadata>"
  prompt: |
    You are <role-based-name>. Your SINGLE task:

    Task: <full task text from TaskGet>
    Target files: <list from metadata.target_files>

    MANDATORY WORKFLOW:
    1. FIRST: Read docs/api/ for API contracts relevant to your task
       - If relevant docs exist, use them as the source of truth
       - If no docs exist for your domain, create docs/api/[domain].md using the
         superpowers:api-edr-validation skill's standard format
    2. Follow TDD: write failing test FIRST, then implement minimal code to pass
       (REQUIRED SUB-SKILL: superpowers:test-driven-development)
    3. Implement using ONLY documented API contracts and variable names
    4. If you create a new API endpoint: create or update docs/api/[domain].md
    5. When DONE: SendMessage to audit-agent with Task Completion Report:
       - What Was Done (bullet list)
       - Files Changed (paths + description)
       - Tests (count, all passing yes/no, command used)
       - API Contracts (documented in docs/api/)
       - Commits (hashes and messages)
    6. If audit-agent rejects: fix and resubmit
    7. NEVER mark task complete yourself — Team Lead handles that after audit approval

    FILE SCOPE RESTRICTION:
    - You may ONLY modify files listed in your target files
    - If you need to modify a file NOT in your target list, STOP and message Team Lead
    - Team Lead will update your task's target_files and check for conflicts before approving
    - NEVER modify files outside your scope — this causes conflicts with other workers

    NEVER assume API shapes or invent variable names — always check docs/api/ first.
  team_name: "<project-name>"
```

## Persona Matching Guidelines

태스크 도메인에 맞는 persona를 Worker 프롬프트에 추가합니다. 적절한 persona가 있으면 Worker의 전문성이 향상됩니다.

| 태스크 도메인 | 권장 Persona |
|-------------|-------------|
| 프론트엔드 (React) | `frontend-react` |
| 프론트엔드 (Svelte 5) | `frontend-svelte5` |
| 프론트엔드 (Vue) | `frontend-vue` |
| 백엔드 (Node.js) | `backend-node` |
| 백엔드 (Python) | `backend-python` |
| 백엔드 (Go) | `backend-go` |
| 테스트/QA | `qa-engineer` |
| 데이터베이스 | `database-specialist` |
| 인프라/DevOps | `infrastructure` |
| 보안 | `security-engineer` |
| 성능 | `performance-engineer` |

**Persona 적용 방법:**
- `personas/` 디렉토리에서 해당 persona 파일을 확인
- 존재하면 Worker 프롬프트에 persona 내용을 append
- 존재하지 않으면 기본 프롬프트만 사용 (persona는 선택사항)

See `personas/index.md` for available personas.
