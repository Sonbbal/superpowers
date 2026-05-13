#!/usr/bin/env bash
# Verifies the Codex project bootstrap updates AGENTS.md safely and idempotently.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BOOTSTRAP_SCRIPT="$REPO_ROOT/codex/scripts/bootstrap-project.sh"
PLUGIN_NAME="sonbbal-superpowers-codex"
START_MARKER="sonbbal-superpowers-codex:start"
END_MARKER="sonbbal-superpowers-codex:end"

fail() {
  echo "  [FAIL] $1"
  exit 1
}

pass() {
  echo "  [PASS] $1"
}

require_text() {
  local file="$1"
  local pattern="$2"
  local message="$3"

  [ -f "$file" ] || fail "Missing required file: $file"

  if rg -q "$pattern" "$file"; then
    pass "$message"
  else
    fail "$message"
  fi
}

echo "=== Test: Codex Project Bootstrap ==="

[ -x "$BOOTSTRAP_SCRIPT" ] || fail "Missing executable bootstrap script: $BOOTSTRAP_SCRIPT"
pass "bootstrap script exists"

project_dir="$(mktemp -d "${TMPDIR:-/tmp}/sonbbal-codex-bootstrap.XXXXXX")"
trap 'rm -rf "$project_dir"' EXIT

cat > "$project_dir/AGENTS.md" <<'AGENTS'
# Existing Project Rules

- Preserve this project rule.
AGENTS

bash "$BOOTSTRAP_SCRIPT" "$project_dir" > "$project_dir/bootstrap-1.log"

agents_file="$project_dir/AGENTS.md"
skill_link="$project_dir/.agents/skills/$PLUGIN_NAME"

require_text "$agents_file" '# Existing Project Rules' \
  "bootstrap preserves existing AGENTS.md content"
require_text "$agents_file" "$START_MARKER" \
  "bootstrap adds managed AGENTS.md start marker"
require_text "$agents_file" "$END_MARKER" \
  "bootstrap adds managed AGENTS.md end marker"
require_text "$agents_file" 'using-superpowers' \
  "bootstrap adds using-superpowers guidance"

[ -L "$skill_link" ] || fail "Expected fallback skill link: $skill_link"
pass "bootstrap creates fallback skill symlink"

[ -f "$skill_link/using-superpowers/SKILL.md" ] \
  || fail "Fallback skill link does not expose using-superpowers"
pass "fallback skill link exposes using-superpowers"

before_cksum="$(cksum "$agents_file")"
bash "$BOOTSTRAP_SCRIPT" "$project_dir" > "$project_dir/bootstrap-2.log"
after_cksum="$(cksum "$agents_file")"

[ "$before_cksum" = "$after_cksum" ] || fail "Bootstrap is not idempotent for AGENTS.md"
pass "bootstrap is idempotent for AGENTS.md"

start_count="$(rg -c "$START_MARKER" "$agents_file")"
end_count="$(rg -c "$END_MARKER" "$agents_file")"

[ "$start_count" -eq 1 ] || fail "Expected one start marker, found $start_count"
[ "$end_count" -eq 1 ] || fail "Expected one end marker, found $end_count"
pass "managed AGENTS.md block appears exactly once"

rm "$skill_link"
mkdir -p "$skill_link"

if bash "$BOOTSTRAP_SCRIPT" "$project_dir" > "$project_dir/bootstrap-3.log" 2>&1; then
  fail "Bootstrap replaced an existing non-symlink fallback path without --force-skill-link"
fi
pass "bootstrap refuses to replace non-symlink fallback path by default"

bash "$BOOTSTRAP_SCRIPT" "$project_dir" --force-skill-link > "$project_dir/bootstrap-4.log"
[ -L "$skill_link" ] || fail "Expected forced fallback skill link replacement"
pass "bootstrap can replace fallback path with explicit force"
