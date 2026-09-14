#!/bin/bash

set -e

REPO_URL="https://github.com/starcut/claude-development-workflow.git"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading claude-development-workflow..."

git clone --depth 1 "$REPO_URL" "$TMP_DIR/claude-development-workflow" >/dev/null 2>&1

echo "Installing Claude Code commands..."

mkdir -p "$PWD/.claude/commands"

cp -R "$TMP_DIR/claude-development-workflow/.claude/commands/"* \
  "$PWD/.claude/commands/"

echo "Installation completed."
