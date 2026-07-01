#!/usr/bin/env bash
# Full global install — copies every plugin's agents/skills/hooks flat into
# ~/.claude/ and wires git hooks. This is Option C in the README (no plugin
# manager required).
#
# The devkit is a multi-plugin marketplace (bmad_v6, engineering, devtools,
# pr-workflow). This script walks ALL of them: skills are directory-format
# (skills/<name>/SKILL.md with an optional references/ subfolder), agents live
# under each plugin's agents/, and the shared hooks / git-hooks / references /
# CLAUDE.md live under bmad_v6.
#
# Platform support:
#   Linux / macOS  — run directly: bash plugins/bmad_v6/scripts/install-global.sh
#
# ┌─ USE THIS SCRIPT when ────────────────────────────────────────────────────┐
# │  • Private/internal fork not published to public GitHub                   │
# │  • No internet at install time                                            │
# │  • You are the repo owner iterating on the devkit itself — edit locally,  │
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
# └───────────────────────────────────────────────────────────────────────────┘
#
# Safe on existing ~/.claude/:
#   - Same-named agents/skills/references are updated to the new version
#   - Your custom files with different names are untouched
#   - ~/.claude/CLAUDE.md is NEVER overwritten — an @include line is injected
#     once; re-running is idempotent
#
# Only the files Claude actually reads are copied per skill (SKILL.md +
# references/*.md). SkillSpec tool artifacts (skill.spec.yml, deps.toml,
# source/, imports/, resources/, .skillspec/) are skipped by design.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BMAD="$(cd "$SCRIPT_DIR/.." && pwd)"                 # plugins/bmad_v6 (canonical hooks/CLAUDE.md)
PLUGINS="$(cd "$SCRIPT_DIR/../.." && pwd)"           # plugins/
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

# ── Agents (every plugin that ships them) ────────────────────────────────────
agent_count=0
for agent_dir in "$PLUGINS"/*/agents; do
    [ -d "$agent_dir" ] || continue
    if ls "$agent_dir"/*.md >/dev/null 2>&1; then
        cp "$agent_dir"/*.md "$GLOBAL/agents/"
        agent_count=$((agent_count + $(ls "$agent_dir"/*.md | wc -l)))
    fi
done
echo "✓ agents — $agent_count installed (your custom agents left untouched)"

# ── Skills (directory-format, all plugins) ───────────────────────────────────
# Copy ONLY SKILL.md + references/*.md so the flat install stays clean and does
# not carry SkillSpec tool scaffolding that Claude never reads.
skill_count=0
for skill_dir in "$PLUGINS"/*/skills/*/; do
    [ -f "$skill_dir/SKILL.md" ] || continue
    skill_name="$(basename "$skill_dir")"
    dest="$GLOBAL/skills/$skill_name"
    mkdir -p "$dest"
    cp "$skill_dir/SKILL.md" "$dest/SKILL.md"
    if ls "$skill_dir"references/*.md >/dev/null 2>&1; then
        mkdir -p "$dest/references"
        cp "$skill_dir"references/*.md "$dest/references/"
    fi
    rm -f "$GLOBAL/skills/${skill_name}.md"   # drop any stale flat file
    skill_count=$((skill_count + 1))
done
echo "✓ skills — $skill_count installed (directory format, stale flat files removed)"

# ── Shared references (non-skill; currently bmad_v6 only) ─────────────────────
for ref_dir in "$PLUGINS"/*/references; do
    [ -d "$ref_dir" ] || continue
    ls "$ref_dir"/*.md >/dev/null 2>&1 && cp "$ref_dir"/*.md "$GLOBAL/references/"
done
echo "✓ shared references"

# ── CLAUDE.md — never overwrite ─────────────────────────────────────────────
# Devkit standards land in ~/.claude/devkit/CLAUDE.md. An @include line is
# injected once into ~/.claude/CLAUDE.md so your personal rules are preserved.
INCLUDE_LINE="@~/.claude/devkit/CLAUDE.md"
cp "$BMAD/CLAUDE.md" "$GLOBAL/devkit/CLAUDE.md"

if [ ! -f "$GLOBAL/CLAUDE.md" ]; then
    printf '%s\n' "$INCLUDE_LINE" > "$GLOBAL/CLAUDE.md"
    echo "✓ CLAUDE.md created with @include → devkit/CLAUDE.md"
elif ! grep -qF "$INCLUDE_LINE" "$GLOBAL/CLAUDE.md"; then
    printf '\n%s\n' "$INCLUDE_LINE" >> "$GLOBAL/CLAUDE.md"
    echo "✓ CLAUDE.md — @include injected (your existing content preserved)"
else
    echo "✓ CLAUDE.md — @include already present, skipped"
fi

# ── Claude Code hooks (every plugin that ships *.sh) ─────────────────────────
for hook_dir in "$PLUGINS"/*/hooks; do
    [ -d "$hook_dir" ] || continue
    if ls "$hook_dir"/*.sh >/dev/null 2>&1; then
        cp "$hook_dir"/*.sh "$GLOBAL/hooks/"
    fi
done
chmod +x "$GLOBAL/hooks/"*.sh 2>/dev/null || true
echo "✓ Claude Code hooks (session-bootstrap, env-guard, pr-review-responder)"

# ── Git hook templates (canonical set under bmad_v6) ─────────────────────────
if ls "$BMAD/git-hooks/"* >/dev/null 2>&1; then
    cp "$BMAD/git-hooks/"* "$GLOBAL/git-hooks/"
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
    bash "$BMAD/git-hooks/install.sh"
else
    echo "Not in a git repo — git hooks not wired."
    echo "To install later in any repo: bash ~/.claude/git-hooks/install.sh"
fi

echo ""
if [ "$MODE" = "fresh" ]; then
    echo "✅ Fresh install complete — $skill_count skills, $agent_count agents."
else
    echo "✅ Update complete — $skill_count skills, $agent_count agents; existing customizations preserved."
fi
echo ""
echo "To wire Claude Code hooks, add to ~/.claude/settings.json:"
echo '  "hooks": {'
echo '    "SessionStart": [{"hooks": [{"type": "command", "command": "bash ~/.claude/hooks/session-bootstrap.sh"}]}],'
echo '    "PreToolUse":  [{"matcher": "Read",  "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/env-guard.sh", "timeout": 3}]}],'
echo '    "PostToolUse": [{"matcher": "Bash",  "hooks": [{"type": "command", "command": "bash ~/.claude/hooks/pr-review-responder.sh"}]}]'
echo '  }'
