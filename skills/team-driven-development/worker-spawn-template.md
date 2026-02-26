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

    GOAL:
      <metadata.goal에서 추출>

    SUCCESS CRITERIA:
      1. <metadata.success_criteria[0]>
      2. <metadata.success_criteria[1]>
      3. <metadata.success_criteria[2]>

    VERIFICATION METHOD:
      <metadata.verification_method에서 추출>

    MANDATORY WORKFLOW:
    0. UNDERSTAND: Goal과 Success Criteria를 읽고, 자신의 말로 정리하여
       Team Lead에게 SendMessage로 보고한다.
       "Task N 이해 완료: [자신의 말로 정리한 목표]"
       Team Lead가 이해가 틀렸다고 판단하면 교정한다.

    1. PLAN: 구현 계획을 3-5단계로 수립한다 (코드 작성 전).
       각 단계가 어떤 success criteria를 충족시키는지 매핑한다.

    2. CHECK docs/api/: API 계약 확인
       - relevant docs exist → use as source of truth
       - no docs for your domain → create docs/api/[domain].md
       (REQUIRED SUB-SKILL: superpowers:api-edr-validation)

    3. RED: 실패하는 테스트 작성 → 실행하여 실패 확인
       (REQUIRED SUB-SKILL: superpowers:test-driven-development)

    4. GREEN: 테스트 통과하는 최소 코드 작성 → 실행하여 통과 확인

    5. REFACTOR: 필요시 정리 (테스트 그린 유지)

    6. Repeat 3-5 for each success criteria / feature

    7. SELF-CHECK: 모든 Success Criteria를 하나씩 대조 확인한다.
       ```
       SELF-CHECK RESULT:
       Success Criteria:
       - [✅/❌] 기준 1: <확인 방법과 결과>
       - [✅/❌] 기준 2: <확인 방법과 결과>
       - [✅/❌] 기준 3: <확인 방법과 결과>
       Verification: <verification_method 실행 결과>
       TDD Compliance:
       - [✅/❌] 모든 기능에 대해 테스트를 먼저 작성했는가
       - [✅/❌] 각 테스트가 실패하는 것을 확인한 후 구현했는가
       - [✅/❌] success criteria마다 대응하는 테스트가 있는가
       Tests: N개 통과 / N개 전체
       ```
       ❌가 하나라도 있으면 → Step 3으로 돌아가서 해결 후 재체크.

    8. REPORT: audit-agent에게 Task Completion Report 제출.
       - Goal: <목표>
       - Self-Check: <위의 SELF-CHECK RESULT>
       - What Was Done (bullet list)
       - Files Changed (paths + description)
       - Tests (count, all passing yes/no, command used)
       - API Contracts (documented in docs/api/)
       - Commits (hashes and messages)

    9. If audit-agent rejects: fix and resubmit (Step 3부터)
    10. NEVER mark task complete yourself — Team Lead handles that after audit approval

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
