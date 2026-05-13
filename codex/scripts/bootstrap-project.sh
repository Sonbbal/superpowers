#!/usr/bin/env bash
# Bootstraps a target Codex project with Sonbbal Superpowers guidance.
set -euo pipefail

PLUGIN_NAME="sonbbal-superpowers-codex"
START_MARKER="<!-- sonbbal-superpowers-codex:start -->"
END_MARKER="<!-- sonbbal-superpowers-codex:end -->"

usage() {
  cat <<'USAGE'
Usage: bootstrap-project.sh [TARGET_PROJECT_ROOT] [--force-skill-link] [--skip-skill-link]

Adds or updates the managed Sonbbal Superpowers block in TARGET_PROJECT_ROOT/AGENTS.md.
Also creates a project-local native skill discovery fallback unless --skip-skill-link is set.

Options:
  --force-skill-link  Replace an existing non-symlink fallback skill path.
  --skip-skill-link   Only update AGENTS.md; do not create .agents/skills fallback.
  -h, --help          Show this help.
USAGE
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CODEX_DIR="$(cd "$SCRIPT_DIR/.." && pwd -P)"
TEMPLATE_FILE="$CODEX_DIR/AGENTS.template.md"
SKILLS_DIR="$CODEX_DIR/skills"

TARGET_DIR=""
FORCE_SKILL_LINK=0
SKIP_SKILL_LINK=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --force-skill-link)
      FORCE_SKILL_LINK=1
      ;;
    --skip-skill-link)
      SKIP_SKILL_LINK=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -n "$TARGET_DIR" ]; then
        echo "Only one target project root may be provided." >&2
        usage >&2
        exit 2
      fi
      TARGET_DIR="$1"
      ;;
  esac
  shift
done

TARGET_DIR="${TARGET_DIR:-$PWD}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Target project root does not exist: $TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Missing AGENTS template: $TEMPLATE_FILE" >&2
  exit 1
fi

if [ ! -d "$SKILLS_DIR" ]; then
  echo "Missing Codex skills directory: $SKILLS_DIR" >&2
  exit 1
fi

count_marker() {
  local marker="$1"
  local file="$2"

  if [ ! -f "$file" ]; then
    echo 0
    return
  fi

  grep -Fxc "$marker" "$file" || true
}

update_agents_file() {
  local agents_file="$TARGET_DIR/AGENTS.md"
  local start_count end_count tmp

  start_count="$(count_marker "$START_MARKER" "$agents_file")"
  end_count="$(count_marker "$END_MARKER" "$agents_file")"

  if [ "$start_count" -eq 0 ] && [ "$end_count" -eq 0 ]; then
    if [ -f "$agents_file" ] && [ -s "$agents_file" ]; then
      printf '\n' >> "$agents_file"
    fi
    cat "$TEMPLATE_FILE" >> "$agents_file"
    return
  fi

  if [ "$start_count" -ne 1 ] || [ "$end_count" -ne 1 ]; then
    echo "Refusing to update $agents_file: expected zero or one complete managed block." >&2
    exit 1
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/sonbbal-agents.XXXXXX")"
  awk -v start="$START_MARKER" -v end="$END_MARKER" -v template="$TEMPLATE_FILE" '
    $0 == start {
      while ((getline line < template) > 0) {
        print line
      }
      close(template)
      skip = 1
      next
    }
    $0 == end {
      skip = 0
      next
    }
    !skip {
      print
    }
  ' "$agents_file" > "$tmp"

  mv "$tmp" "$agents_file"
}

install_skill_link() {
  local skills_parent="$TARGET_DIR/.agents/skills"
  local skill_link="$skills_parent/$PLUGIN_NAME"

  mkdir -p "$skills_parent"

  if [ -L "$skill_link" ]; then
    rm "$skill_link"
  elif [ -e "$skill_link" ]; then
    if [ "$FORCE_SKILL_LINK" -ne 1 ]; then
      echo "Refusing to replace existing non-symlink path: $skill_link" >&2
      echo "Remove it manually or rerun with --force-skill-link." >&2
      exit 1
    fi
    rm -rf "$skill_link"
  fi

  ln -s "$SKILLS_DIR" "$skill_link"
}

update_agents_file

if [ "$SKIP_SKILL_LINK" -ne 1 ]; then
  install_skill_link
fi

echo "Bootstrapped Sonbbal Superpowers for Codex in $TARGET_DIR"
echo "Updated: $TARGET_DIR/AGENTS.md"
if [ "$SKIP_SKILL_LINK" -ne 1 ]; then
  echo "Fallback skills: $TARGET_DIR/.agents/skills/$PLUGIN_NAME -> $SKILLS_DIR"
fi
