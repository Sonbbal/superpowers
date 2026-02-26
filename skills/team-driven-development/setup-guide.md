# Team Setup Guide

## Step 1: Create Team & Register All Tasks

```
TeamCreate:
  team_name: "<project-name>"
  description: "Implementing <feature>"
```

**Immediately after TeamCreate**, register ALL tasks from the plan using TaskCreate:

```
For each task in plan:
  TaskCreate:
    subject: "<task title>"
    description: "<full task requirements including target files>"
    activeForm: "<present continuous form>"
    metadata: {
      "target_files": ["src/auth.ts", "src/auth.test.ts"],
      "model": "opus",
      "goal": "<이 태스크가 완료되면 무엇이 달성되는가 — 한 문장>",
      "success_criteria": [
        "<검증 가능한 성공 기준 1>",
        "<검증 가능한 성공 기준 2>",
        "<검증 가능한 성공 기준 3>"
      ],
      "verification_method": "<구체적 검증 방법: 테스트 명, curl 명령, UI 확인 등>"
    }

Then set dependencies:
  TaskUpdate: { taskId: "2", addBlockedBy: ["1"] }  # if task 2 depends on task 1
```

**CRITICAL — goal/success_criteria metadata:**
Every task MUST declare goal, success_criteria, and verification_method.
Workers use these for self-check, and Audit Agent verifies against them.

**success_criteria 작성 원칙:**
- 모호한 기준 금지: "잘 동작함" ✗ → "POST /api/login 시 200 + JWT 반환" ✓
- 검증 가능해야 함: 테스트, curl, UI 조작 등으로 확인할 수 있어야 한다
- 에러 케이스 포함: 정상 경로 + 비정상 경로 모두 기술
- 3-7개 범위: 너무 적으면 누락 위험, 너무 많으면 태스크 분할 필요

**CRITICAL — target_files metadata:**
Every task MUST declare which files it will create or modify in `metadata.target_files`.
This is used by the orchestration loop to prevent file conflicts between concurrent workers.

**CRITICAL — dependency analysis:**
Before entering the loop, verify the dependency graph is correct:
1. Tasks that share target files MUST have a dependency (blockedBy) between them
2. Tasks that consume output of another task MUST be blocked by that task
3. Circular dependencies MUST be resolved by splitting tasks

This gives you a complete task board with dependency graph and file ownership BEFORE any agent is spawned.

## Step 2: Spawn Audit Agent

**Only spawn the Audit Agent — NO workers yet:**

```
Task (Audit Agent):
  name: "audit-agent"
  subagent_type: "sonbbal-superpowers:audit-agent"
  model: "opus"                    # ALWAYS Opus — non-negotiable
  prompt: "You are the Audit Agent. See agents/audit-agent.md for your role."
  team_name: "<project-name>"
```

## Step 3: API Documentation Check

Before entering the orchestration loop:

1. Check if `docs/api/` directory exists
2. If it doesn't exist, create an empty `docs/api/` directory as baseline
3. If it exists, review the contents to understand existing API contracts
4. Workers will reference `docs/api/` directly when implementing API-related tasks (using the `superpowers:api-edr-validation` skill)

## Step 4: Assess Task Difficulty

Use **superpowers:model-assignment** to determine model for each task:

| Difficulty | Criteria | Model |
|-----------|----------|-------|
| **High** | New architecture, complex logic, security-critical, multi-system integration | Opus |
| **Low** | Simple CRUD, config changes, boilerplate, straightforward tests | Sonnet |

Record the model assignment in task metadata:
```
TaskUpdate: { taskId: "1", metadata: { "model": "opus" } }
TaskUpdate: { taskId: "2", metadata: { "model": "sonnet" } }
```
