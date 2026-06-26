#!/usr/bin/env bash
# Full global install — copies everything flat into ~/.claude/ and wires git hooks.
# This is Option C in the README (no plugin manager required).
#
# Platform support:
#   Linux / macOS  — run directly: bash .claude/scripts/install-global.sh
#
# ┌─ USE THIS SCRIPT when ────────────────────────────────────────────────────┐
# │  • Private/internal fork not published to public GitHub                   │
# │    (claude plugin install requires a public URL)                          │
# │  • No internet at install time                                            │
# │  • You are the repo owner iterating on .claude/ itself — edit locally,   │
# │    run this, changes land in ~/.claude/ immediately without a             │
# │    git push + `claude plugin update` cycle                                │
# │  • You want files flat in ~/.claude/ rather than namespaced under         │
# │    ~/.claude/plugins/cache/                                               │
# └───────────────────────────────────────────────────────────────────────────┘
#
# ┌─ SKIP THIS SCRIPT and use the plugin when ────────────────────────────────┐
# │  • Distributing to teammates from a public GitHub repo                    │
# │    → `claude plugin install github:LuisFelipeMoro/claude-devkit`          │
# │  • You want `claude plugin update` for version management                 │
# │  • You only need Claude Code skills/agents (no git hooks)                 │
# │    → plugin install alone is enough; git hooks are optional               │
# └───────────────────────────────────────────────────────────────────────────┘
#
# Safe on existing ~/.claude/:
#   - Same-named agents/skills/references are updated to new version
#   - Your custom files with different names are untouched
#   - ~/.claude/CLAUDE.md is NEVER overwritten — an @include line is injected
#     once; re-running is idempotent
#
# Usage: bash .claude/scripts/install-global.sh
set -e

DOTCLAUDE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GLOBAL="$HOME/.claude"

# Detect fresh vs existing install for clearer output
if [ -d "$GLOBAL/agents" ] || [ -f "$GLOBAL/CLAUDE.md" ]; then
    echo "Updating existing ~/.claude/ ..."
    MODE="update"
else
    echo "Creating fresh ~/.claude/ ..."
    MODE="fresh"
fi

mkdir -p "$GLOBAL/agents" "$GLOBAL/skills" "$GLOBAL/references" \
         "$GLOBAL/hooks"  "$GLOBAL/git-hooks" "$GLOBAL/devkit"

# ── Agents ──────────────────────────────────────────────────────────────────
if ls "$DOTCLAUDE/agents/"*.md >/dev/null 2>&1; then
    cp "$DOTCLAUDE/agents/"*.md "$GLOBAL/agents/"
    echo "✓ agents (updated existing, left your custom agents untouched)"
fi

# ── Skills ──────────────────────────────────────────────────────────────────
# Write each skill as directory-format (skills/{name}/SKILL.md) so Claude Code
# resolves them consistently. Also removes any stale flat .md to avoid collisions.
if ls "$DOTCLAUDE/skills/"*.md >/dev/null 2>&1; then
    for skill_file in "$DOTCLAUDE/skills/"*.md; do
        skill_name=$(basename "$skill_file" .md)
        mkdir -p "$GLOBAL/skills/$skill_name"
        cp "$skill_file" "$GLOBAL/skills/$skill_name/SKILL.md"
        # Remove stale flat file if it pre-existed from an older install
        rm -f "$GLOBAL/skills/${skill_name}.md"
    done
    echo "✓ skills (directory format, stale flat files removed)"
fi

# ── References ──────────────────────────────────────────────────────────────
if ls "$DOTCLAUDE/references/"*.md >/dev/null 2>&1; then
    cp "$DOTCLAUDE/references/"*.md "$GLOBAL/references/"
    echo "✓ references"
fi

# ── CLAUDE.md — never overwrite ─────────────────────────────────────────────
# Devkit standards land in ~/.claude/devkit/CLAUDE.md.
# An @include line is injected once into ~/.claude/CLAUDE.md so your personal
# rules (RTK, Go proverbs, etc.) are preserved on every re-run.
INCLUDE_LINE="@~/.claude/devkit/CLAUDE.md"
cp "$DOTCLAUDE/CLAUDE.md" "$GLOBAL/devkit/CLAUDE.md"

if [ ! -f "$GLOBAL/CLAUDE.md" ]; then
    printf '%s\n' "$INCLUDE_LINE" > "$GLOBAL/CLAUDE.md"
    echo "✓ CLAUDE.md created with @include → devkit/CLAUDE.md"
elif ! grep -qF "$INCLUDE_LINE" "$GLOBAL/CLAUDE.md"; then
    printf '\n%s\n' "$INCLUDE_LINE" >> "$GLOBAL/CLAUDE.md"
    echo "✓ CLAUDE.md — @include injected (your existing content preserved)"
else
    echo "✓ CLAUDE.md — @include already present, skipped"
fi

# ── Claude Code hooks ────────────────────────────────────────────────────────
if ls "$DOTCLAUDE/hooks/"*.sh >/dev/null 2>&1; then
    cp "$DOTCLAUDE/hooks/"*.sh "$GLOBAL/hooks/"
    # chmod is a no-op on Windows/Git Bash but never fails
    chmod +x "$GLOBAL/hooks/"*.sh 2>/dev/null || true
    echo "✓ Claude Code hooks (session-bootstrap, env-guard, pr-review-responder)"
fi

# ── Git hook templates ───────────────────────────────────────────────────────
if ls "$DOTCLAUDE/git-hooks/"* >/dev/null 2>&1; then
    cp "$DOTCLAUDE/git-hooks/"* "$GLOBAL/git-hooks/"
    chmod +x "$GLOBAL/git-hooks/pre-commit" \
             "$GLOBAL/git-hooks/pre-push" \
             "$GLOBAL/git-hooks/commit-msg" \
             "$GLOBAL/git-hooks/install.sh" 2>/dev/null || true
    echo "✓ git-hook templates staged to ~/.claude/git-hooks/"
fi

# ── Wire git hooks into current repo ────────────────────────────────────────
if git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo ""
    echo "Wiring git hooks into current repo..."
    bash "$DOTCLAUDE/git-hooks/install.sh"
else
    echo "Not in a git repo — git hooks not wired."
    echo "To install later in any repo: bash ~/.claude/git-hooks/install.sh"
fi

echo ""
if [ "$MODE" = "fresh" ]; then
    echo "✅ Fresh install complete."
else
    echo "✅ Update complete — existing customizations preserved."
fi
echo ""
echo "To wire Claude Code hooks, add to ~/.claude/settings.json:"
echo '  "hooks": {'
echo '    "SessionStart": [{"hooks": [{"type": "command", "command": "bash ~/.claude/hooks/session-bootstrap.sh"}]}],'
echo '    "PreToolUse":  [{"matcher": "Read",  "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/env-guard.sh", "timeout": 3}]}],'
echo '    "PostToolUse": [{"matcher": "Bash",  "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/pr-review-responder.sh"}]}]'
echo '  }'
