# Installing Sonbbal Superpowers for Codex

Enable the Codex-compatible Sonbbal Superpowers package through Codex plugin metadata, then bootstrap the target project with managed `AGENTS.md` guidance. A native skill discovery link is created as a fallback for Codex environments that do not load local plugins yet.

The Codex runtime package lives in:

```text
codex/
```

Claude Code uses the separate package in:

```text
claude-code/
```

## Prerequisites

- Git
- Bash for the project bootstrap script

## Project Install

Run these commands from the target project root.

Clone or update the repository:

```bash
mkdir -p ~/.codex
if [ -d ~/.codex/superpowers/.git ]; then
  git -C ~/.codex/superpowers pull
else
  git clone https://github.com/Sonbbal/superpowers.git ~/.codex/superpowers
fi
```

Install the Codex plugin through your Codex plugin flow when local plugin marketplaces are available. The repository marketplace is:

```text
~/.codex/superpowers/.agents/plugins/marketplace.json
```

It exposes `sonbbal-superpowers-codex`, whose package metadata lives at:

```text
~/.codex/superpowers/codex/.codex-plugin/plugin.json
```

Then bootstrap the target project:

```bash
bash ~/.codex/superpowers/codex/scripts/bootstrap-project.sh .
```

The bootstrap script:

- adds or updates a managed `sonbbal-superpowers-codex` block in `AGENTS.md`;
- preserves any existing `AGENTS.md` content outside the managed block;
- creates `.agents/skills/sonbbal-superpowers-codex` as a native skill discovery fallback;
- refuses to replace an existing non-symlink fallback path unless you rerun with `--force-skill-link`.

On Windows, run the bootstrap script from Git Bash or WSL. If symlink creation is blocked, rerun with `--skip-skill-link`, then create a junction manually from PowerShell if your Codex build needs the fallback link.

Restart Codex after plugin install or project bootstrap so plugin metadata, skills, and `AGENTS.md` are reloaded.

## Verify

```bash
test -f ~/.codex/superpowers/codex/.codex-plugin/plugin.json
grep -F "sonbbal-superpowers-codex:start" AGENTS.md
test -f .agents/skills/sonbbal-superpowers-codex/using-superpowers/SKILL.md
find .agents/skills/sonbbal-superpowers-codex -name SKILL.md | sort
```

You should see the managed `AGENTS.md` block and the Codex-compatible skills from `codex/skills`, including `using-superpowers`, `executing-plans`, `team-driven-development`, and the other packaged Superpowers workflows.

## Test The Package

From the repository clone:

```bash
git -C ~/.codex/superpowers pull
bash ~/.codex/superpowers/tests/codex/test-plugin-package.sh
```

## Updating

```bash
git -C ~/.codex/superpowers pull
bash ~/.codex/superpowers/codex/scripts/bootstrap-project.sh .
```

Update the installed plugin through your Codex plugin flow when available. The project bootstrap is idempotent and refreshes the managed `AGENTS.md` block plus fallback skill link. Restart Codex so discovery reloads the plugin and project instructions.

## Uninstalling

```bash
rm -rf .agents/skills/sonbbal-superpowers-codex
```

Also remove the managed `sonbbal-superpowers-codex` block from `AGENTS.md` if the project should no longer use this package.

Optionally delete the clone:

```bash
rm -rf ~/.codex/superpowers
```
