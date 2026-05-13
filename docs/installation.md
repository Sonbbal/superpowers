# Installing Sonbbal Superpowers

Sonbbal Superpowers ships two platform packages from one repository:

| Platform | Package |
| --- | --- |
| Claude Code | `claude-code/` |
| Codex | `codex/` |

The repository root is the project overview and marketplace entry point. It is not the Claude Code runtime package.

## Claude Code

Run these commands in Claude Code:

```text
/plugin marketplace add Sonbbal/superpowers
/plugin install sonbbal-superpowers@sonbbal-marketplace
```

Update:

```text
/plugin update sonbbal-superpowers
```

Verify from a local clone:

```bash
bash tests/claude-code/test-plugin-package.sh
```

The Claude Code marketplace source should be `./claude-code`.

## Codex

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

Install `sonbbal-superpowers-codex` through your Codex plugin flow when local plugin marketplaces are available. The repository marketplace is `~/.codex/superpowers/.agents/plugins/marketplace.json`, and it points at the `codex/` package.

Bootstrap the target project:

```bash
bash ~/.codex/superpowers/codex/scripts/bootstrap-project.sh .
```

The bootstrap script updates `AGENTS.md` with a managed usage block and creates `.agents/skills/sonbbal-superpowers-codex` as a native skill discovery fallback. Restart Codex after install or update.

Verify:

```bash
grep -F "sonbbal-superpowers-codex:start" AGENTS.md
test -f .agents/skills/sonbbal-superpowers-codex/using-superpowers/SKILL.md
find .agents/skills/sonbbal-superpowers-codex -name SKILL.md | sort
```

Run package tests:

```bash
bash tests/codex/test-plugin-package.sh
```

## Migration Notes

Older Claude Code docs and historical design plans may mention root-level `skills/`, `agents/`, `commands/`, or `hooks/`. Current Claude Code runtime files live under `claude-code/`.

The root `.codex/INSTALL.md` remains as a compatibility pointer for one release cycle. The canonical Codex install guide is `codex/INSTALL.md`.
