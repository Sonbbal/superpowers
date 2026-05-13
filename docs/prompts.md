# Paste-Ready Installation Prompts

Use these prompts inside the target agent when you want it to install or update Sonbbal Superpowers for the current environment.

## Claude Code Install Or Update Prompt

```text
현재 프로젝트에 Sonbbal Superpowers for Claude Code를 설치하거나 업데이트해줘.

요구사항:
1. 현재 작업 디렉터리를 사용자의 프로젝트 루트로 판단한다.
2. Git과 Claude Code 플러그인 명령 사용 가능 여부를 확인한다.
3. Sonbbal marketplace가 등록되어 있지 않으면 다음 명령을 사용자에게 실행하도록 안내한다:
   /plugin marketplace add Sonbbal/superpowers
4. sonbbal-superpowers 플러그인이 설치되어 있지 않으면 다음 명령을 사용자에게 실행하도록 안내한다:
   /plugin install sonbbal-superpowers@sonbbal-marketplace
5. 이미 설치되어 있으면 다음 명령으로 업데이트하도록 안내한다:
   /plugin update sonbbal-superpowers
6. 설치된 Claude Code 패키지가 저장소 루트가 아니라 claude-code/ 패키지를 가리키는지 확인한다.
7. 설치 또는 업데이트 후 Claude Code 새 세션을 시작하라고 안내한다.
8. 재시작 후 using-superpowers, brainstorming, writing-plans 같은 스킬이 보이는지 검증한다.

직접 실행할 수 없는 slash command는 추측하지 말고 사용자가 복사할 수 있는 정확한 명령만 제시해줘.
```

## Codex Install Or Update Prompt

```text
현재 Codex 환경에 Sonbbal Superpowers for Codex를 설치하거나 업데이트해줘.

요구사항:
1. 현재 작업 디렉터리를 사용자의 프로젝트 루트로 판단한다.
2. https://github.com/Sonbbal/superpowers.git 저장소를 ~/.codex/superpowers 에 clone하거나, 이미 있으면 git pull로 업데이트한다.
3. Codex plugin metadata를 지원하는 환경이면 ~/.codex/superpowers/.agents/plugins/marketplace.json 에서 sonbbal-superpowers-codex 플러그인을 설치하거나 업데이트한다. 지원 여부가 불확실하면 명령을 추측하지 말고 사용자가 실행할 수 있는 정확한 안내만 제시한다.
4. 현재 프로젝트 루트에서 다음 bootstrap 스크립트를 실행한다:
   bash ~/.codex/superpowers/codex/scripts/bootstrap-project.sh .
5. bootstrap 결과 AGENTS.md 안에 sonbbal-superpowers-codex 관리 블록이 생겼는지 확인한다.
6. fallback native skill discovery 경로인 .agents/skills/sonbbal-superpowers-codex 가 ~/.codex/superpowers/codex/skills 를 가리키는지 확인한다.
7. .agents/skills/sonbbal-superpowers-codex 아래에 using-superpowers, brainstorming, writing-plans, executing-plans, team-driven-development 스킬이 있는지 검증한다.
8. 설치 또는 업데이트 후 Codex를 재시작하라고 안내한다.

권한상 직접 실행할 수 없는 단계가 있으면 사용자가 복사할 수 있는 정확한 shell 명령을 제시해줘.
```
