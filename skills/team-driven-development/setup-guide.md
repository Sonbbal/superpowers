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
    metadata: { "target_files": ["src/auth.ts", "src/auth.test.ts"] }

Then set dependencies:
  TaskUpdate: { taskId: "2", addBlockedBy: ["1"] }  # if task 2 depends on task 1
```

**CRITICAL — target_files metadata:**
Every task MUST declare which files it will create or modify in `metadata.target_files`.
This is used by the orchestration loop to prevent file conflicts between concurrent workers.

**CRITICAL — dependency analysis:**
Before entering the loop, verify the dependency graph is correct:
1. Tasks that share target files MUST have a dependency (blockedBy) between them
2. Tasks that consume output of another task MUST be blocked by that task
3. Circular dependencies MUST be resolved by splitting tasks

This gives you a complete task board with dependency graph and file ownership BEFORE any agent is spawned.

## Step 2: Spawn Mandatory Agents (Only These)

**Only spawn infrastructure agents — NO workers yet:**

```
Task (API/EDR Manager):
  name: "api-edr-manager"
  subagent_type: "sonbbal-superpowers:api-edr-manager"
  model: "opus"                    # ALWAYS Opus — non-negotiable
  prompt: "You are the API/EDR Manager. See agents/api-edr-manager.md for your role."
  team_name: "<project-name>"

Task (Audit Agent):
  name: "audit-agent"
  subagent_type: "sonbbal-superpowers:audit-agent"
  model: "opus"                    # ALWAYS Opus — non-negotiable
  prompt: "You are the Audit Agent. See agents/audit-agent.md for your role."
  team_name: "<project-name>"
```

## Step 3: API/EDR Manager Initial Scan

Before entering the orchestration loop:

1. Send message to `api-edr-manager`: "Scan docs/ for API and EDR documents. Build the API registry."
2. Wait for the API/EDR Manager to respond with the registry
3. If no docs found: API/EDR Manager creates `docs/api-registry.md` as baseline
4. If docs found: API/EDR Manager indexes all endpoints, variables, contracts

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
