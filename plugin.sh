#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_JSON="$SCRIPT_DIR/.claude-plugin/marketplace.json"

MARKETPLACE_NAME=$(python3 -c "import json; d=json.load(open('$MARKETPLACE_JSON')); print(d['name'])")
PLUGINS=$(python3 -c "import json; d=json.load(open('$MARKETPLACE_JSON')); [print(p['name']) for p in d['plugins']]")

usage() {
  echo "Usage: $0 [install|uninstall|reload]"
  echo ""
  echo "  install   — Add marketplace and install all plugins"
  echo "  uninstall — Remove all plugins and marketplace"
  echo "  reload    — Uninstall then reinstall everything"
  exit 1
}

install() {
  echo "Adding marketplace '$MARKETPLACE_NAME'..."
  claude plugin marketplace add "$SCRIPT_DIR"

  while IFS= read -r plugin; do
    echo "Installing plugin '$plugin'..."
    claude plugin install "$MARKETPLACE_NAME/$plugin"
  done <<< "$PLUGINS"

  echo ""
  echo "Done. Please restart Claude Code to apply changes."
}

uninstall() {
  while IFS= read -r plugin; do
    echo "Removing plugin '$plugin'..."
    claude plugin uninstall "$plugin" || true
  done <<< "$PLUGINS"

  echo "Removing marketplace '$MARKETPLACE_NAME'..."
  claude plugin marketplace remove "$MARKETPLACE_NAME" || true

  echo ""
  echo "Done. Please restart Claude Code to apply changes."
}

reload() {
  uninstall
  install
}

case "${1:-}" in
  install)   install ;;
  uninstall) uninstall ;;
  reload)    reload ;;
  *)         usage ;;
esac
