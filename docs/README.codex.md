# Superpowers for Codex

Guide for using Sonbbal Superpowers with OpenAI Codex via plugin metadata, project `AGENTS.md` bootstrap, and a native skill discovery fallback.

## Package Location

The Codex package lives at:

```text
codex/
```

Codex skills live at:

```text
codex/skills
```

Claude Code uses the separate package at:

```text
claude-code/
```

## Quick Install

Tell Codex:

```text
Fetch and follow instructions from https://raw.githubusercontent.com/Sonbbal/superpowers/refs/heads/main/codex/INSTALL.md
```

Paste-ready install prompts are in [prompts.md](prompts.md).

## Manual Installation

Run from the target project root.

Clone or update the repo:

```bash
mkdir -p ~/.codex
if [ -d ~/.codex/superpowers/.git ]; then
  git -C ~/.codex/superpowers pull
else
  git clone https://github.com/Sonbbal/superpowers.git ~/.codex/superpowers
fi
```

Install the plugin through your Codex plugin flow when local plugin marketplaces are available. The repository marketplace is:

```text
~/.codex/superpowers/.agents/plugins/marketplace.json
```

Then run the project bootstrap:

```bash
bash ~/.codex/superpowers/codex/scripts/bootstrap-project.sh .
```

Restart Codex after installation.

## How It Works

The Codex plugin metadata lives in:

```text
~/.codex/superpowers/codex/.codex-plugin/plugin.json
```

The bootstrap script adds a managed `sonbbal-superpowers-codex` block to the target project's `AGENTS.md` and creates this fallback link for native skill discovery:

```text
.agents/skills/sonbbal-superpowers-codex/ -> ~/.codex/superpowers/codex/skills/
```

The `using-superpowers` skill is discovered through the plugin or fallback link and enforces skill usage discipline.

## Packaged Skills

The Codex package includes the Superpowers workflows ported to Codex-native tool language:

- `api-edr-validation`
- `audit-verification`
- `brainstorming`
- `context-window-management`
- `dispatching-parallel-agents`
- `executing-plans`
- `finishing-a-development-branch`
- `model-assignment`
- `project-scoping`
- `receiving-code-review`
- `requesting-code-review`
- `subagent-driven-development`
- `systematic-debugging`
- `team-driven-development`
- `test-driven-development`
- `using-git-worktrees`
- `using-superpowers`
- `verification-before-completion`
- `wiki-management`
- `writing-plans`
- `writing-skills`

## Updating

```bash
git -C ~/.codex/superpowers pull
bash ~/.codex/superpowers/codex/scripts/bootstrap-project.sh .
```

Update the installed plugin through your Codex plugin flow when available. The bootstrap script is idempotent and refreshes the managed `AGENTS.md` block plus fallback skill link. Restart Codex so discovery reloads them.

## Uninstalling

```bash
rm -rf .agents/skills/sonbbal-superpowers-codex
```

Also remove the managed `sonbbal-superpowers-codex` block from `AGENTS.md` if the project should no longer use this package.

Optionally delete the clone:

```bash
rm -rf ~/.codex/superpowers
```
