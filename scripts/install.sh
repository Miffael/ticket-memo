#!/usr/bin/env bash
# Installs the ticket-memo skill into the skill folders of one or more AI agents (Linux / macOS).
#
# By default creates a symlink from each agent's skills folder to <repo>/skills/ticket-memo,
# so `git pull` in the repo updates every agent at once. Use --copy for a standalone copy.
#
# Targets:
#   claude       ~/.claude/skills          (Claude Code)
#   agents       ~/.agents/skills          (cross-agent folder: Codex, Gemini CLI and others)
#   antigravity  ~/.gemini/config/skills   (Google Antigravity)
#
# Usage:
#   scripts/install.sh                                  # Claude Code only
#   scripts/install.sh --target claude,antigravity
#   scripts/install.sh --target all --dry-run
#   scripts/install.sh --target all --uninstall
set -euo pipefail

SKILL=ticket-memo
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills/$SKILL" && pwd)"
TARGETS=claude; COPY=0; FORCE=0; UNINSTALL=0; DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target|-t) TARGETS="$2"; shift 2 ;;
    --copy) COPY=1; shift ;;
    --force) FORCE=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --dry-run|-n) DRY=1; shift ;;
    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done
[ "$TARGETS" = all ] && TARGETS=claude,agents,antigravity
[ -f "$SRC/SKILL.md" ] || { echo "SKILL.md not found in $SRC" >&2; exit 1; }

run() { if [ "$DRY" = 1 ]; then echo "  would run: $*"; else "$@"; fi; }

dir_for() {
  case "$1" in
    claude) echo "$HOME/.claude/skills" ;;
    agents) echo "$HOME/.agents/skills" ;;
    antigravity) echo "$HOME/.gemini/config/skills" ;;
    *) echo "unknown target: $1" >&2; exit 1 ;;
  esac
}

IFS=',' read -r -a list <<< "$TARGETS"
for t in "${list[@]}"; do
  base="$(dir_for "$t")"; dest="$base/$SKILL"
  echo "[$t] $dest"

  if [ "$UNINSTALL" = 1 ]; then
    if [ -L "$dest" ]; then run rm "$dest"; echo "  link removed"
    elif [ -f "$dest/SKILL.md" ] && head -3 "$dest/SKILL.md" | grep -q "name: *$SKILL"; then run rm -rf "$dest"; echo "  folder removed"
    elif [ -e "$dest" ]; then echo "  not a ticket-memo install - left untouched" >&2
    else echo "  not installed"; fi
    continue
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$SRC" ]; then echo "  already linked"; continue; fi
    if [ "$FORCE" != 1 ]; then echo "  exists - skipped (use --force to move it to a .bak folder)" >&2; continue; fi
    if [ -L "$dest" ]; then run rm "$dest"; else run mv "$dest" "$dest.bak-$(date +%Y%m%d-%H%M%S)"; fi
    echo "  existing install moved aside"
  fi

  run mkdir -p "$base"
  if [ "$COPY" = 1 ]; then run cp -R "$SRC" "$dest"; else run ln -s "$SRC" "$dest"; fi
  if [ "$DRY" = 1 ]; then echo "  (dry run, nothing changed)"; else echo "  installed"; fi
done

[ "$UNINSTALL" = 1 ] || echo "Restart the agent (or start a new session) so it picks up the skill."
